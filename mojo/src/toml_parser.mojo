"""
Rules:
Dotted keys, can create a dictionary grouping the values.
"""

from utils import Variant
from memory import OwnedPointer
import os


struct TomlType[o: ImmutOrigin](Movable, Writable):
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool
    comptime Array = List[UnsafePointer[TomlType[Self.o], MutAnyOrigin]]
    comptime Table = Dict[
        StringSlice[Self.o], UnsafePointer[TomlType[Self.o], MutAnyOrigin]
    ]

    comptime OpaqueArray = List[OpaquePointer[MutAnyOrigin]]
    comptime OpaqueTable = Dict[
        StringSlice[Self.o], OpaquePointer[MutAnyOrigin]
    ]

    var inner: AnyTomlType[Self.o]

    fn __init__(
        out self, var v: AnyTomlType[Self.o], explicitly_constructed: ()
    ):
        self.inner = v

    fn __init__(out self, var v: StringSlice[Self.o]):
        self.inner = v

    fn __init__(out self, var v: Int):
        self.inner = v

    fn __init__(out self, var v: Float64):
        self.inner = v

    fn __init__(out self, var v: Bool):
        self.inner = v

    fn __init__(out self, var v: Self.Array):
        var opaque_array = [i.bitcast[NoneType]() for i in v]
        self.inner = opaque_array^

    fn __init__(out self, var v: Self.Table):
        var opaque_table = {
            kv.key: kv.value.bitcast[NoneType]() for kv in v.items()
        }
        self.inner = opaque_table^

    fn write_to(self, mut w: Some[Writer]):
        ref inner = self.inner

        if inner.isa[self.String]():
            w.write('String("', inner[self.String], '")')
        elif inner.isa[self.Integer]():
            w.write("Integer(", inner[self.Integer], ")")
        elif inner.isa[self.Float]():
            w.write("Float(", inner[self.Float], ")")
        elif inner.isa[self.Boolean]():
            w.write("Boolean(", inner[self.Boolean], ")")
        elif inner.isa[self.OpaqueArray]():
            ref array = inner[self.OpaqueArray]
            w.write("[")
            for i, v in enumerate(array):
                if i != 0:
                    w.write(", ")
                w.write(v.bitcast[TomlType[Self.o]]()[])
            w.write("]")
        elif inner.isa[self.OpaqueTable]():
            ref table = inner[self.OpaqueTable]
            w.write("{")
            for i, kv in enumerate(table.items()):
                if i != 0:
                    w.write(", ")
                w.write(
                    '"', kv.key, '": ', kv.value.bitcast[TomlType[Self.o]]()[]
                )
            w.write("}")


comptime AnyTomlType[o: ImmutOrigin] = Variant[
    TomlType[o].String,
    TomlType[o].Integer,
    TomlType[o].Float,
    TomlType[o].Boolean,
    TomlType[o].OpaqueArray,
    TomlType[o].OpaqueTable,
]


fn get_absolute_idx(
    full_content: StringSlice, line_idx: Int, relative_idx: Int
) -> Int:
    orig_idx = 0
    for y in range(line_idx):
        orig_idx = full_content.find("\n", orig_idx) + 1
    return relative_idx + orig_idx


fn parse_multiline_string[
    o: ImmutOrigin
](content: StringSlice[o], var idx: Int) -> TomlType[o]:
    var close_char = idx + 3

    while (scape_idx := content.find('/"', close_char)) != -1:
        close_char = scape_idx + 1

    char_end = content.find('"""', close_char)
    var final_content = content[idx + 1 : char_end]
    return TomlType[o](final_content)


fn parse_string[
    o: ImmutOrigin
](content: StringSlice[o], from_char_idx: Int) -> TomlType[o]:
    var close_char = from_char_idx + 1

    while (scape_idx := content.find('/"', close_char)) != -1:
        close_char = scape_idx + 1

    char_end = content.find('"', close_char)
    var final_content = content[from_char_idx + 1 : char_end]
    return TomlType[o](final_content)


fn parse_inline_table[
    o: ImmutOrigin
](orig_content: StringSlice[o], mut from_char_idx: Int) -> TomlType[o]:
    var close_char = from_char_idx + 1

    var list_nested = 0
    var table_nested = 0
    var string_nested = 0
    var multistring_nested = 0

    var cip = close_char
    var ci = close_char
    var bts = orig_content.as_bytes()
    var objs = TomlType[o].Table()

    print("start parsing at:", ci)

    while (b := bts[ci]) != ord(
        "}"
    ) or list_nested + table_nested + string_nested + multistring_nested > 0:
        print(chr(Int(bts[ci])), end="")
        if b == ord('"'):
            if bts[ci + 1] == ord('"') and bts[ci + 2] == ord('"'):
                # print("\nthe content is a multiline string")
                if multistring_nested == 1 and bts[ci - 1] != ord("\\"):
                    multistring_nested -= 1
                else:
                    multistring_nested += 1
                ci += 3
                continue

            # print("\nthe content is a string")
            if string_nested == 1 and bts[ci - 1] != ord("\\"):
                string_nested -= 1
            else:
                string_nested += 1
            ci += 1
            continue

        # in case you are in a string, just keep going
        if string_nested > 0 or multistring_nested > 0:
            ci += 1
            continue

        # if out of string...
        elif b == ord("{"):
            table_nested += 1
        elif b == ord("}"):
            table_nested -= 1

        elif b == ord("["):
            list_nested += 1
        elif b == ord("]"):
            list_nested -= 1
        elif (
            b == ord(",")
            and list_nested + table_nested + string_nested + multistring_nested
            == 0
        ):
            print()
            var obj_str = orig_content[cip:ci].strip()
            print(
                "\n\tobject found in the dict: '",
                obj_str,
                "' in between ",
                cip,
                " and ",
                ci,
                sep="",
            )
            var eq_idx = obj_str.find("=")
            var kk = obj_str[:eq_idx].strip()
            var val = obj_str[eq_idx + 1 :].strip()
            print(
                "\n\tfound key: '", kk, "' and found value: '", val, "'", sep=""
            )
            var _lidx = 0
            var toml_obj = parse_value(val, _lidx)
            print("\n\tParsed value: '", toml_obj, "'", sep="")
            objs[kk] = UnsafePointer(to=toml_obj)
            cip = ci + 1
        ci += 1

    # NOTE: Will potentially fail if there is a trailing comma
    print(chr(Int(bts[ci])))
    var obj_str = orig_content[cip:ci].strip()
    print(
        "\n\tobject found in the dict:'",
        obj_str,
        "' in between ",
        cip,
        " and ",
        ci,
        sep="",
    )
    var eq_idx = obj_str.find("=")
    var kk = obj_str[:eq_idx].strip()
    var val = obj_str[eq_idx + 1 :].strip()
    print("\n\tfound key: '", kk, "' and found value: '", val, "'", sep="")
    var _lidx = 0
    var toml_obj = parse_value(val, _lidx)
    print("\n\tParsed value: '", toml_obj, "'", sep="")
    objs[kk] = UnsafePointer(to=toml_obj)

    print("end at:", ci + 1)
    from_char_idx = ci + 1
    # print("final table:", TomlType[o](objs.copy()))
    return TomlType[o](objs^)


fn parse_inline_list[
    o: ImmutOrigin
](
    orig_content: StringSlice[o],
    # lines: List[StringSlice[o]],
    # mut line_idx: Int,
    mut from_char_idx: Int,
) -> TomlType[o]:
    # ref line = lines[line_idx]
    # from_char_idx = get_absolute_idx(orig_content, line_idx, from_char_idx)

    var close_char = from_char_idx + 1

    var list_nested = 0
    var table_nested = 0
    var string_nested = 0
    var multistring_nested = 0

    var cip = close_char
    var ci = close_char
    var bts = orig_content.as_bytes()
    var objs = TomlType[o].Array()

    print("start parsing at:", ci)

    while (b := bts[ci]) != ord(
        "]"
    ) or list_nested + table_nested + string_nested + multistring_nested > 0:
        print(chr(Int(bts[ci])), end="")
        if b == ord('"'):
            if bts[ci + 1] == ord('"') and bts[ci + 2] == ord('"'):
                # print("\nthe content is a multiline string")
                if multistring_nested == 1 and bts[ci - 1] != ord("\\"):
                    multistring_nested -= 1
                else:
                    multistring_nested += 1
                ci += 3
                continue

            # print("\nthe content is a string")
            if string_nested == 1 and bts[ci - 1] != ord("\\"):
                string_nested -= 1
            else:
                string_nested += 1
            ci += 1
            continue

        # in case you are in a string, just keep going
        if string_nested > 0 or multistring_nested > 0:
            ci += 1
            continue

        # if out of string...
        elif b == ord("{"):
            table_nested += 1
        elif b == ord("}"):
            table_nested -= 1

        elif b == ord("["):
            list_nested += 1
        elif b == ord("]"):
            list_nested -= 1
        elif (
            b == ord(",")
            and list_nested + table_nested + string_nested + multistring_nested
            == 0
        ):
            print()
            var obj_str = orig_content[cip:ci].strip()
            print(
                "\n\tobject found in the list: '",
                obj_str,
                "' in between ",
                cip,
                " and ",
                ci,
                sep="",
            )
            var _lidx = 0
            var toml_obj = parse_value(obj_str, _lidx)
            print("\n\tparsed_value: '", toml_obj, "'", sep="")
            objs.append(UnsafePointer(to=toml_obj))
            cip = ci + 1
        ci += 1

    print(chr(Int(bts[ci])))
    var obj_str = orig_content[cip:ci]

    # Will potentially fail if there is a trailing comma
    print(
        "\n\tlast object found in the list: '",
        obj_str,
        "' in between ",
        cip,
        " and ",
        ci,
        sep="",
    )
    var _lidx = 0
    var toml_obj = parse_value(obj_str, _lidx)
    print("\n\tparsed_value: '", toml_obj, "'", sep="")
    objs.append(UnsafePointer(to=toml_obj))

    print("end at:", ci + 1)
    from_char_idx = ci + 1
    return TomlType[o](objs^)


fn string_to_type[o: ImmutOrigin](str_value: StringSlice[o]) -> TomlType[o]:
    print("Casting value '", str_value, "' into a type...", sep="")
    s = str_value.strip()
    if len(parts := s.split(".")) == 2:
        if parts[0].is_ascii_digit() and parts[1].is_ascii_digit():
            try:
                return TomlType[o](atof(s))
            except:
                pass

    if s.is_ascii_digit():
        try:
            return TomlType[o](Int(s))
        except:
            pass

    if s == "true":
        return TomlType[o](True)

    if s == "false":
        return TomlType[o](False)

    os.abort(String("Could not cast value '", str_value, "' to a type"))


fn is_before(v: Int, /, *others: Int) -> Bool:
    if v == -1:
        return False

    for o in others:
        if o != -1 and o < v:
            return False

    return True


fn parse_value[
    o: ImmutOrigin
](file_content: StringSlice[o], mut idx: Int) -> TomlType[o]:
    var multiline_string_start = file_content.find('"""', idx)
    var string_start = file_content.find('"', idx)
    var list_start = file_content.find("[", idx)
    var table_start = file_content.find("{", idx)

    var content: TomlType[o]
    if is_before(multiline_string_start, list_start, table_start):
        print(
            "Parsing multiline string: ###\n",
            file_content[multiline_string_start : multiline_string_start + 20],
            "\n...\n###",
            sep="",
        )
        content = parse_multiline_string(
            file_content, idx=multiline_string_start
        )
        idx = multiline_string_start

    elif is_before(string_start, list_start, table_start):
        print(
            "parsing string:'",
            file_content[string_start : string_start + 20],
            "...'",
            sep="",
        )
        content = parse_string(file_content, from_char_idx=string_start)
        idx = multiline_string_start

    elif is_before(list_start, table_start):
        print(
            "parsing linine list: ###\n",
            file_content[list_start : list_start + 20],
            "\n...\n###",
        )
        content = parse_inline_list(file_content, from_char_idx=list_start)
        idx = list_start

    elif is_before(table_start, list_start):
        print(
            "parsing inline table: ###\n",
            file_content[table_start : table_start + 20],
            "\n...\n###",
        )
        content = parse_inline_table(file_content, from_char_idx=table_start)
        idx = list_start

    else:
        print("infer type for all: '", file_content, "'", sep="")
        var eol = file_content.find("\n", idx + 1)
        # TODO: Check this...
        eol = len(file_content) - idx if eol == -1 else eol
        var cnt = file_content[idx:eol]
        content = string_to_type(cnt)
        idx = eol + 1

    return content^


fn update_base_with_kv_table[
    o: ImmutOrigin
](
    key: StringSlice[o],
    mut value: TomlType[o],
    var base: TomlType[o].OpaqueTable,
) -> TomlType[o].OpaqueTable:
    var keys = key.split(".")

    print("nested keys found:", keys)

    var table: UnsafePointer[TomlType[o].OpaqueTable, origin=MutAnyOrigin]
    table = UnsafePointer[origin=MutAnyOrigin](to=base)

    for key in keys[: len(keys) - 1]:  # leave the last one to the end.
        print("navigating to key:", key)
        var new_tb = TomlType[o].Table()
        var new_toml_table = TomlType[o](new_tb^)
        var opaque_table_ptr = UnsafePointer(to=new_toml_table).bitcast[
            NoneType
        ]()
        var new_tbl_ptr = table[].setdefault(key, opaque_table_ptr)
        table = UnsafePointer(
            to=new_tbl_ptr.bitcast[TomlType[o]]()[].inner[
                TomlType[o].OpaqueTable
            ]
        )

    ref last_key = keys[len(keys) - 1]
    table[][keys[len(keys) - 1]] = UnsafePointer(to=value).bitcast[NoneType]()

    return base^


fn update_base_with_kv_list[
    o: ImmutOrigin, mode: StaticString = "table"
](
    key: StringSlice[o],
    mut value: TomlType[o],
    var base: TomlType[o].OpaqueTable,
) -> TomlType[o].OpaqueTable:
    var keys = key.split(".")

    print("nested keys found:", keys)

    var table: UnsafePointer[TomlType[o].OpaqueTable, origin=MutAnyOrigin]
    table = UnsafePointer[origin=MutAnyOrigin](to=base)

    for key in keys[: len(keys) - 1]:  # leave the last one to the end.
        print("navigating to key:", key)
        var new_tb = TomlType[o].Table()
        var new_toml_table = TomlType[o](new_tb^)
        var opaque_table_ptr = UnsafePointer(to=new_toml_table).bitcast[
            NoneType
        ]()
        var new_tbl_ptr = table[].setdefault(key, opaque_table_ptr)
        table = UnsafePointer(
            to=new_tbl_ptr.bitcast[TomlType[o]]()[].inner[
                TomlType[o].OpaqueTable
            ]
        )

    ref last_key = keys[len(keys) - 1]
    var toml_array = TomlType(TomlType[o].Array())
    var array_ref = table[].setdefault(
        last_key, UnsafePointer(to=toml_array).bitcast[NoneType]()
    )
    ref inner_array = array_ref.bitcast[TomlType[o]]()[].inner[
        TomlType[o].OpaqueArray
    ]
    inner_array.append(UnsafePointer(to=value).bitcast[NoneType]())

    return base^


fn try_get_kv_pair[
    o: ImmutOrigin
](file_content: StringSlice[o], mut idx: Int) -> Optional[
    Tuple[StringSlice[o], TomlType[o]]
]:
    if file_content.as_bytes()[idx] in [Byte(ord("[")), Byte(ord("{"))]:
        return None

    if (eq_idx := file_content.find("=", idx + 1)) == -1:
        return None

    var key = file_content[idx:eq_idx].strip()
    print("key found:", key)
    var content = parse_value(file_content, idx=eq_idx)
    print("content:", content)
    idx = eq_idx  # eq_idx gets modified by parse_value func
    return key, content^


fn parse_table[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int) -> TomlType[o]:
    # Clean start
    var i_content = TomlType[o].Table()

    # The only possibility to stop is to find another table or table list
    var end_of_table = full_content.find("\n[", char_idx)
    print("end of table found in idx:", end_of_table)

    while char_idx < end_of_table:
        print("Parsing table content on line:", char_idx)
        var next_jump = full_content.find("\n", char_idx)
        # Do Parsing
        if full_content[char_idx:next_jump].strip() == "":
            print("empty line. skipping...")
            char_idx = next_jump + 1
            continue

        if kv := try_get_kv_pair(full_content, idx=char_idx):
            var kv = kv.take()
            print("store kv pair content", kv[0])
            i_content[kv[0]] = UnsafePointer(to=kv[1])
            continue

        os.abort("This should not happen.!")

    char_idx = end_of_table + 1
    return TomlType[o](i_content^)


fn try_get_table_list[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int) -> Optional[
    Tuple[StringSlice[o], TomlType[o]]
]:
    var i = full_content.find("[[", char_idx)
    var l = full_content.find("]]", char_idx)

    if i != char_idx:
        print(
            (
                "no table list. table open bracket should be the first"
                " character. expected:"
            ),
            char_idx,
            ", got:",
            i,
        )
        return None
    if l == -1 or full_content.as_bytes()[l + 1] != ord("\n"):
        print(
            "no table list. table close bracket should be the last character in"
            " line."
        )
        return None

    var key = full_content[i + 2 : l]
    print("table list key found:", key)
    char_idx += l + 2

    var i_content = parse_table(full_content, char_idx)

    return key, i_content^


fn try_get_table[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int) -> Optional[
    Tuple[StringSlice[o], TomlType[o]]
]:
    var i = full_content.find("[", char_idx)
    var l = full_content.find("]", char_idx)

    if i != char_idx:
        print(
            (
                "no table. table open bracket should be the first character."
                " expected:"
            ),
            char_idx,
            ", got:",
            i,
        )
        return None
    if l == -1 or full_content.as_bytes()[l + 1] != ord("\n"):
        print(
            "no table. table close bracket should be the last character in"
            " line."
        )
        return None

    var key = full_content[i + 1 : l]
    print("table key found:", key)
    char_idx += l + 2

    var i_content = parse_table(full_content, char_idx)

    return key, i_content^


fn parse_toml(content: StringSlice) -> TomlType[content.origin]:
    # var lines = content.splitlines()
    var idx = 0
    # var content_len = len(content)

    var base = TomlType[content.origin].OpaqueTable()
    # We will parse the file sequentially, building the type on the way.

    while (nidx := content.find("\n", idx)) != -1:
        print(
            "on line",
            content[idx:nidx],
            ", and idx span: (",
            idx,
            ",",
            nidx,
            ")",
        )

        # var line = content[idx:nidx]

        # if whitespace, skip line
        if content[idx:nidx].strip() == "":
            idx += nidx + 1
            continue

        # First, find key,value pairs
        print("try to get kv pair")
        if kv := try_get_kv_pair(content, idx):
            var kv = kv.take()
            print("store kv pair content", kv[0])
            print("key is:", kv[0])
            print("value is:", kv[1])
            base = update_base_with_kv_table(kv[0], kv[1], base^)
            print("parsing kv done, moving to ", idx + 1, "...")
            idx += 1
            continue
        print("No kv pair. continue")

        # if there is no key, value, then try to get a table list.
        print("try to get table list")
        if kv := try_get_table_list(content, idx):
            var kv = kv.take()
            print("store table list content", kv[0])
            base = update_base_with_kv_list(kv[0], kv[1], base^)
            print("parsing table list done, moving to ", idx + 1, "...")
            idx += 1
            continue
        print("no table list, continue")

        print("try to get table")
        if kv := try_get_table(content, idx):
            var kv = kv.take()
            print("store table content", kv[0])
            base = update_base_with_kv_table(kv[0], kv[1], base^)
            print("parsing table done, moving to ", idx + 1, "...")
            idx += 1
            continue
        print("no table. Abort")

        os.abort(
            "This is wrong! This should not happen!. Nothing to parse or rules"
            " doesn't catch this"
        )

    return TomlType[content.origin](base^, explicitly_constructed=())


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

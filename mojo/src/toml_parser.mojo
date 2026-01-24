"""
Rules:
Dotted keys, can create a dictionary grouping the values.
"""

from utils import Variant
from builtin.builtin_slice import ContiguousSlice
from memory import OwnedPointer
import os

comptime Slicer = ContiguousSlice


struct CollectionType(Equatable, Writable):
    var inner: StaticString

    @implicit
    fn __init__(out self, v: type_of("table")):
        self.inner = v

    @implicit
    fn __init__(out self, v: type_of("array")):
        self.inner = v


struct TomlType[o: ImmutOrigin](Movable, Writable):
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool
    # comptime Array = List[Self.Ptr]
    # comptime Table = Dict[StringSlice[Self.o], Self.Ptr]

    # Store a list of addesses.
    comptime OpaqueArray = List[Self.Opq]
    comptime OpaqueTable = Dict[StringSlice[Self.o], Self.Opq]

    comptime Opq = MutOpaquePointer[MutAnyOrigin]

    var inner: AnyTomlType[Self.o]

    @staticmethod
    fn from_addr(addr: Self.Opq) -> ref [MutAnyOrigin] Self:
        return addr.bitcast[Self]()[]

    fn to_addr(var self) -> Self.Opq:
        var ptr = UnsafePointer[Self, MutAnyOrigin]()
        ptr.init_pointee_move(self^)
        return ptr.bitcast[NoneType]()

    @staticmethod
    fn new_array(out self: Self):
        self = Self(Self.OpaqueArray())

    @staticmethod
    fn new_table(out self: Self):
        self = Self(Self.OpaqueTable())

    fn as_table(ref self) -> ref [self.inner] Self.OpaqueTable:
        return self.inner[Self.OpaqueTable]

    fn as_array(ref self) -> ref [self.inner] Self.OpaqueArray:
        return self.inner[Self.OpaqueArray]

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

    fn __init__(out self, var v: Self.OpaqueArray):
        self.inner = v^

    fn __init__(out self, var v: Self.OpaqueTable):
        self.inner = v^

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
            # w.write(array)
            w.write("[")
            for i, v in enumerate(array):
                if i != 0:
                    w.write(", ")
                ref value = Self.from_addr(v)
                w.write(value)
            w.write("]")
        elif inner.isa[self.OpaqueTable]():
            ref table = inner[self.OpaqueTable]
            # w.write(table)
            w.write("{")
            for i, kv in enumerate(table.items()):
                if i != 0:
                    w.write(", ")
                ref value = Self.from_addr(kv.value)
                w.write('"', kv.key, '": ', value)
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


fn parse_inline_collection[
    o: ImmutOrigin, //, collection: CollectionType
](orig_content: StringSlice[o], mut from_char_idx: Int,) -> TomlType[o]:
    var close_char = from_char_idx + 1

    var list_nested = 0
    var table_nested = 0
    var string_nested = 0
    var multistring_nested = 0

    var cip = close_char
    var ci = close_char
    var bts = orig_content.as_bytes()

    print("start parsing", collection.inner, "at:", ci, end="\t -> `")

    comptime close_char_byte = ord("]" if collection == "array" else "}")
    var objs = (
        TomlType[o].new_array() if collection.inner
        == "array" else TomlType[o].new_table()
    )
    print("!! new", collection.inner, "with repr:", objs)

    while not (
        (b := bts[ci]) == close_char_byte
        and list_nested + table_nested + string_nested + multistring_nested == 0
    ):
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
                " ->> object found in the ",
                collection.inner,
                " collection: '",
                obj_str,
                "'",
                # " in between ",
                # cip,
                # " and ",
                # ci,
                sep="",
            )
            var _lidx = 0

            @parameter
            if collection == "array":
                var toml_obj = parse_value(obj_str, _lidx)
                print("\n\tparsed_value: '", toml_obj, "'", sep="")
                objs.as_array().append(toml_obj^.to_addr())
            elif collection == "table":
                var s = Slicer(0, 0, None)  # gets modified by next fn
                var value = try_get_kv_pair(obj_str, _lidx, s)
                var toml_obj = value.take()
                var kk = obj_str[s]
                update_base_with_kv["table"](kk, toml_obj^, objs)

            print("continue with", collection.inner, "parsing...", end=" -> ")
            cip = ci + 1
        ci += 1

    print(chr(Int(bts[ci])))

    var obj_str = orig_content[cip:ci]

    # Will potentially fail if there is a trailing comma
    print(
        " ->> last object found in the ",
        collection.inner,
        " collection: '",
        obj_str,
        "'",
        # " in between ",
        # cip,
        # " and ",
        # ci,
        sep="",
    )
    var _lidx = 0

    @parameter
    if collection == "array":
        var toml_obj = parse_value(obj_str, _lidx)
        print("\n\tparsed_value: '", toml_obj, "'", sep="")
        objs.as_array().append(toml_obj^.to_addr())
    elif collection == "table":
        var s = Slicer(0, 0, None)  # gets modified by next fn
        var value = try_get_kv_pair(obj_str, _lidx, s)
        var toml_obj = value.take()
        var kk = obj_str[s]
        update_base_with_kv["table"](kk, toml_obj^, objs)

    from_char_idx = ci + 1
    print("end at:", ci + 1)
    print("display", collection.inner, "collection parsed:", objs)
    return objs^


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
            "Parsing multiline string: '''\n",
            file_content[multiline_string_start : multiline_string_start + 20],
            "...\n'''",
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
            "parsing linine list: '''\n",
            file_content[list_start : list_start + 20],
            "...\n'''",
        )
        content = parse_inline_collection["array"](
            file_content, from_char_idx=list_start
        )
        idx = list_start

    elif is_before(table_start, list_start):
        print(
            "parsing inline table: '''\n",
            file_content[table_start : table_start + 20],
            "...\n'''",
        )
        content = parse_inline_collection["table"](
            file_content, from_char_idx=table_start
        )
        idx = list_start

    else:
        var eol = file_content.find("\n", idx + 1)
        # TODO: Check this...
        eol = len(file_content) if eol == -1 else eol
        var cnt = file_content[idx:eol]
        print("infer type for all: '", cnt, "'", sep="")
        content = string_to_type(cnt)
        idx = eol + 1

    return content^


# @no_inline
# fn opaque_table_repr[o: ImmutOrigin](ref tb: TomlType[o].OpaqueTable) -> String:
#     var s = String("{")
#     for i, kv in enumerate(tb.items()):
#         if i != 0:
#             s.write(", ")
#         ref k = kv.key
#         ref v = TomlType[o].from_addr(kv.value)
#         s.write(k, ": ", v)
#     s.write("}")
#     return s


fn update_base_with_kv[
    o: ImmutOrigin, //, collection: CollectionType
](key: StringSlice[o], var value: TomlType[o], mut base: TomlType[o]):
    var keys = key.split(".")

    if len(keys) == 1:
        var value_repr = String(value)
        var value_addr = value^.to_addr()
        print(
            "Setting unique key:",
            key,
            "to store obj",
            value_repr,
            "with addr",
            Int(value_addr),
        )

        @parameter
        if collection == "table":
            _ = base.as_table().setdefault(key, value_addr)
        elif collection == "array":
            var default_array = TomlType[o].new_array()
            var def_array_addr = default_array^.to_addr()
            var addr = base.as_table().setdefault(key, def_array_addr)
            ref new_base_ptr = TomlType[o].from_addr(addr)
            print(
                "^^ using",
                "obj",
                new_base_ptr,
                "as container with addr",
                Int(addr),
            )
            new_base_ptr.as_array().append(value_addr)
        return

    var first_key = keys[0]

    var rest = key[len(first_key) + 1 :]
    var default_tb = TomlType[o].new_table()

    var default_tb_addr = default_tb^.to_addr()
    var new_base_ptr = base.as_table().setdefault(first_key, default_tb_addr)
    ref new_base = TomlType[o].from_addr(new_base_ptr)
    print(
        "^^ using",
        "obj",
        # new_base,
        "as container with addr",
        Int(new_base_ptr),
    )
    update_base_with_kv[collection](rest, value^, new_base)


fn try_get_kv_pair[
    o: ImmutOrigin
](file_content: StringSlice[o], mut idx: Int, mut s: Slicer) -> Optional[
    TomlType[o]
]:
    if file_content.as_bytes()[idx] in [Byte(ord("[")), Byte(ord("{"))]:
        return None

    if (eq_idx := file_content.find("=", idx + 1)) == -1:
        return None

    s = ContiguousSlice(idx, eq_idx, None)
    # var key = file_content[idx:eq_idx].strip()
    print("key found: '", file_content[s].strip(), "'", sep="")
    eq_idx += 1
    print("value found: '", file_content[eq_idx : eq_idx + 20], "...'", sep="")
    print("Parsing value into toml...")
    var content = parse_value(file_content, idx=eq_idx)
    print("Parsing done! Result:", content)
    idx = eq_idx  # eq_idx gets modified by parse_value func
    return content^


fn parse_table[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int) -> TomlType[o]:
    # Clean start
    var i_content = TomlType[o].new_table()

    # The only possibility to stop is to find another table or table list
    var end_of_table = full_content.find("\n[", char_idx)
    print("end of table found in idx:", end_of_table)
    print(
        "possible table span: '''\n",
        full_content[char_idx:end_of_table],
        "\n'''",
        sep="",
    )

    var s = Slicer(0, 0, None)
    while char_idx < end_of_table:
        print("Parsing table content on line:", char_idx)
        var next_jump = full_content.find("\n", char_idx)
        # Do Parsing
        if full_content[char_idx:next_jump].strip() == "":
            print("empty line. skipping...")
            char_idx = next_jump + 1
            continue

        if kv := try_get_kv_pair(full_content, idx=char_idx, s=s):
            var toml_obj = kv.take()
            print("store kv pair content", full_content[s])
            update_base_with_kv["table"](full_content[s], toml_obj^, i_content)
            continue

        os.abort("Unable to classify table content!")

    char_idx = end_of_table + 1
    return i_content^


fn try_get_table_list[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int, mut s: Slicer) -> Optional[
    TomlType[o]
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

    # var key = full_content[i + 2 : l]
    s = Slicer(i + 2, l, None)
    print("table list key found:", full_content[s])
    char_idx += l + 2

    var i_content = parse_table(full_content, char_idx)

    return i_content^


fn try_get_table[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int, mut s: Slicer) -> Optional[
    TomlType[o]
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

    s = Slicer(i + 1, l, None)
    # var key = full_content[i + 1 : l]
    print("table key found:", full_content[s])
    char_idx += l + 2

    var i_content = parse_table(full_content, char_idx)

    return i_content^


fn parse_toml(content: StringSlice) -> TomlType[content.origin]:
    # var lines = content.splitlines()
    var idx = 0
    # var content_len = len(content)

    var base = TomlType[content.origin].new_table()
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
        var s = Slicer(0, 0, None)
        if val := try_get_kv_pair(content, idx, s):
            var toml_obj = val.take()
            print("store kv pair content")
            print("key is:", content[s])
            print("value is:", toml_obj)
            update_base_with_kv["table"](content[s], toml_obj^, base)
            print("parsing kv done, moving to ", idx + 1, "...")
            idx += 1
            continue
        print("No kv pair. continue")

        # if there is no key, value, then try to get a table list.
        print("try to get table list")
        if val := try_get_table_list(content, idx, s):
            var toml_obj = val.take()
            print("store table list content", content[s])
            update_base_with_kv["table"](content[s], toml_obj^, base)
            print("parsing table list done, moving to ", idx + 1, "...")
            idx += 1
            continue
        print("no table list, continue")

        print("try to get table")
        if val := try_get_table(content, idx, s):
            var toml_obj = val.take()
            print("store table content", content[s])
            update_base_with_kv["table"](content[s], toml_obj^, base)
            print("parsing table done, moving to ", idx + 1, "...")
            idx += 1
            continue
        print("no table. Abort")

        os.abort(
            "This is wrong! This should not happen!. Nothing to parse or rules"
            " doesn't catch this"
        )

    return base^


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

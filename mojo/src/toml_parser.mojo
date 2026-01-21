"""
Rules:
Dotted keys, can create a dictionary grouping the values.
"""

from utils import Variant
import os

comptime Date = String
comptime OffsetDateTime = String
comptime LocalDateTime = String
comptime Time = String


@fieldwise_init("implicit")
struct TomlError:
    comptime UnsecifiedKey: Self = 1
    comptime NeedEOFAfterKey: Self = 2
    comptime NoKeyBeforeEqual: Self = 3
    comptime MultilineKeyNotAllowed: Self = 4
    comptime DuplicatedKey: Self = 5

    var value: Int


@fieldwise_init("implicit")
struct TomlWarning:
    comptime KeyIsEmpty: Self = 1
    comptime SpaceAfterDot: Self = 2

    var value: Int


struct TomlType[o: ImmutOrigin](Movable, Writable):
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool
    comptime OffsetDateTime = OffsetDateTime
    comptime LocalDateTime = LocalDateTime
    comptime Date = Date
    comptime Time = Time
    comptime Array = List[MutOpaquePointer[MutAnyOrigin]]
    comptime Table = Dict[StringSlice[Self.o], MutOpaquePointer[MutAnyOrigin]]

    var inner: AnyTomlType[Self.o]

    fn __init__(out self, var v: AnyTomlType[Self.o]):
        self.inner = v

    fn write_to(self, mut w: Some[Writer]):
        ref anytype = self.inner
        if anytype.isa[self.String]():
            w.write('String("', anytype[self.String], '")')
        elif anytype.isa[self.Integer]():
            w.write("Integer(", anytype[self.Integer], ")")
        elif anytype.isa[self.Float]():
            w.write("Float(", anytype[self.Float], ")")
        elif anytype.isa[self.Boolean]():
            w.write("Boolean(", anytype[self.Boolean], ")")
        elif anytype.isa[self.OffsetDateTime]():
            w.write("OffsetDateTime(", anytype[self.OffsetDateTime], ")")
        elif anytype.isa[self.LocalDateTime]():
            w.write("LocalDateTime(", anytype[self.LocalDateTime], ")")
        elif anytype.isa[self.Date]():
            w.write("Date(", anytype[self.Date], ")")
        elif anytype.isa[self.Time]():
            w.write("Time(", anytype[self.Time], ")")

        elif anytype.isa[self.Array]():
            w.write("[")
            ref v = anytype[self.Array]
            for vi in v:
                w.write(vi.bitcast[TomlType[Self.o]]()[], ",")
            w.write("]")

        elif anytype.isa[self.Table]():
            w.write("{")
            ref v = anytype[self.Table]
            for vi in v.items():
                w.write(
                    '"',
                    vi.key,
                    '": ',
                    vi.value.bitcast[TomlType[Self.o]]()[],
                    ", ",
                )
            w.write("}")

        else:
            os.abort("no type found to be represented.")


comptime AnyTomlType[o: ImmutOrigin] = Variant[
    TomlType[o].String,
    TomlType[o].Integer,
    TomlType[o].Float,
    TomlType[o].Boolean,
    TomlType[o].OffsetDateTime,
    TomlType[o].LocalDateTime,
    TomlType[o].Date,
    TomlType[o].Time,
    TomlType[o].Array,
    TomlType[o].Table,
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
    var final_content = AnyTomlType[o](content[idx + 1 : char_end])
    return TomlType[o](final_content)


fn parse_string[
    o: ImmutOrigin
](content: StringSlice[o], from_char_idx: Int) -> TomlType[o]:
    var close_char = from_char_idx + 1

    while (scape_idx := content.find('/"', close_char)) != -1:
        close_char = scape_idx + 1

    char_end = content.find('"', close_char)
    var final_content = AnyTomlType[o](content[from_char_idx + 1 : char_end])
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

    # print(chr(Int(bts[ci])), end="")

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
            objs[kk] = UnsafePointer(to=toml_obj).bitcast[NoneType]()
            cip = ci + 1
        ci += 1

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
    objs[kk] = UnsafePointer(to=toml_obj).bitcast[NoneType]()

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
            objs.append(UnsafePointer(to=toml_obj).bitcast[NoneType]())
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
    objs.append(UnsafePointer(to=toml_obj).bitcast[NoneType]())

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

    return TomlType[o](TomlType[o].OffsetDateTime(str_value))


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
            "Parsing multiline string:", file_content[multiline_string_start:]
        )
        content = parse_multiline_string(
            file_content, idx=multiline_string_start
        )
        idx = multiline_string_start

    elif is_before(string_start, list_start, table_start):
        print("parsing string:", file_content[string_start:])
        content = parse_string(file_content, from_char_idx=string_start)
        idx = multiline_string_start

    elif is_before(list_start, table_start):
        print("parsing linine list:", file_content[list_start:])
        content = parse_inline_list(file_content, from_char_idx=list_start)
        idx = list_start

    elif is_before(table_start, list_start):
        print("parsing inline table:", file_content[table_start:])
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


fn update_base_with_kv[
    o: ImmutOrigin, mode: String = "table"
](
    key: StringSlice[o], mut value: TomlType[o], var base: TomlType[o].Table
) -> TomlType[o].Table:
    var keys = key.split(".")

    # normalize base into a AnyTomlType
    var toml_base = AnyTomlType[o](base^)
    var most_inner_table = Pointer[origin=MutAnyOrigin](to=toml_base)

    for key in keys[: len(keys) - 1]:  # leave the last one to the end.
        var new_tb = TomlType[o](TomlType[o].Table())
        ref val = most_inner_table[][TomlType[o].Table].setdefault(
            key, UnsafePointer(to=new_tb).bitcast[NoneType]()
        )
        most_inner_table = Pointer[origin=MutAnyOrigin](
            to=val.bitcast[TomlType[o]]()[].inner
        )

    # Pass the value into
    ref most_inner = most_inner_table[][TomlType[o].Table]
    ref last_key = keys[len(keys) - 1]

    @parameter
    if mode == "array":
        var new_array = TomlType[o](TomlType[o].Array())
        ref toml_array = most_inner.setdefault(
            last_key, UnsafePointer(to=new_array).bitcast[NoneType]()
        )
        toml_array.bitcast[TomlType[o]]()[].inner[TomlType[o].Array].append(
            UnsafePointer(to=value).bitcast[NoneType]()
        )
    else:
        if last_key in most_inner:
            os.abort("Key already defined within the toml file.")
        most_inner[last_key] = UnsafePointer(to=value).bitcast[NoneType]()

    # Return the base with nested results.
    return toml_base.take[TomlType[o].Table]()


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
            char_idx = next_jump + 1
            continue

        if kv := try_get_kv_pair(full_content, idx=char_idx):
            var kv = kv.take()
            i_content[kv[0]] = UnsafePointer(to=kv[1]).bitcast[NoneType]()
            continue

        os.abort("This should not happen.!")

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
            "table open bracket should be the first character. expected:",
            char_idx,
            ", got:",
            i,
        )
        return None
    if l == -1 or full_content.as_bytes()[l + 1] != ord("\n"):
        print("table close bracket should be the last character in line.")
        return None

    var key = full_content[i + 2 : l]
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
            "table open bracket should be the first character. expected:",
            char_idx,
            ", got:",
            i,
        )
        return None
    if l == -1 or full_content.as_bytes()[l + 1] != ord("\n"):
        print("table close bracket should be the last character in line.")
        return None

    var key = full_content[i + 2 : l]
    char_idx += l + 2

    var i_content = parse_table(full_content, char_idx)

    return key, i_content^


fn parse_toml(content: StringSlice) -> TomlType[content.origin]:
    # var lines = content.splitlines()
    var idx = 0
    # var content_len = len(content)

    var base = TomlType[content.origin].Table()
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
        if kv := try_get_kv_pair(content, idx):
            print("parsing kv pair")
            var kv = kv.take()
            print("key is:", kv[0])
            print("value is:", kv[1])
            base = update_base_with_kv(kv[0], kv[1], base^)
            print("parsing kv done, moving to ", idx, "...")
            idx += 1
            continue
        print("No kv pair. continue")

        # if there is no key, value, then try to get a table list.
        if kv := try_get_table_list(content, idx):
            print("parsing table list")
            var kv = kv.take()
            base = update_base_with_kv[mode="array"](kv[0], kv[1], base^)
            idx += 1
            continue
        print("no table list, continue")

        if kv := try_get_table(content, idx):
            print("parse table")
            var kv = kv.take()
            base = update_base_with_kv(kv[0], kv[1], base^)
            idx += 1
            continue
        print("no table. Abort")

        os.abort(
            "This is wrong! This should not happen!. Nothing to parse or rules"
            " doesn't catch this"
        )

    return TomlType[content.origin](base^)


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

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


struct TomlError:
    comptime UnspecifiedKey = 1
    comptime NeedEOFAfterKey = 2
    comptime NoKeyBeforeEqual = 3
    comptime MultilineKeyNotAllowed = 4
    comptime DuplicatedKey = 5


struct TomlWarning:
    comptime KeyIsEmpty = 1
    comptime SpaceAfterDot = 2


# @fieldwise_init
# struct Array[T: Copyable](Copyable):
#     var inner: List[Self.T]


# @fieldwise_init
# struct Table[V: Copyable & ImplicitlyDestructible](Copyable):
#     var inner: Dict[String, Self.V]


@fieldwise_init
struct TomlType[o: ImmutOrigin](Copyable & ImplicitlyDestructible):
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool
    comptime OffsetDateTime = OffsetDateTime
    comptime LocalDateTime = LocalDateTime
    comptime Date = Date
    comptime Time = Time
    comptime Array = List[TomlType[Self.o]]
    comptime Table = Dict[StringSlice[Self.o], TomlType[Self.o]]

    var inner: AnyTomlType[Self.o]


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
](
    orig_content: StringSlice[o],
    lines: List[StringSlice[o]],
    mut line_idx: Int,
    var from_char_idx: Int,
) -> TomlType[o]:
    ref line = lines[line_idx]
    from_char_idx = get_absolute_idx(orig_content, line_idx, from_char_idx)

    var close_char = from_char_idx + 3

    while (scape_idx := line.find('/"', close_char)) != -1:
        close_char = scape_idx + 1

    char_end = line.find('"""', close_char)
    return TomlType[o](orig_content[from_char_idx + 1 : char_end])


fn parse_string[
    o: ImmutOrigin
](line: StringSlice[o], from_char_idx: Int) -> TomlType[o]:
    var close_char = from_char_idx + 1

    while (scape_idx := line.find('/"', close_char)) != -1:
        close_char = scape_idx + 1

    char_end = line.find('"', close_char)
    return TomlType[o](line[from_char_idx + 1 : char_end])


fn parse_inline_table[
    o: ImmutOrigin
](
    orig_content: StringSlice[o],
    # lines: List[StringSlice[o]],
    mut line_idx: Int,
    var from_char_idx: Int,
) -> TomlType[o]:
    from_char_idx = get_absolute_idx(orig_content, line_idx, from_char_idx)

    var close_char = from_char_idx + 1

    var list_nested = 0
    var table_nested = 0
    var string_nested = 0
    var multistring_nested = 0

    var cip = close_char
    var ci = close_char
    var bts = orig_content.as_bytes()
    var objs = TomlType[o].Table()

    while (b := bts[ci]) != ord(
        "}"
    ) and list_nested + table_nested + string_nested + multistring_nested == 0:
        if b == ord('"'):
            if bts[ci + 1] == ord('"') and bts[ci + 2] == ord('"'):
                if multistring_nested == 1 and bts[ci - 1] != ord("\\"):
                    multistring_nested -= 1
                else:
                    multistring_nested += 1
                ci += 3
                continue

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
            var obj_str = orig_content[cip:ci].strip()
            var eq_idx = obj_str.find("=")
            var kk = obj_str[:eq_idx].strip()
            var val = obj_str[eq_idx + 1 :].strip()
            var _lidx = 0
            var toml_obj = parse_value(val, val.splitlines(), _lidx, 0)
            objs[kk] = toml_obj^
            cip = ci + 1
        ci += 1

        var obj_str = orig_content[cip:ci].strip()
        var eq_idx = obj_str.find("=")
        var kk = obj_str[:eq_idx].strip()
        var val = obj_str[eq_idx + 1 :].strip()
        var _lidx = 0
        var toml_obj = parse_value(val, val.splitlines(), _lidx, 0)
        objs[kk] = toml_obj^

    return TomlType[o](objs^)


fn parse_inline_list[
    o: ImmutOrigin
](
    orig_content: StringSlice[o],
    # lines: List[StringSlice[o]],
    mut line_idx: Int,
    var from_char_idx: Int,
) -> TomlType[o]:
    # ref line = lines[line_idx]
    from_char_idx = get_absolute_idx(orig_content, line_idx, from_char_idx)

    var close_char = from_char_idx + 1

    var list_nested = 0
    var table_nested = 0
    var string_nested = 0
    var multistring_nested = 0

    var cip = close_char
    var ci = close_char
    var bts = orig_content.as_bytes()
    var objs = List[TomlType[o]]()

    while (b := bts[ci]) != ord(
        "]"
    ) and list_nested + table_nested + string_nested + multistring_nested == 0:
        if b == ord('"'):
            if bts[ci + 1] == ord('"') and bts[ci + 2] == ord('"'):
                if multistring_nested == 1 and bts[ci - 1] != ord("\\"):
                    multistring_nested -= 1
                else:
                    multistring_nested += 1
                ci += 3
                continue

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
            var obj_str = orig_content[cip:ci].strip()
            var _lidx = 0
            var toml_obj = parse_value(obj_str, obj_str.splitlines(), _lidx, 0)
            objs.append(toml_obj^)
            cip = ci + 1
        ci += 1

    var obj_str = orig_content[cip:ci]
    var _lidx = 0
    var toml_obj = parse_value(obj_str, obj_str.splitlines(), _lidx, 0)
    objs.append(toml_obj^)

    return TomlType[o](objs^)


fn string_to_type[o: ImmutOrigin](str_value: StringSlice[o]) -> TomlType[o]:
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


fn parse_value[
    o: ImmutOrigin
](
    full_content: StringSlice[o],
    lines: List[StringSlice[o]],
    mut line_idx: Int,
    from_char_idx: Int,
) -> TomlType[o]:
    ref line_i = lines[line_idx]
    var multiline_string_start = line_i.find('"""', from_char_idx)
    var string_start = line_i.find('"', from_char_idx)
    var list_start = line_i.find("[", from_char_idx)
    var table_start = line_i.find("{", from_char_idx)

    var content: TomlType[o]
    if multiline_string_start < min(list_start, table_start):
        content = parse_multiline_string(
            full_content,
            lines,
            line_idx=line_idx,
            from_char_idx=multiline_string_start,
        )
    elif string_start < min(list_start, table_start):
        content = parse_string(
            line_i,
            from_char_idx=multiline_string_start,
        )
    elif list_start < table_start:
        content = parse_inline_list(
            full_content, line_idx=line_idx, from_char_idx=list_start
        )
    elif table_start < list_start:
        content = parse_inline_table(
            full_content, line_idx=line_idx, from_char_idx=list_start
        )
    else:
        content = string_to_type(line_i[from_char_idx:])

    return content^


fn update_base_with_kv[
    o: ImmutOrigin, mode: String = "table"
](
    key: StringSlice[o], var value: TomlType[o], var base: TomlType[o].Table
) -> TomlType[o].Table:
    var keys = key.split(".")

    # normalize base into a AnyTomlType
    var toml_base = AnyTomlType[o](base^)
    var most_inner_table = Pointer[origin=MutAnyOrigin](to=toml_base)

    for key in keys[: len(keys) - 1]:  # leave the last one to the end.
        ref val = most_inner_table[][TomlType[o].Table].setdefault(
            key, TomlType[o](TomlType[o].Table())
        )
        most_inner_table = Pointer(to=val.inner)

    # Pass the value into
    ref most_inner = most_inner_table[][TomlType[o].Table]
    ref last_key = keys[len(keys) - 1]

    @parameter
    if mode == "array":
        ref toml_array = most_inner.setdefault(
            last_key, TomlType[o](TomlType[o].Array())
        )
        toml_array.inner[TomlType[o].Array].append(value^)
    else:
        if last_key in most_inner:
            os.abort("Key already defined within the toml file.")
        most_inner[last_key] = value^

    # Return the base with nested results.
    return toml_base.take[TomlType[o].Table]()


fn try_get_kv_pair[
    o: ImmutOrigin
](
    full_content: StringSlice[o], lines: List[StringSlice[o]], mut line_idx: Int
) -> Optional[Tuple[StringSlice[o], TomlType[o]]]:
    ref line = lines[line_idx]
    if (eq_idx := line.find("=")) == -1:
        return None

    var key = line[:eq_idx].strip()
    var content = parse_value(
        full_content, lines, line_idx=line_idx, from_char_idx=eq_idx + 1
    )
    return key, content^


fn try_get_table_list[
    o: ImmutOrigin
](
    full_content: StringSlice[o], lines: List[StringSlice[o]], mut line_idx: Int
) -> Optional[Tuple[StringSlice[o], TomlType[o]]]:
    ref line = lines[line_idx]

    var i = line.find("[[")
    var l = line.find("]]")

    if i != 0:
        return None
    if l != len(line) - 1:
        return None

    var key = line[2:l]
    line_idx += 1
    var i_content = TomlType[o].Table()

    # The only possibility to stop is to find another table or table list
    while (line_i := lines[line_idx]).find("[") != 0:
        # Do Parsing
        if line_i.strip() == "":
            line_idx += 1
            continue

        if kv := try_get_kv_pair(full_content, lines, line_idx=line_idx):
            ref k, value = kv.unsafe_take()
            i_content[k] = value.copy()
            line_idx += 1
            continue

        os.abort("This should not happen.!")

    return key, TomlType[o](i_content^)


fn try_get_table[
    o: ImmutOrigin
](
    full_content: StringSlice[o], lines: List[StringSlice[o]], mut line_idx: Int
) -> Optional[Tuple[StringSlice[o], TomlType[o]]]:
    ref line = lines[line_idx]

    var i = line.find("[")
    var l = line.find("]")
    if i != 0:
        return None
    if l != len(line) - 1:
        return None

    var key = line[1:l]
    line_idx += 1
    var i_content = TomlType[o].Table()

    # The only possibility to stop is to find another table or table list
    while (line_i := lines[line_idx]).find("[") != 0:
        # Do Parsing
        if line_i.strip() == "":
            line_idx += 1
            continue

        if kv := try_get_kv_pair(full_content, lines, line_idx=line_idx):
            ref k, value = kv.unsafe_take()
            i_content[k] = value.copy()
            line_idx += 1
            continue

        os.abort("This should not happen.!")

    return key, TomlType[o](i_content^)


fn parse_toml(content: StringSlice) raises -> TomlType[content.origin].Table:
    # var lines = content.splitlines()
    var idx = 0
    var content_len = len(content)

    var base = TomlType[content.origin].Table()
    # We will parse the file sequentially, building the type on the way.
    while nidx := content.find("\n", idx):
        var line = content[idx:nidx]

        # if whitespace, skip line
        if line.strip() == "":
            idx += nidx + 1
            continue

        # First, find key,value pairs
        if kv := try_get_kv_pair(content, lines, idx):
            ref key, value = kv.value()
            base = update_base_with_kv(key, value.copy(), base^)
            idx += 1
            continue

        # if there is no key, value, then try to get a table list.
        if kv := try_get_table_list(content, lines, idx):
            ref key, value = kv.value()
            base = update_base_with_kv[mode="array"](key, value.copy(), base^)
            idx += 1
            continue

        if kv := try_get_table(content, lines, idx):
            ref key, value = kv.value()
            base = update_base_with_kv(key, value.copy(), base^)
            idx += 1
            continue

        os.abort(
            "This is wrong! This should not happen!. Nothing to parse or rules"
            " doesn't catch this"
        )

    return base^

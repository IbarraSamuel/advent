"""
Rules:
Dotted keys, can create a dictionary grouping the values.
"""

from utils import Variant

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
    comptime Float = Float32
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
    TomlType.Integer,
    TomlType.Float,
    TomlType.Boolean,
    TomlType.OffsetDateTime,
    TomlType.LocalDateTime,
    TomlType.Date,
    TomlType.Time,
    TomlType[o].Array,
    TomlType[o].Table,
]


fn parse_multiline_string[
    o: ImmutOrigin
](
    lines: List[StringSlice[o]], mut line_idx: Int, from_char_idx: Int
) -> TomlType[o]:
    ...


fn parse_table[
    o: ImmutOrigin
](
    lines: List[StringSlice[o]], mut line_idx: Int, from_char_idx: Int
) -> TomlType[o]:
    ...


fn parse_list[
    o: ImmutOrigin
](
    lines: List[StringSlice[o]], mut line_idx: Int, from_char_idx: Int
) -> TomlType[o]:
    ...


fn string_to_type[o: ImmutOrigin](str_value: StringSlice[o]) -> TomlType[o]:
    ...


fn parse_toml(content: StringSlice) raises -> TomlType[content.origin].Table:
    var lines = content.splitlines()
    var content_len = len(lines)

    var base = TomlType[content.origin].Table()
    # We will parse the file sequentially, building the type on the way.
    var idx = 0
    while idx < content_len:
        ref line = lines[idx]

        # First, find key,value pairs
        ...

        # Find tables
        # A table header
        if (i := line.find("[")) == 0:
            if (l := line.find("]")) == len(line) - 1:
                # Next lines should be consider as table content
                var key = TomlType[content.origin].String(line[i + 1 : l])
                idx += 1
                var i_content = TomlType[content.origin].Table()

                # Parse table content. only arrays and tables are allowed, and key, value pairs.
                while (line_i := lines[idx]).find("[") == -1:
                    # Do Parsing
                    var eq_place = line_i.find("=")
                    var kkey_i = line_i[:eq_place].strip()

                    var list_start = line_i.find("[", eq_place + 1)
                    var table_start = line_i.find("{", eq_place + 1)
                    var multiline_string = line_i.find('"""', eq_place + 1)

                    var content: TomlType[content.origin]
                    if (
                        multiline_string < list_start
                        and multiline_string < table_start
                    ):
                        content = parse_multiline_string(
                            lines, line_idx=idx, from_char_idx=multiline_string
                        )
                    elif list_start < table_start:
                        content = parse_list(
                            lines, line_idx=idx, from_char_idx=list_start
                        )
                    elif table_start < list_start:
                        content = parse_table(
                            lines, line_idx=idx, from_char_idx=list_start
                        )
                    else:
                        content = string_to_type(line_i[eq_place:])

                    i_content[kkey_i] = content^
                    idx += 1

                var content_as_toml_type = AnyTomlType[content.origin](
                    i_content^
                )
                base[key] = TomlType[content.origin](content_as_toml_type)

            # The content could be an array of tables, check that out in case that's the value.

        # Continue
        idx += 1

    return base^

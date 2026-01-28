"""
Rules:
Dotted keys, can create a dictionary grouping the values.
"""

from utils import Variant
from sys.intrinsics import _type_is_eq, unlikely, likely
from collections.dict import _DictEntryIter
from builtin.builtin_slice import ContiguousSlice
from memory import OwnedPointer
import os

comptime SquareBracketOpen = ord("[")
comptime SquareBracketClose = ord("]")
comptime CurlyBracketOpen = ord("{")
comptime CurlyBracketClose = ord("}")

comptime NewLine = ord("\n")
comptime Space = ord(" ")

comptime Comma = ord(",")
comptime Equal = ord("=")
comptime Period = ord(".")

comptime Quote = ord('"')
comptime Escape = ord("\\")

# comptime EmptyChars = (Space, NewLine)
comptime CollectionOpenChars = (SquareBracketOpen, CurlyBracketOpen)


@fieldwise_init("implicit")
struct TomlException(TrivialRegisterType, Writable):
    comptime UnexpectedCharacter = TomlException("Unexpected Character")
    var value: StaticString

    @staticmethod
    fn idx_to_coord(abs_idx: Int, content: StringSlice) -> Tuple[Int, Int]:
        var internal_abs_idx = 0
        var lines = content.splitlines()
        for y_pos, line in enumerate(lines):
            if internal_abs_idx + len(line) >= abs_idx:
                return abs_idx - internal_abs_idx, y_pos
            internal_abs_idx += len(line)

        return 0, 0


struct CollectionType[_v: __mlir_type.`!kgen.string`](
    Equatable, TrivialRegisterType  # , Writable
):
    comptime inner = StringLiteral[Self._v]()

    @implicit
    fn __init__(out self: CollectionType[v.value], v: type_of("table")):
        pass

    @implicit
    fn __init__(out self: CollectionType[v.value], v: type_of("array")):
        pass

    @implicit
    fn __init__(out self: CollectionType[v.value], v: type_of("plain")):
        pass

    fn __eq__(self, other: Self) -> Bool:
        return True

    fn __eq__(self, other: CollectionType[...]) -> Bool:
        return self.inner == other.inner

    # fn write_to(self, mut w: Some[Writer]):
    #     w.write(self.inner)


struct TomlRef[inner: ImmutOrigin, toml: ImmutOrigin](
    Iterable, TrivialRegisterType
):
    comptime Toml = TomlType[Self.inner]
    comptime IteratorType[origin: Origin]: Iterator = Self.Toml.IteratorType[
        Self.toml
    ]
    var pointer: Pointer[Self.Toml, Self.toml]

    fn __init__(out self, ref [Self.toml]v: Self.Toml):
        self.pointer = Pointer(to=v)

    fn __getitem__(ref self) -> ref [Self.toml] Self.Toml:
        return self.pointer[]

    fn __getitem__(ref self, idx: Int) -> ref [Self.toml] Self.Toml:
        return self.pointer[][idx]

    fn __getitem__(ref self, key: StringSlice) -> ref [Self.toml] Self.Toml:
        return self.pointer[][key]

    fn __iter__(ref self) -> Self.IteratorType[Self.toml]:
        return self.pointer[].__iter__()


struct TomlListIter[
    toml_origin: Origin,
    toml_inner_origin: Origin,
](Iterator):
    comptime Element = TomlType[Self.toml_inner_origin]
    var pointer: Pointer[Self.Element.OpaqueArray, Self.toml_origin]
    var index: Int

    fn __init__(out self, ref [Self.toml_origin]v: Self.Element.OpaqueArray):
        self.pointer = Pointer(to=v)
        self.index = 0

    fn __next__(
        mut self,
    ) raises StopIteration -> ref [Self.toml_origin] Self.Element:
        if self.index >= len(self.pointer[]):
            raise StopIteration()

        ref elem = self.pointer[][self.index].bitcast[Self.Element]()[]
        self.index += 1
        return elem


struct TomlTableIter[
    toml_origin: ImmutOrigin,
    o: ImmutOrigin,
](ImplicitlyCopyable, Iterable, Iterator):
    comptime Element = Tuple[
        StringSlice[Self.o], TomlRef[Self.o, ImmutExternalOrigin]
    ]
    comptime IteratorType[origin: Origin]: Iterator = Self
    comptime Toml = TomlType[Self.o]
    var pointer: _DictEntryIter[
        mut=False,
        K = Self.Toml.OpaqueTable.K,
        V = Self.Toml.OpaqueTable.V,
        H = Self.Toml.OpaqueTable.H,
        origin = Self.toml_origin,
    ]

    fn __init__(out self, ref [Self.toml_origin]v: Self.Toml.OpaqueTable):
        self.pointer = v.items()

    fn __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        return self.copy()

    fn __next__(
        mut self,
    ) raises StopIteration -> Self.Element:
        ref kv = next(self.pointer)

        ref toml_value = kv.value.bitcast[Self.Toml]()[]
        return kv.key, TomlRef(toml_value)


struct TomlType[o: ImmutOrigin](Copyable, Iterable, Writable):
    comptime Unknown = Span[Byte, Self.o]
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool

    comptime Array = List[Self]
    comptime Table = Dict[Self.String, Self]

    # Store a list of addesses.
    comptime Opaque[o: Origin] = OpaquePointer[o]
    comptime OpaqueArray = List[Self.Opaque[MutExternalOrigin]]
    comptime OpaqueTable = Dict[
        StringSlice[Self.o], Self.Opaque[MutExternalOrigin]
    ]
    comptime RefArray[o: ImmutOrigin] = List[TomlRef[Self.o, o]]
    comptime RefTable[o: ImmutOrigin] = Dict[Self.String, TomlRef[Self.o, o]]

    # Iterable
    comptime IteratorType[
        mut: Bool, //, origin: Origin[mut=mut]
    ] = TomlListIter[origin, Self.o]

    fn __iter__(ref self) -> Self.IteratorType[origin_of(self)]:
        # upcast origin to self.
        ref array = UnsafePointer(
            to=self.inner[Self.OpaqueArray]
        ).unsafe_origin_cast[origin_of(self)]()[]

        return TomlListIter[
            toml_origin = origin_of(self), toml_inner_origin = Self.o
        ](array)

    # Runtime
    var inner: AnyTomlType[Self.o]

    fn isa[T: AnyType](self) -> Bool:
        @parameter
        if _type_is_eq[T, Self.Array]():
            return self.inner.isa[Self.OpaqueArray]()
        elif _type_is_eq[T, Self.Table]():
            return self.inner.isa[Self.OpaqueTable]()
        else:
            return self.inner.isa[T]()

    @staticmethod
    fn from_addr(addr: Self.Opaque[...]) -> ref [addr.origin] Self:
        return addr.bitcast[Self]()[]

    @staticmethod
    fn take_from_addr(var addr: Self.Opaque[MutExternalOrigin]) -> Self:
        return addr.bitcast[Self]().take_pointee()

    fn move_to_addr(var self) -> Self.Opaque[MutExternalOrigin]:
        var ptr = alloc[Self](1)
        ptr.init_pointee_move(self^)
        return ptr.bitcast[NoneType]()

    fn to_addr(ref self) -> Self.Opaque[origin_of(self)]:
        return UnsafePointer(to=self).bitcast[NoneType]()

    @staticmethod
    fn new_array(out self: Self):
        self = Self(Self.OpaqueArray(capacity=64))

    @staticmethod
    fn new_table(out self: Self):
        self = Self(Self.OpaqueTable(power_of_two_initial_capacity=64))

    fn as_opaque_table(ref self) -> ref [self.inner] Self.OpaqueTable:
        return self.inner[Self.OpaqueTable]

    fn as_opaque_array(ref self) -> ref [self.inner] Self.OpaqueArray:
        return self.inner[Self.OpaqueArray]

    # ==== Access inner values using methods ====

    fn string(ref self) -> Self.String:
        return self.inner[Self.String]

    fn integer(ref self) -> Self.Integer:
        return self.inner[Self.Integer]

    fn float(ref self) -> Self.Float:
        return self.inner[Self.Float]

    fn boolean(ref self) -> Self.Boolean:
        return self.inner[Self.Boolean]

    fn to_array(deinit self) -> Self.Array:
        """Points to self, because external origin it's managed by self."""
        return [Self.take_from_addr(it) for it in self.inner[Self.OpaqueArray]]

    fn to_table(deinit self) -> Self.Table:
        """Points to self, because external origin it's managed by self."""
        return {
            kv.key: Self.take_from_addr(kv.value)
            for kv in self.inner[Self.OpaqueTable].items()
        }

    fn array(self) -> Self.RefArray[origin_of(self.inner)]:
        """Points to self, because external origin it's managed by self."""
        return [
            TomlRef[Self.o, origin_of(self.inner)](Self.from_addr(it))
            for it in self.inner[Self.OpaqueArray]
        ]

    fn table(self) -> Self.RefTable[origin_of(self.inner)]:
        """Points to self, because external origin it's managed by self."""
        return {
            kv.key: TomlRef[Self.o, origin_of(self.inner)](
                Self.from_addr(kv.value)
            )
            for kv in self.inner[Self.OpaqueTable].items()
        }

    # For interop with list

    fn __getitem__(ref self, idx: Int) -> ref [self] Self:
        return self.inner[Self.OpaqueArray][idx].bitcast[Self]()[]

    # For interop with dict

    fn __getitem__(ref self, key: StringSlice[...]) -> ref [self] Self:
        ref table = self.inner[Self.OpaqueTable]

        for kv in table.items():
            if kv.key == key:
                return Self.from_addr(kv.value)

        os.abort(String("Key '", key, "' not found in TOML table."))

    fn items(ref self) -> TomlTableIter[origin_of(self.inner), Self.o]:
        return TomlTableIter(self.inner[Self.OpaqueTable])

    fn __init__(out self, *, unknown: Self.Unknown):
        self.inner = unknown

    fn __init__(out self, var v: Self.String):
        self.inner = v

    fn __init__(out self, var v: Self.Integer):
        self.inner = v

    fn __init__(out self, var v: Self.Float):
        self.inner = v

    fn __init__(out self, var v: Self.Boolean):
        self.inner = v

    fn __init__(out self, var v: Self.OpaqueArray):
        self.inner = v^

    fn __init__(out self, var v: Self.OpaqueTable):
        self.inner = v^

    fn __del__(deinit self):
        ref inner = self.inner

        if inner.isa[self.OpaqueArray]():
            ref array = inner[self.OpaqueArray]
            for addr in array:
                addr.free()
        elif inner.isa[self.OpaqueTable]():
            ref table = inner[self.OpaqueTable]
            for v in table.values():
                v.free()

    fn write_to(self, mut w: Some[Writer]):
        ref inner = self.inner

        if inner.isa[self.String]():
            w.write('"', inner[self.String], '"')
        elif inner.isa[self.Integer]():
            w.write(inner[self.Integer])
        elif inner.isa[self.Float]():
            w.write(inner[self.Float])
        elif inner.isa[self.Boolean]():
            w.write("true" if inner[self.Boolean] else "false")
        elif inner.isa[self.OpaqueArray]():
            ref array = inner[self.OpaqueArray]
            w.write("[")
            for i, v in enumerate(array):
                if i != 0:
                    w.write(", ")
                ref value = Self.from_addr(v)
                w.write(value)
            w.write("]")
        elif inner.isa[self.OpaqueTable]():
            ref table = inner[self.OpaqueTable]
            w.write("{")
            for i, kv in enumerate(table.items()):
                if i != 0:
                    w.write(", ")
                ref value = Self.from_addr(kv.value)
                w.write('"', kv.key, '": ', value)
            w.write("}")
        elif inner.isa[self.Unknown]():
            w.write(
                "Unknown(",
                StringSlice(unsafe_from_utf8=inner[self.Unknown]),
                ")",
            )


comptime AnyTomlType[o: ImmutOrigin] = Variant[
    TomlType[o].String,
    TomlType[o].Integer,
    TomlType[o].Float,
    TomlType[o].Boolean,
    TomlType[o].OpaqueArray,
    TomlType[o].OpaqueTable,
    TomlType[o].Unknown,
]


fn parse_multiline_string(
    data: Span[Byte], var idx: Int, out value: Span[Byte, data.origin]
):
    idx += 3
    var value_init = idx

    while not (
        data[idx] == Quote
        and data[idx + 1] == Quote
        and data[idx + 2] == Quote
        and data[idx - 1] != Escape
    ):
        idx += 1

    value = data[value_init:idx]

    idx += 2  # keep on the end of the quote


fn parse_quoted_string(
    data: Span[Byte], mut idx: Int, out value: Span[Byte, data.origin]
):
    idx += 1
    var value_init = idx

    while data[idx] != Quote:
        idx += 1
        if data[idx] == Quote and data[idx - 1] == Escape:
            idx += 1

    value = data[value_init:idx]


fn parse_inline_collection[
    collection: CollectionType
](data: Span[Byte], mut idx: Int, out value: TomlType[data.origin]):
    """Assumes the first char is already within the collection."""
    # print("parse inline collection", collection.inner)
    # comptime ContainerEnd = SquareBracketClose if collection == "array" else CurlyBracketClose

    @parameter
    if collection == "array":
        value = TomlType[data.origin].new_array()
    else:
        value = TomlType[data.origin].new_table()

    # NOTE: Useless but we might need to bring it back
    # while data[idx] == Space:
    #     idx += 1

    # We should be at the start of the inner value.
    # Could not be triple quoted.
    @parameter
    if collection == "table":
        parse_and_update_kv_pairs[separator=Comma, end_char=CurlyBracketClose](
            data, idx, value
        )
        # print("finished table", value)
    elif collection == "array":
        ref arr = value.as_opaque_array()
        # ok to not check constraints because we are already in a list.
        skip[Space, NewLine](data, idx)

        while data[idx] != SquareBracketClose:
            arr.append(
                parse_value[SquareBracketClose](data, idx).move_to_addr()
            )

            # print(
            #     "appended to array:",
            #     arr[len(arr) - 1].bitcast[TomlType[data.origin]]()[],
            # )

            # For both table and array, you need to split by comma
            stop_at[Comma, SquareBracketClose](data, idx)
            if data[idx] == SquareBracketClose:
                break

            # we are at a comma
            idx += 1

            skip[Space, NewLine](data, idx)
            # while data[idx] != Comma:
            #     if data[idx] == ContainerEnd:
            #         break
            #     idx += 1

            # if data[idx] == ContainerEnd:
            #     break

            # idx += 1

            # while data[idx] == NewLine or data[idx] == Space:
            #     idx += 1

    # print(
    #     "finished inline collection",
    #     collection.inner,
    #     "at:",
    #     idx,
    #     "and codepoint:",
    #     Codepoint(data[idx]),
    #     "and collection:",
    #     value,
    # )
    # # print("end of parse value loop. Value is parsed as:", value)


fn string_to_type[
    end_char: Byte
](data: Span[Byte], mut idx: Int, out value: TomlType[data.origin]):
    """Returns end of value + 1."""
    comptime lower, upper = ord("0"), ord("9")
    var init = idx
    var all_is_digit = True
    var has_period = False

    if data[idx : idx + 4] == StringSlice("true").as_bytes():
        # print("-> to bool")
        value = TomlType[data.origin](True)
        idx += 4
        return

    if data[idx : idx + 5] == StringSlice("false").as_bytes():
        # print("-> to bool")
        idx += 5
        value = TomlType[data.origin](False)
        return

    while (
        idx < len(data)
        and data[idx] != end_char
        and data[idx] != NewLine
        and data[idx] != Space
        and data[idx] != Comma
    ):
        if data[idx] == Period and not has_period:
            has_period = True
        else:
            all_is_digit &= data[idx] >= lower and data[idx] <= upper
        idx += 1

    var str_val = StringSlice(unsafe_from_utf8=data[init:idx])
    # print("string to type: `{}`".format(str_val))
    # To keep ending at the end of the values

    if all_is_digit and not has_period:
        # print("-> to int")
        try:
            value = TomlType[data.origin](Int(str_val))
            return
        except:
            pass

    if all_is_digit:
        # print("-> to float")
        try:
            value = TomlType[data.origin](atof(str_val))
            return
        except:
            pass

    # print("-> to unknown")
    return TomlType(unknown=data[init:idx])


fn parse_value[
    end_char: Byte
](data: Span[Byte], mut idx: Int, out value: TomlType[data.origin],):
    # Assumes the first char is the first value of the value to parse.
    if data[idx] == Quote:
        if data[idx + 1] == Quote and data[idx + 2] == Quote:
            var s = parse_multiline_string(data, idx)
            value = TomlType[data.origin](StringSlice(unsafe_from_utf8=s))
        else:
            var s = parse_quoted_string(data, idx)
            value = TomlType[data.origin](StringSlice(unsafe_from_utf8=s))
    elif data[idx] == SquareBracketOpen:
        idx += 1
        value = parse_inline_collection["array"](data, idx)
    elif data[idx] == CurlyBracketOpen:
        idx += 1
        value = parse_inline_collection["table"](data, idx)
    else:
        value = string_to_type[end_char](data, idx)


fn get_or_ref_container[
    collection: CollectionType
](key: Span[Byte], mut base: TomlType[key.origin]) -> ref [base] TomlType[
    key.origin
]:
    str_key = StringSlice[mut=False, key.origin](unsafe_from_utf8=key)
    # print("Setting up key:", str_key)
    var def_addr = (
        base.new_array() if collection == "array" else base.new_table()
    ).move_to_addr()
    ref base_tb = base.as_opaque_table().setdefault(str_key, def_addr)
    return base.from_addr(base_tb)


fn parse_key_span_and_get_container[
    o: Origin, //, collection: CollectionType, close_char: Byte
](
    data: Span[Byte, o],
    mut idx: Int,
    mut base: TomlType[o],
    mut key: Span[Byte, o],
) -> ref [base] TomlType[o]:
    """Assumes that first character is not a space. Ends on close char."""
    var key_init = idx
    if data[idx] == Quote:
        # Ignore quote
        idx += 1

        # its fine to not check len if the toml is formatted
        while data[idx] != Quote:
            idx += 1 + Int(data[idx] == Escape and data[idx + 1] == Quote)

        key = data[key_init + 1 : idx]

        # add one to skip the quote
        stop_at[close_char](data, idx)

    else:
        # not checking len here because good toml should have the close char somewhere
        while data[idx] != close_char and data[idx] != Space:
            if data[idx] == Period:
                key = data[key_init:idx]
                idx += 1
                ref cont = get_or_ref_container["table"](key, base)
                return parse_key_span_and_get_container[collection, close_char](
                    data, idx, cont, key
                )
            idx += 1

    key = data[key_init:idx]
    if data[idx] == Space:
        stop_at[close_char](data, idx)

    # Here we are at close char, so key should be set up

    # For multiline collections, you actually want to use the current base
    if collection == "plain":
        return base

    # For the rest, use the table as the holder of the key.
    return get_or_ref_container[collection](key, base)


fn find_kv_and_update_base[
    end_char: Byte
](data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]):
    var key = data[idx:idx]

    ref tb = parse_key_span_and_get_container["plain", Equal](
        data, idx, base, key
    )

    # It's ended on equal
    idx += 1

    skip[Space](data, idx)

    # we are on the value part
    # var v = parse_value[end_char](data, idx)
    # print(
    #     "setting key: `",
    #     StringSlice(unsafe_from_utf8=key),
    #     "` with value: `",
    #     v,
    #     "`",
    #     sep="",
    # )
    # tb.as_opaque_table()[StringSlice(unsafe_from_utf8=key)] = v^.move_to_addr()
    # print(" ++ Setting done!")
    tb.as_opaque_table()[StringSlice(unsafe_from_utf8=key)] = parse_value[
        CurlyBracketClose
    ](data, idx).move_to_addr()


fn parse_and_update_kv_pairs[
    separator: Byte, end_char: Byte
](data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]):
    """This function ends at the start of a new collection."""
    # print("parse kv pairs at idx:", idx, "and codepoint:", Codepoint(data[idx]))
    while idx < len(data) and data[idx] != end_char:
        # # Skip spaces
        # skip_char[Space](data, idx)

        # we should be at something to parse
        find_kv_and_update_base[end_char=end_char](data, idx, base)
        # ends at idx + 1 of latest value char.
        # print("end kv pair with updated base:", base)
        skip[Space](data, idx)
        stop_at[separator, end_char](data, idx)
        if data[idx] == end_char or idx == len(data):
            break

        # we are at separator
        skip[separator, Space](data, idx)

        # we should be at the start of the next value, or just the end
        # if there is a separator, move to there and goto next loop
    # print(
    #     "No more kv pairs. end at:",
    #     idx,
    #     "and codepoint:",
    #     Codepoint(data[idx]),
    # )
    # Stops at end_char always.


fn parse_and_store_multiline_collection(
    data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]
):
    if data[idx] != SquareBracketOpen:
        os.abort("Not an array or table")

    var is_array = data[idx + 1] == SquareBracketOpen
    idx += 1 + Int(is_array)

    var tb: UnsafePointer[TomlType[data.origin], MutAnyOrigin]
    var key = data[idx:idx]
    # Right away parse the key

    var cont_getter = parse_key_span_and_get_container[
        o = data.origin, "array", SquareBracketClose
    ] if is_array else parse_key_span_and_get_container[
        o = data.origin, "table", SquareBracketClose
    ]

    ref container = cont_getter(data, idx, base, key)

    # if is array, we were not at the end of the brackets
    idx += Int(is_array)

    # print(
    #     "========>> multiline root key:",
    #     StringSlice(unsafe_from_utf8=key),
    #     "with current codepoint:",
    #     Codepoint(data[idx]),
    # )

    if is_array:
        ref array = container.as_opaque_array()
        array.append(base.new_table().move_to_addr())
        tb = array[len(array) - 1].bitcast[TomlType[data.origin]]()
    else:
        tb = UnsafePointer(to=container)

    # Use `tb` to store any kv pairs

    # If there is a key, there should be a value right?
    # print("move to newline...")
    stop_at[NewLine, SquareBracketOpen](data, idx)
    # print("skip newlines now. We want the next real value...")
    skip[NewLine](data, idx)

    if data[idx] == SquareBracketOpen or idx >= len(data):
        return

    # print("--- parse multiline kv pairs")
    # This function should end just in the next SquarBracketOpen or when we hit max idx
    parse_and_update_kv_pairs[separator=NewLine, end_char=SquareBracketOpen](
        data, idx, tb[]
    )


@always_inline
fn skip[*chars: Byte](data: Span[Byte], mut idx: Int):
    while idx < len(data):

        @parameter
        for i in range(Variadic.size(chars)):
            comptime c = chars[i]
            if data[idx] == c:
                idx += 1
                break
        else:
            return


fn stop_at[*chars: Byte](data: Span[Byte], mut idx: Int):
    while idx < len(data):

        @parameter
        for i in range(Variadic.size(chars)):
            comptime c = chars[i]
            if data[idx] == c:
                return

        idx += 1


fn parse_toml(content: StringSlice) -> TomlType[content.origin]:
    var idx = 0

    var base = TomlType[content.origin].new_table()
    var data = content.as_bytes()

    parse_and_update_kv_pairs[separator=NewLine, end_char=SquareBracketOpen](
        data, idx, base
    )

    # Here we are at end of file or start of a table or table list
    while idx < len(data):
        parse_and_store_multiline_collection(data, idx, base)
    return base^


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

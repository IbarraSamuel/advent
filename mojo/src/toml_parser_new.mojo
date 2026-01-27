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
comptime SquareBracketClose = ord("[")
comptime CurlyBracketOpen = ord("{")
comptime CurlyBracketClose = ord("}")

comptime NewLine = ord("\n")
comptime Space = ord(" ")

comptime Comma = ord(",")
comptime Equal = ord("=")
comptime Period = ord(".")

comptime Quote = ord('"')
comptime Escape = ord("\\")

comptime EmptyChars = (Space, NewLine)
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
    fn __init__(out self: CollectionType[v.value], v: type_of("multiline")):
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

    fn array(self) -> Self.RefArray[origin_of(self)]:
        """Points to self, because external origin it's managed by self."""
        return [
            TomlRef[Self.o, origin_of(self)](Self.from_addr(it))
            for it in self.inner[Self.OpaqueArray]
        ]

    fn table(self) -> Self.RefTable[origin_of(self)]:
        """Points to self, because external origin it's managed by self."""
        return {
            kv.key: TomlRef[Self.o, origin_of(self)](Self.from_addr(kv.value))
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
            w.write(StringSlice(unsafe_from_utf8=inner[self.Unknown]))


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
    idx += 1
    comptime ContainerEnd = ord("]" if collection == "array" else "}")

    @parameter
    if collection == "array":
        value = TomlType[data.origin].new_array()
    else:
        value = TomlType[data.origin].new_table()

    while data[idx] == Space:
        idx += 1

    # We should be at the start of the inner value.
    # Could not be triple quoted.

    while data[idx] != ContainerEnd:

        @parameter
        if collection == "array":  # Within an array, you need to split by comma
            ref arr = value.as_opaque_array()
            arr.append(parse_value(data, idx).move_to_addr())

        elif collection == "table":
            parse_and_update_kv_pairs(data, idx, value)

        # For both table and array, you need to split by comma
        while data[idx] != Comma:
            if data[idx] == ContainerEnd:
                break
            idx += 1

        while data[idx] in EmptyChars:
            idx += 1


fn string_to_type(
    data: Span[Byte], mut idx: Int, out value: TomlType[data.origin]
):
    "Keeps idx a char after the value."
    comptime lower, upper = ord("0"), ord("9")
    var init = idx
    var all_is_digit = True
    var has_dot = False

    if data[idx : idx + 4] == StringSlice("true").as_bytes():
        value = TomlType[data.origin](True)
        idx += 4
        return

    if data[idx : idx + 5] == StringSlice("false").as_bytes():
        idx += 5
        value = TomlType[data.origin](False)
        return

    # TODO: Should handle commas?
    while idx < len(data) and data[idx] not in EmptyChars:
        if all_is_digit and data[idx] < lower or data[idx] > upper:
            # if has dot, then keep it as digit for first dot
            if data[idx] == ord(".") and not has_dot:
                has_dot = True
                continue
            all_is_digit = False
        idx += 1

    var str_val = StringSlice(unsafe_from_utf8=data[init:idx])
    # To keep ending at the end of the values

    if all_is_digit and not has_dot:
        try:
            value = TomlType[data.origin](Int(str_val))
            return
        except:
            pass

    if all_is_digit:
        try:
            value = TomlType[data.origin](atof(str_val))
        except:
            pass

    return TomlType(unknown=data[init:idx])


fn parse_value(
    data: Span[Byte],
    mut idx: Int,
    out value: TomlType[data.origin],
):
    # Assumes the first char is the first value of the value to parse.
    if data[idx] == Quote:
        if data[idx + 1] == Quote and data[idx + 2] == Quote:
            var s = parse_multiline_string(data, idx)
            value = TomlType[data.origin](StringSlice(unsafe_from_utf8=s))
        else:
            var s = parse_quoted_string(data, idx)
            value = TomlType[data.origin](StringSlice(unsafe_from_utf8=s))
        idx += 1
        return
    elif data[idx] == SquareBracketOpen:
        value = parse_inline_collection["array"](data, idx)
        idx += 1
        return
    elif data[idx] == CurlyBracketOpen:
        value = parse_inline_collection["table"](data, idx)
        idx += 1
        return

    # Value should be a integer/float/date/time/datetime/datetimetz/bool

    value = string_to_type(data, idx)


fn get_or_ref_container[
    collection: CollectionType
](key: Span[Byte], mut base: TomlType[key.origin]) -> ref [base] TomlType[
    key.origin
]:
    str_key = StringSlice[mut=False, key.origin](unsafe_from_utf8=key)
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
    """Assumes that first character is not a space. Ends on the end of the key.
    """
    var key_init = idx
    if data[idx] == Quote:
        idx += 1
        while data[idx] != Quote:
            var add_idx = data[idx] == Escape and data[idx + 1] == Quote
            idx += 1 + Int(add_idx)

        key = data[key_init + 1 : idx]
    else:
        while idx < len(data):
            # TODO: Fail on unexpected characters
            if (
                data[idx] == Equal
                or data[idx] == Space
                or data[idx] == close_char
            ):
                key = data[key_init:idx]
                break

            if data[idx] == Period:
                # Reference to the key inside base, and calculate the rest
                key = data[key_init:idx]
                ref cont = get_or_ref_container["table"](key, base)
                idx += 1
                return parse_key_span_and_get_container[collection, close_char](
                    data, idx, cont, key
                )
            idx += 1

    if collection == "multiline":
        return base
    return get_or_ref_container[collection](key, base)


fn find_kv_and_update_base(
    data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]
):
    """Assumes that first character is not a space."""
    var key = data[idx : idx + 1]
    ref tb = parse_key_span_and_get_container["multiline", Equal](
        data, idx, base, key
    )

    # Could be here because of equal or space
    while data[idx] != Equal:
        idx += 1

    # For sure we are on Equal here.
    while data[idx] == Space:
        idx += 1

    # we are on the value part
    tb[StringSlice(unsafe_from_utf8=key)] = parse_value(data, idx)


fn parse_and_update_kv_pairs(
    data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]
):
    while idx < len(data):
        var b = data[idx]

        if b == SquareBracketOpen:
            break

        if b in EmptyChars:
            idx += 1
            continue
        # if b in (Period, Comma, Equal, SquareBracketClose, CurlyBracketClose):
        #     raise TomlException.UnexpectedCharacter

        # Something that is not a collection
        find_kv_and_update_base(data, idx, base)

        # function leaves idx at the end of the parsed value, check for new line
        # TODO: Add support for comments
        while idx != NewLine:
            idx += 1
        idx += 1


fn parse_and_store_multiline_collection(
    data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]
):
    if data[idx] != SquareBracketOpen:
        os.abort("Not an array or table")

    var is_array = data[idx + 1] == SquareBracketOpen
    idx += 1 + Int(is_array)

    var tb: Pointer[TomlType[data.origin], origin_of(base)]
    var key = data[idx : idx + 1]
    # Right away parse the key
    if is_array:
        ref container = parse_key_span_and_get_container[
            "array", SquareBracketClose
        ](data, idx, base, key)
        ref array = container.as_opaque_array()
        array.append(base.new_table().move_to_addr())
        tb = Pointer[origin = origin_of(base)](
            to=array[len(array) - 1].bitcast[TomlType[data.origin]]()[]
        )
    else:
        tb = Pointer(
            to=parse_key_span_and_get_container["table", SquareBracketClose](
                data, idx, base, key
            )
        )

    while data[idx] != NewLine:
        idx += 1
    idx += 1

    # Now let's move on to the key-value pairs
    while data[idx] == Space or data[idx] == NewLine:
        idx += 1

    # Parse Values
    parse_and_update_kv_pairs(data, idx, tb[])


fn parse_toml[
    logging: Bool = False
](content: StringSlice) -> TomlType[content.origin]:
    var idx = 0

    var base = TomlType[content.origin].new_table()
    var data = content.as_bytes()

    @parameter
    if logging:
        print("parse kv pairs at top of fn")

    parse_and_update_kv_pairs(data, idx, base)

    # Here we are at end of file or start of a table or table list
    @parameter
    if logging:
        print("parse collections (tables and arrays)")
    while idx < len(data):
        parse_and_store_multiline_collection(data, idx, base)

        while data[idx] != NewLine:
            idx += 1
        idx += 1

    return base^


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

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
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool

    comptime Array = List[Self]
    comptime Table = Dict[StringSlice[Self.o], Self]

    # Store a list of addesses.
    comptime Opaque[o: Origin] = OpaquePointer[o]
    comptime OpaqueArray = List[Self.Opaque[MutExternalOrigin]]
    comptime OpaqueTable = Dict[
        StringSlice[Self.o], Self.Opaque[MutExternalOrigin]
    ]
    comptime RefArray[o: ImmutOrigin] = List[TomlRef[Self.o, o]]
    comptime RefTable[o: ImmutOrigin] = Dict[
        StringSlice[Self.o], TomlRef[Self.o, o]
    ]

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


comptime AnyTomlType[o: ImmutOrigin] = Variant[
    TomlType[o].String,
    TomlType[o].Integer,
    TomlType[o].Float,
    TomlType[o].Boolean,
    TomlType[o].OpaqueArray,
    TomlType[o].OpaqueTable,
]


fn parse_multiline_string(
    data: Span[Byte], var idx: Int
) -> TomlType[data.origin]:
    idx += 3
    var value_init = idx

    while not (
        data[idx] == Quote
        and data[idx + 1] == Quote
        and data[idx + 2] == Quote
        and data[idx - 1] != Escape
    ):
        idx += 1

    var value = data[value_init:idx]

    idx += 2  # keep on the end of the quote
    return TomlType(
        StringSlice(unsafe_from_utf8=value)
    )  # keep on the end of the quote


fn parse_string(data: Span[Byte], mut idx: Int) -> TomlType[data.origin]:
    idx += 1
    var value_init = idx

    while data[idx] != Quote or data[idx - 1] == Escape:
        idx += 1

    var value = data[value_init:idx]

    idx += 1  # keep on the end of the quote
    return TomlType(
        StringSlice(unsafe_from_utf8=value)
    )  # keep on the end of the value


fn parse_inline_collection[
    o: ImmutOrigin, //, collection: CollectionType
](orig_content: StringSlice[o], mut from_char_idx: Int,) -> TomlType[o]:
    comptime close_char_byte = ord("]" if collection == "array" else "}")

    var close_char = from_char_idx + 1

    var list_nested = 0
    var table_nested = 0
    var string_nested = 0
    var multistring_nested = 0

    var cip = close_char
    var ci = close_char
    var bts = orig_content.as_bytes()

    var objs = (
        TomlType[o].new_array() if collection.inner
        == "array" else TomlType[o].new_table()
    )

    while not (
        (b := bts[ci]) == close_char_byte
        and list_nested + table_nested + string_nested + multistring_nested == 0
    ):
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

            @parameter
            if collection == "array":
                var toml_obj = old_parse_value(obj_str, _lidx)
                objs.as_opaque_array().append(toml_obj^.move_to_addr())
            elif collection == "table":
                var s = ContiguousSlice(0, 0, None)  # gets modified by next fn
                var value = old_try_get_value_and_update_slicer(
                    obj_str, _lidx, s
                )
                var toml_obj = value.take()
                var kk = obj_str[s]
                update_base_with_kv["table"](kk, toml_obj^, objs)

            cip = ci + 1
        ci += 1

    var obj_str = orig_content[cip:ci]

    if obj_str.strip() == "":
        from_char_idx = ci + 1
        return objs^
    var _lidx = 0

    @parameter
    if collection == "array":
        var toml_obj = old_parse_value(obj_str, _lidx)
        objs.as_opaque_array().append(toml_obj^.move_to_addr())
    elif collection == "table":
        var s = ContiguousSlice(0, 0, None)  # gets modified by next fn
        var value = old_try_get_value_and_update_slicer(obj_str, _lidx, s)
        var toml_obj = value.take()
        var kk = obj_str[s]
        update_base_with_kv["table"](kk, toml_obj^, objs)

    from_char_idx = ci + 1
    return objs^


fn string_to_type[o: ImmutOrigin](str_value: StringSlice[o]) -> TomlType[o]:
    s = str_value.strip()
    if (
        len(parts := s.split(".")) == 2
        and parts[0].is_ascii_digit()
        and parts[1].is_ascii_digit()
    ):
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


fn old_parse_value[
    o: ImmutOrigin
](file_content: StringSlice[o], mut idx: Int) -> TomlType[o]:
    var multiline_string_start = file_content.find('"""', idx)
    var string_start = file_content.find('"', idx)
    var list_start = file_content.find("[", idx)
    var table_start = file_content.find("{", idx)

    var content: TomlType[o]
    if is_before(multiline_string_start, list_start, table_start):
        content = parse_multiline_string(
            file_content, idx=multiline_string_start
        )
        return
        idx = multiline_string_start

    elif is_before(string_start, list_start, table_start):
        content = parse_string(file_content, from_char_idx=string_start)
        idx = multiline_string_start

    elif is_before(list_start, table_start):
        content = parse_inline_collection["array"](
            file_content, from_char_idx=list_start
        )
        idx = list_start

    elif is_before(table_start, list_start):
        content = parse_inline_collection["table"](
            file_content, from_char_idx=table_start
        )
        idx = list_start

    else:
        var eol = file_content.find("\n", idx + 1)
        # TODO: Check this...
        var l = len(file_content) if eol == -1 else eol
        var cnt = file_content[idx:l]
        content = string_to_type(cnt)
        idx = l + 1

    return content^


fn parse_value(
    data: Span[Byte],
    mut idx: Int,
    out value: TomlType[data.origin],
):
    var flen = len(data)

    while idx < flen:
        var b = data[idx]
        if b == Quote:
            if data[idx + 1] == Quote and data[idx + 2] == Quote:
                value = parse_multiline_string(data, idx)
            else:
                value = parse_string(data, idx)
            return
        elif b == SquareBracketOpen:
            parse_inline_collection["array"](...)
        elif b == CurlyBracketOpen:
            parse_inline_collection["table"](...)

    #     if file_content[idx]
    # var multiline_string_start = file_content.find('"""', idx)
    # var string_start = file_content.find('"', idx)
    # var list_start = file_content.find("[", idx)
    # var table_start = file_content.find("{", idx)

    # var content: TomlType[o]
    # if is_before(multiline_string_start, list_start, table_start):
    #     content = parse_multiline_string(
    #         file_content, idx=multiline_string_start
    #     )
    #     idx = multiline_string_start

    # elif is_before(string_start, list_start, table_start):
    #     content = parse_string(file_content, from_char_idx=string_start)
    #     idx = multiline_string_start

    # elif is_before(list_start, table_start):
    #     content = parse_inline_collection["array"](
    #         file_content, from_char_idx=list_start
    #     )
    #     idx = list_start

    # elif is_before(table_start, list_start):
    #     content = parse_inline_collection["table"](
    #         file_content, from_char_idx=table_start
    #     )
    #     idx = list_start

    # else:
    #     var eol = file_content.find("\n", idx + 1)
    #     # TODO: Check this...
    #     var l = len(file_content) if eol == -1 else eol
    #     var cnt = file_content[idx:l]
    #     content = string_to_type(cnt)
    #     idx = l + 1

    return TomlType[data.origin](
        StringSlice[mut=False, data.origin](unsafe_from_utf8=data[idx:flen])
    )


# fn update_base_with_kv[
#     o: ImmutOrigin, //, collection: CollectionType
# ](key: StringSlice[o], var value: TomlType[o], mut base: TomlType[o]):
#     var keys = key.split(".")

#     if len(keys) == 1:
#         var value_addr = value^.move_to_addr()

#         @parameter
#         if collection == "table":
#             _ = base.as_opaque_table().setdefault(key.strip(), value_addr)
#         elif collection == "array":
#             var default_array = TomlType[o].new_array()
#             var addr = base.as_opaque_table().setdefault(
#                 key.strip(), default_array^.move_to_addr()
#             )
#             ref new_base_ptr = TomlType[o].from_addr(addr)
#             new_base_ptr.as_opaque_array().append(value_addr)
#         return

#     var first_key = keys[0]

#     var rest = key[len(first_key) + 1 :]
#     var default_tb = TomlType[o].new_table()

#     var new_base_ptr = base.as_opaque_table().setdefault(
#         first_key.strip(), default_tb^.move_to_addr()
#     )
#     ref new_base = TomlType[o].from_addr(new_base_ptr)
#     update_base_with_kv[collection](rest, value^, new_base)


fn old_try_get_value_and_update_slicer[
    o: ImmutOrigin
](
    file_content: StringSlice[o], mut idx: Int, mut s: ContiguousSlice
) -> Optional[TomlType[o]]:
    if file_content.as_bytes()[idx] in [Byte(ord("[")), Byte(ord("{"))]:
        return None

    if (eq_idx := file_content.find("=", idx + 1)) == -1:
        return None

    s = ContiguousSlice(idx, eq_idx, None)
    eq_idx += 1
    var content = old_parse_value(file_content, idx=eq_idx)
    idx = eq_idx  # eq_idx gets modified by parse_value func
    return content^


fn get_or_ref_container[
    collection: CollectionType
](key: Span[Byte], mut base: TomlType[key.origin],) -> ref [base] TomlType[
    key.origin
]:
    str_key = StringSlice[mut=False, key.origin](unsafe_from_utf8=key)
    var def_addr = (
        base.new_array() if collection == "array" else base.new_table()
    ).move_to_addr()
    ref base_tb = base.as_opaque_table().setdefault(str_key, def_addr)
    return base.from_addr(base_tb)


fn parse_key_span_and_get_container[
    collection: CollectionType
](
    data: Span[Byte],
    mut idx: Int,
    mut base: TomlType[data.origin],
    mut key: Span[Byte, data.origin],
) -> ref [base] TomlType[data.origin]:
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
            if data[idx] == Equal or data[idx] == Space:
                key = data[key_init:idx]
                break

            if data[idx] == Period:
                # Reference to the key inside base, and calculate the rest
                key = data[key_init:idx]
                ref cont = get_or_ref_container["table"](key, base)
                idx += 1
                return parse_key_span_and_get_container[collection](
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
    ref tb = parse_key_span_and_get_container["multiline"](data, idx, base, key)

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


fn parse_and_store_collection(
    data: Span[Byte], mut idx: Int, mut base: TomlType[data.origin]
):
    var is_array = True if data[idx + 1] == SquareBracketOpen else False
    idx += 1 + Int(is_array)

    var tb: Pointer[TomlType[data.origin], origin_of(base)]
    var key = data[idx : idx + 1]
    # Right away parse the key
    if is_array:
        ref container = parse_key_span_and_get_container["array"](
            data, idx, base, key
        )
        ref array = container.as_opaque_array()
        array.append(base.new_table().move_to_addr())
        tb = Pointer[origin = origin_of(base)](
            to=array[len(array) - 1].bitcast[TomlType[data.origin]]()[]
        )
    else:
        tb = Pointer(
            to=parse_key_span_and_get_container["table"](data, idx, base, key)
        )

    while data[idx] != NewLine:
        idx += 1
    idx += 1

    # Now let's move on to the key-value pairs
    while data[idx] == Space or data[idx] == NewLine:
        idx += 1

    # Parse Values
    parse_and_update_kv_pairs(data, idx, tb[])


fn parse_toml(
    content: StringSlice[mut=False],
) -> TomlType[content.origin]:
    var idx = 0

    var base = TomlType[content.origin].new_table()
    var data = content.as_bytes()

    parse_and_update_kv_pairs(data, idx, base)

    # Here we are at end of file or start of a table or table list
    while idx < len(data):
        parse_and_store_collection(data, idx, base)

        while data[idx] != NewLine:
            idx += 1
        idx += 1

    return base^


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

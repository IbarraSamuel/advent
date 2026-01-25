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


struct TomlRef[inner: ImmutOrigin, toml: ImmutOrigin](TrivialRegisterType):
    comptime Toml = TomlType[Self.inner]
    var pointer: Pointer[Self.Toml, Self.toml]

    fn __init__(out self, ref [Self.toml]v: Self.Toml):
        self.pointer = Pointer(to=v)

    fn __getitem__(ref self) raises -> ref [Self.toml] Self.Toml:
        return self.pointer[]

    # fn __getitem__(ref self, idx: Int) raises -> ref [Self.toml] Self.Toml:
    #     ref obj = self.pointer[].inner
    #     if not obj.isa[Self.Toml.OpaqueArray]():
    #         raise Error("Wrong object type for array indexing.")

    #     return self.pointer[][idx]

    # fn __getitem__(
    #     ref self, key: StringSlice[...]
    # ) raises -> ref [Self.toml] Self.Toml:
    #     return self.pointer[][key]


struct TomlType[o: ImmutOrigin](Copyable, Writable):
    comptime String = StringSlice[Self.o]
    comptime Integer = Int
    comptime Float = Float64
    comptime Boolean = Bool
    comptime Array = List[Self]
    comptime Table = Dict[StringSlice[Self.o], Self]
    comptime RefArray[o: ImmutOrigin] = List[TomlRef[Self.o, o]]
    comptime RefTable[o: ImmutOrigin] = Dict[
        StringSlice[Self.o], TomlRef[Self.o, o]
    ]
    # Store a list of addesses.
    comptime OpaqueArray = List[Self.Opaque[MutExternalOrigin]]
    comptime OpaqueTable = Dict[
        StringSlice[Self.o], Self.Opaque[MutExternalOrigin]
    ]

    comptime Opaque[o: Origin] = OpaquePointer[o]

    var inner: AnyTomlType[Self.o]

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
        self = Self(Self.OpaqueArray())

    @staticmethod
    fn new_table(out self: Self):
        self = Self(Self.OpaqueTable())

    fn as_opaque_table(ref self) -> ref [self.inner] Self.OpaqueTable:
        return self.inner[Self.OpaqueTable]

    fn as_opaque_array(ref self) -> ref [self.inner] Self.OpaqueArray:
        return self.inner[Self.OpaqueArray]

    # ==== Access inner values using methods ====

    fn string(ref self) raises -> StringSlice[Self.o]:
        if not self.inner.isa[Self.String]():
            raise Error("Wrong object type for string access.")
        return self.inner[Self.String]

    fn integer(ref self) raises -> Int:
        if not self.inner.isa[Self.Integer]():
            raise Error("Wrong object type for integer access.")
        return self.inner[Self.Integer]

    fn float(ref self) raises -> Float64:
        if not self.inner.isa[Self.Float]():
            raise Error("Wrong object type for float access.")
        return self.inner[Self.Float]

    fn boolean(ref self) raises -> Bool:
        if not self.inner.isa[Self.Boolean]():
            raise Error("Wrong object type for boolean access.")
        return self.inner[Self.Boolean]

    fn array(self) raises -> Self.Array:
        """Points to self, because external origin it's managed by self."""
        if not self.inner.isa[Self.OpaqueArray]():
            raise Error("Wrong object type for array access.")
        return [Self.take_from_addr(it) for it in self.inner[Self.OpaqueArray]]

    fn table(self) raises -> Self.Table:
        """Points to self, because external origin it's managed by self."""
        if not self.inner.isa[Self.OpaqueTable]():
            raise Error("Wrong object type for table access.")
        return {
            kv.key: Self.take_from_addr(kv.value)
            for kv in self.inner[Self.OpaqueTable].items()
        }

    fn array_ref(self) raises -> Self.RefArray[origin_of(self)]:
        """Points to self, because external origin it's managed by self."""
        if not self.inner.isa[Self.OpaqueArray]():
            raise Error("Wrong object type for array access.")
        return [
            TomlRef[Self.o, origin_of(self)](Self.from_addr(it))
            for it in self.inner[Self.OpaqueArray]
        ]

    fn table_ref(self) raises -> Self.RefTable[origin_of(self)]:
        """Points to self, because external origin it's managed by self."""
        if not self.inner.isa[Self.OpaqueTable]():
            raise Error("Wrong object type for table access.")
        return {
            kv.key: TomlRef[Self.o, origin_of(self)](Self.from_addr(kv.value))
            for kv in self.inner[Self.OpaqueTable].items()
        }

    # For interop with list

    fn __getitem__(ref self, idx: Int) raises -> ref [self] Self:
        ref obj = self.inner
        if not obj.isa[Self.OpaqueArray]():
            raise Error("Wrong object type for array indexing.")

        return obj[Self.OpaqueArray][idx].bitcast[Self]()[]

    # For interop with dict

    fn __getitem__(ref self, key: StringSlice[...]) raises -> ref [self] Self:
        ref obj = self.inner
        if not obj.isa[Self.OpaqueTable]():
            raise Error("Wrong object type for table indexing.")

        ref table = obj[Self.OpaqueTable]

        for kv in table.items():
            if kv.key == key:
                return Self.from_addr(kv.value)

        raise Error("Key not found.")

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
                var toml_obj = parse_value(obj_str, _lidx)
                objs.as_opaque_array().append(toml_obj^.move_to_addr())
            elif collection == "table":
                var s = Slicer(0, 0, None)  # gets modified by next fn
                var value = try_get_value_and_update_slicer(obj_str, _lidx, s)
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
        var toml_obj = parse_value(obj_str, _lidx)
        objs.as_opaque_array().append(toml_obj^.move_to_addr())
    elif collection == "table":
        var s = Slicer(0, 0, None)  # gets modified by next fn
        var value = try_get_value_and_update_slicer(obj_str, _lidx, s)
        var toml_obj = value.take()
        var kk = obj_str[s]
        update_base_with_kv["table"](kk, toml_obj^, objs)

    from_char_idx = ci + 1
    return objs^


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
        content = parse_multiline_string(
            file_content, idx=multiline_string_start
        )
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
        eol = len(file_content) if eol == -1 else eol
        var cnt = file_content[idx:eol]
        # print("infer type for all: '", cnt, "'", sep="")
        content = string_to_type(cnt)
        idx = eol + 1

    return content^


fn update_base_with_kv[
    o: ImmutOrigin, //, collection: CollectionType
](key: StringSlice[o], var value: TomlType[o], mut base: TomlType[o]):
    var keys = key.split(".")

    if len(keys) == 1:
        var value_addr = value^.move_to_addr()

        @parameter
        if collection == "table":
            _ = base.as_opaque_table().setdefault(key.strip(), value_addr)
        elif collection == "array":
            var default_array = TomlType[o].new_array()
            var addr = base.as_opaque_table().setdefault(
                key.strip(), default_array^.move_to_addr()
            )
            ref new_base_ptr = TomlType[o].from_addr(addr)
            new_base_ptr.as_opaque_array().append(value_addr)
        return

    var first_key = keys[0]

    var rest = key[len(first_key) + 1 :]
    var default_tb = TomlType[o].new_table()

    var new_base_ptr = base.as_opaque_table().setdefault(
        first_key.strip(), default_tb^.move_to_addr()
    )
    ref new_base = TomlType[o].from_addr(new_base_ptr)
    update_base_with_kv[collection](rest, value^, new_base)


fn try_get_value_and_update_slicer[
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
    # print("key found: '", file_content[s].strip(), "'", sep="")
    eq_idx += 1
    # print("value found: '", file_content[eq_idx : eq_idx + 20], "...'", sep="")
    # print("Parsing value into toml...")
    var content = parse_value(file_content, idx=eq_idx)
    # print("Parsing done! Result:", content)
    idx = eq_idx  # eq_idx gets modified by parse_value func
    return content^


fn parse_table[
    o: ImmutOrigin
](full_content: StringSlice[o], mut char_idx: Int) -> TomlType[o]:
    # Clean start
    var i_content = TomlType[o].new_table()

    # The only possibility to stop is to find another table or table list
    var end_of_table = eot if (
        eot := full_content.find("\n[", char_idx)
    ) != -1 else len(full_content)
    # print("end of table found in idx:", end_of_table)
    # print(
    #     "======>> possible table span: from ",
    #     char_idx,
    #     " to ",
    #     end_of_table,
    #     ": ->> '''\n",
    #     full_content[char_idx:end_of_table],
    #     "\n'''",
    #     sep="",
    # )

    var s = Slicer(0, 0, None)
    while char_idx < end_of_table:
        # print("Parsing table content on line:", char_idx)
        var next_jump = full_content.find("\n", char_idx)
        # Do Parsing
        if full_content[char_idx:next_jump].strip() == "":
            # print("empty line. skipping...")
            char_idx = next_jump + 1
            continue

        if kv := try_get_value_and_update_slicer(
            full_content, idx=char_idx, s=s
        ):
            var toml_obj = kv.take()
            # print("store kv pair content", full_content[s])
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
        # print(
        #     (
        #         "no table list. table open bracket should be the first"
        #         " character. expected:"
        #     ),
        #     char_idx,
        #     ", got:",
        #     i,
        # )
        return None
    if l == -1 or full_content.as_bytes()[l + 2] != ord("\n"):
        # print(
        #     "no table list. table close bracket should be the last character in"
        #     " line."
        # )
        return None

    # var key = full_content[i + 2 : l]
    s = Slicer(i + 2, l, None)
    # print("table list key found:", full_content[s])
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
        # print(
        #     (
        #         "no table. table open bracket should be the first character."
        #         " expected:"
        #     ),
        #     char_idx,
        #     ", got:",
        #     i,
        # )
        return None
    if l == -1 or full_content.as_bytes()[l + 1] != ord("\n"):
        # print(
        #     "no table. table close bracket should be the last character in"
        #     " line."
        # )
        return None

    s = Slicer(i + 1, l, None)
    # var key = full_content[i + 1 : l]
    # print("table key found:", full_content[s])
    char_idx = l + 1

    var i_content = parse_table(full_content, char_idx)

    return i_content^


fn parse_toml(content: StringSlice) -> TomlType[content.origin]:
    # var lines = content.splitlines()
    var idx = 0
    # var content_len = len(content)

    var base = TomlType[content.origin].new_table()
    # We will parse the file sequentially, building the type on the way.

    while (nidx := content.find("\n", idx)) != -1:
        # print(
        #     "on line",
        #     content[idx:nidx],
        #     ", and idx span: (",
        #     idx,
        #     ",",
        #     nidx,
        #     ")",
        # )

        # var line = content[idx:nidx]

        # if whitespace, skip line
        if content[idx:nidx].strip() == "":
            idx += nidx + 1
            continue

        # First, find key,value pairs
        # # print("try to get kv pair")
        var s = Slicer(0, 0, None)
        if val := try_get_value_and_update_slicer(content, idx, s):
            var toml_obj = val.take()
            # print("store kv pair content")
            # print("key is:", content[s])
            # print("value is:", toml_obj)
            update_base_with_kv["table"](content[s], toml_obj^, base)
            # print("parsing kv done, moving to ", idx + 1, "...")
            # idx += 1
            continue
        # print("No kv pair. continue")

        # if there is no key, value, then try to get a table list.
        # # print("try to get table list")
        if val := try_get_table_list(content, idx, s):
            var toml_obj = val.take()
            # print("store table list content", content[s])
            update_base_with_kv["table"](content[s], toml_obj^, base)
            # print("parsing table list done, moving to ", idx + 1, "...")
            # idx += 1
            continue
        # print("no table list, continue")

        # # print("try to get table")
        if val := try_get_table(content, idx, s):
            var toml_obj = val.take()
            # print("store table content", content[s])
            update_base_with_kv["table"](content[s], toml_obj^, base)
            # print("parsing table done, moving to ", idx + 1, "...")
            # idx += 1
            continue
        # print("no table. Abort")

        os.abort(
            "This is wrong! This should not happen!. Nothing to parse or rules"
            " doesn't catch this"
        )

    return base^


fn stringify_toml(content: StringSlice) -> String:
    return String(parse_toml(content))

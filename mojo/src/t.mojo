from toml_parser import parse_toml, stringify_toml
from pathlib import Path
from sys import argv
from utils import Variant
import os


# @fieldwise_init("implicit")
# struct Container(Movable, Writable):
#     var val: ContValue

#     fn write_to(self, mut w: Some[Writer]):
#         if self.val.isa[Int]():
#             w.write("Container(Int:", self.val[Int], ")")
#         elif self.val.isa[Float64]():
#             w.write("Container(Float64:", self.val[Float64], ")")
#         elif self.val.isa[MutOpaquePointer[MutAnyOrigin]]():
#             w.write(
#                 "Container(MutOpaquePointer[MutAnyOrigin]:",
#                 self.val[MutOpaquePointer[MutAnyOrigin]].bitcast[Container]()[],
#                 ")",
#             )
#         else:
#             os.abort("no type found to be represented.")


# comptime ContValue = Variant[Float64, Int, MutOpaquePointer[MutAnyOrigin]]


fn main() raises:
    # var int_cont = Container(12)
    # print(int_cont)
    # var ptr_cont = Container(UnsafePointer(to=int_cont).bitcast[NoneType]())
    # print(ptr_cont)
    # var flt_cont = Container(43.0)
    # print(flt_cont)
    # var flt_ptr_cont = Container(UnsafePointer(to=flt_cont).bitcast[NoneType]())
    # print(flt_ptr_cont)

    # var cont_container_value = ContValue(float_cont^)
    # var cont_container = Container(UnsafePointer(to=cont_container_value), 1)
    # print(cont_container)

    var path = argv()[1]
    var f = Path(path).read_text()
    var t = parse_toml(f)
    print("parsed toml:", t)

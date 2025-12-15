from builtin.variadics import Variadic
from builtin.rebind import downcast, trait_downcast


fn concat_tuple(
    var a: Tuple, var b: Tuple
) -> Tuple[*Variadic.concat[a.element_types, b.element_types]]:
    return a.concat(b)


@fieldwise_init("implicit")
struct TestSuite[*ts: Movable]:
    var inner: Tuple[*Self.ts]

    fn test(
        deinit self, var other: Tuple
    ) -> TestSuite[*Variadic.concat[Self.ts, other.element_types]]:
        return {self.inner.concat(other^)}


fn main() raises:
    fn fa() raises unified {}:
        print("fa")

    fn fb() raises unified {}:
        print("fb")

    var first_tuple = TestSuite((fa, fb))

    fn fc() raises unified {}:
        print("fc")

    var all_tuples = first_tuple^.test((fc,))

    @parameter
    for i in range(Variadic.size(all_tuples.ts)):
        ref f = all_tuples.inner[i]
        ref ff = trait_downcast[fn () raises unified](f)
        ff()

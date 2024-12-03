from utils import StaticTuple
from pathlib import Path
from benchmark import run as bench
from pathlib import _dir_of_current_file


trait Solution:
    alias T: DType

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        ...

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        ...


fn run[input_path: StringLiteral, *solutions: Solution]() raises:
    filepath = Path() / ".." / input_path
    alias sols = VariadicList(solutions)
    alias n_sols = len(sols)
    res_part_1 = SIMD[DType.int64, 32](0)
    res_part_2 = SIMD[DType.int64, 32](0)
    res_bench_1 = SIMD[DType.float64, 32](0)
    res_bench_2 = SIMD[DType.float64, 32](0)

    @parameter
    for i in range(n_sols):
        alias Sol = solutions[i]

        fmt = "0" + str(i + 1) if i < 9 else str(i + 1)
        file = filepath / "day{}.txt".format(fmt)
        with open(file, "r") as f:
            data = f.read()

        var p1: Scalar[Sol.T] = 0
        var p2: Scalar[Sol.T] = 0

        @parameter
        fn part_1():
            p1 = Sol.part_1(data)

        @parameter
        fn part_2():
            p2 = Sol.part_2(data)

        rep_1 = bench[part_1]()
        rep_2 = bench[part_2]()

        # Saving results
        res_part_1[i] = p1.cast[DType.int64]()
        res_part_2[i] = p2.cast[DType.int64]()
        res_bench_1[i] = rep_1.mean("ns")
        res_bench_2[i] = rep_2.mean("ns")

    for i in range(n_sols):
        fmt = "0" + str(i + 1) if i < 9 else str(i + 1)
        print("For file: {}/day{}.txt".format(filepath, fmt))
        p1, p2 = res_part_1[i], res_part_2[i]
        b1, b2 = res_bench_1[i], res_bench_2[i]
        print("\tPart 1: {} in {} ns.".format(p1, int(b1)))
        print("\tPart 2: {} in {} ns.".format(p2, int(b2)))

    print("---- END ----")

from advent_utils import AdventSolution, AdventResult
from algorithm.functional import sync_parallelize, parallelize, vectorize, map
from memory import Arc


# fn calc_line(line: String) -> Int:
#     return 1


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        print("iterations:", lines.size)
        total = 0

        @parameter
        fn calc[a: Int](b: Int):
            total += 1

        sync_parallelize[calc[1]](len(lines))
        print("sync_parallelize:", total)
        total = 0
        parallelize[calc[1]](len(lines))
        print("parallelize:", total)
        total = 0
        vectorize[calc, 1](lines.size)
        print("vectorize:", total)
        total = 0
        map[calc[1]](lines.size)
        print("map:", total)
        return 0

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        print("iterations:", lines.size)
        total = 0

        @parameter
        fn calc[a: Int](b: Int):
            total += 1

        sync_parallelize[calc[1]](len(lines))
        print("sync_parallelize:", total)
        total = 0
        parallelize[calc[1]](len(lines))
        print("parallelize:", total)
        total = 0
        vectorize[calc, 1](lines.size)
        print("vectorize:", total)
        total = 0
        map[calc[1]](lines.size)
        print("map:", total)
        return 0

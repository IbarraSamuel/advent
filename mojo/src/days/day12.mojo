from advent_utils import AdventSolution, AdventResult
from algorithm.functional import parallelize


fn calc_line(line: String) -> Int:
    return 1


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        total = 0

        @parameter
        fn calc_permutations(idx: Int) capturing -> None:
            line = lines[idx]
            res = calc_line(line)
            total += res

        parallelize[calc_permutations](lines.size)
        return total

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        total = 0

        @parameter
        fn calc_permutations(idx: Int) capturing -> None:
            line = lines[idx]
            res = calc_line(line)
            total += res

        parallelize[calc_permutations](lines.size)
        return total

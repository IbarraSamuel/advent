from advent_utils import AdventSolution, AdventResult
from collections import Optional
from utils import StaticIntTuple


fn str_to_int(s: String) -> Optional[Int]:
    try:
        return atol(s)
    except:
        return None


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(lines: List[String]) -> AdventResult:
        nums = List[StaticIntTuple[2]]()
        empty_l = List[Int](capacity=lines[0].byte_length())
        empty_c = List[Int](capacity=lines.size)
        empty_c_flg = List[Bool](capacity=lines.size)
        for _ in range(lines.size):
            empty_c_flg.append(True)

        total = 0

        for i in range(lines.size):
            empty_line = True
            for j in range(lines[0].byte_length()):
                if lines[i][j] == "#":
                    nums.append((i, j))
                    # The col is not empty anymore
                    if empty_c[i]:
                        empty_c_flg[i] = False
                        empty_c.append(i)
                    # The row is not empty anymore
                    if empty_line:
                        empty_l.append(j)
                        empty_line = False

        for i in range(nums.size):
            for j in range(i + 1, nums.size):
                a, b = nums[i], nums[j]
                x_space = 0
                y_space = 0
                xmin, xmax = min(a[0], b[0]), max(a[0], b[0])
                ymin, ymax = min(a[1], b[1]), max(a[1], b[1])
                for x in empty_l:
                    x_space += 1 if xmin <= x[] <= xmax else 0

                for y in empty_c:
                    y_space += 1 if ymin <= y[] <= ymax else 0

                total += xmax - xmin + ymax - ymin + x_space * 2 + y_space * 2

        return total

    @staticmethod
    fn part_2(lines: List[String]) -> AdventResult:
        return 0

from collections import Optional
from utils import IndexList
from advent_utils import ListSolution


fn str_to_int(s: String) -> Optional[Int]:
    try:
        return atol(s)
    except:
        return None


struct Solution(ListSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(lines: List[String]) -> UInt32:
        nums = List[IndexList[2]]()
        empty_l = List[Int](capacity=len(lines))
        empty_c = List[Int](capacity=lines[0].byte_length())
        empty_c_flg = List[Bool](capacity=len(lines))
        for _ in range(len(lines)):
            empty_c_flg.append(True)

        for i in range(len(lines)):
            empty_line = True
            for j in range(lines[0].byte_length()):
                if lines[i][j] == "#":
                    nums.append((i, j))
                    # The col is not empty anymore
                    if empty_c_flg[j]:
                        empty_c_flg[j] = False
                    # The row is not empty anymore
                    empty_line = False

            if empty_line:
                empty_l.append(i)

        for i in range(len(empty_c_flg)):
            if empty_c_flg[i]:
                empty_c.append(i)

        total = 0
        for i in range(len(nums)):
            for j in range(i + 1, len(nums)):
                a, b = nums[i], nums[j]
                # Equals will be zero at the end
                x_space = 0
                y_space = 0
                xmin, xmax = min(a[0], b[0]), max(a[0], b[0])
                ymin, ymax = min(a[1], b[1]), max(a[1], b[1])
                for x in empty_l:
                    x_space += 1 if xmin <= x <= xmax else 0

                for y in empty_c:
                    y_space += 1 if ymin <= y <= ymax else 0

                total += xmax - xmin + ymax - ymin + x_space + y_space

        return total

    @staticmethod
    fn part_2(lines: List[String]) -> UInt32:
        nums = List[IndexList[2]]()
        empty_l = List[Int](capacity=len(lines))
        empty_c = List[Int](capacity=lines[0].byte_length())
        empty_c_flg = List[Bool](capacity=len(lines))
        for _ in range(len(lines)):
            empty_c_flg.append(True)

        for i in range(len(lines)):
            empty_line = True
            for j in range(lines[0].byte_length()):
                if lines[i][j] == "#":
                    nums.append((i, j))
                    # The col is not empty anymore
                    if empty_c_flg[j]:
                        empty_c_flg[j] = False
                    # The row is not empty anymore
                    empty_line = False

            if empty_line:
                empty_l.append(i)

        for i in range(len(empty_c_flg)):
            if empty_c_flg[i]:
                empty_c.append(i)

        total = 0
        for i in range(len(nums)):
            for j in range(i + 1, len(nums)):
                a, b = nums[i], nums[j]
                # Equals will be zero at the end
                x_space = 0
                y_space = 0
                xmin, xmax = min(a[0], b[0]), max(a[0], b[0])
                ymin, ymax = min(a[1], b[1]), max(a[1], b[1])
                for x in empty_l:
                    x_space += 999999 if xmin <= x <= xmax else 0

                for y in empty_c:
                    y_space += 999999 if ymin <= y <= ymax else 0

                total += xmax - xmin + ymax - ymin + x_space + y_space

        return total

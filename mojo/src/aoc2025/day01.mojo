from advent_utils import AdventSolution


struct Solution(AdventSolution):
    @staticmethod
    fn part_1(data: StringSlice) -> Int:
        var loc = 50
        var pwd = 0
        for line in data.splitlines():
            var sign = 1 if line[0] == "R" else -1
            var num = line[1:]
            var n: Int
            try:
                n = Int(num)
            except:
                n = 0
            loc = (loc + sign * n) % 100
            if loc == 0:
                pwd += 1
        return pwd

    @staticmethod
    fn part_2(data: StringSlice) -> Int:
        var loc = 50
        var pwd = 0
        for line in data.splitlines():
            var sign = 1 if line[0] == "R" else -1
            var num = line[1:]
            var n: Int
            try:
                n = Int(num)
            except:
                n = 0
            pwd += n // 100
            locp = (loc + sign * n) % 100
            if locp == 0 or (locp > 1) ^ (loc > 1) or (locp < 1) ^ (loc < 1):
                pwd += 1

            loc = locp

        return pwd

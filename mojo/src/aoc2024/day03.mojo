from advent_utils import AdventSolution


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    def part_1(data: StringSlice) -> Self.T:
        var pos = 0
        var tot = 0
        while pos < data.byte_length():
            var pi = data.find("mul(", pos)
            if pi == -1:
                break
            pi += 4
            var pc = data.find(",", start=pi + 1)
            if pc == -1:
                break
            var n1: Int
            try:
                n1 = Int(data[byte=pi:pc])
            except:
                pos = pi + 1
                continue

            var pf = data.find(")", pc + 2)
            if pf == -1:
                break

            var n2: Int
            try:
                n2 = Int(data[byte = pc + 1 : pf])
            except:
                pos = pc + 1
                continue

            pos = pf + 1
            tot += n1 * n2
        return tot

    @staticmethod
    def part_2(data: StringSlice) -> Self.T:
        var pos = 0
        var tot = 0
        var n_dont = data.find("don't()")
        while pos < data.byte_length():
            var pi = data.find("mul(", pos)
            if pi == -1:
                # print("mul( not found")
                break

            if n_dont > -1 and n_dont < pi:
                var do = data.find("do()", pos + 7)
                if do == -1:
                    break
                pos = do + 4
                n_dont = data.find("don't()", pos)
                continue

            pi += 4
            var pc = data.find(",", start=pi + 1)
            if pc == -1:
                break
            var n1: Int
            try:
                n1 = Int(data[byte=pi:pc])
            except:
                pos = pi + 1
                continue

            var pf = data.find(")", pc + 2)
            if pf == -1:
                break

            var n2: Int
            try:
                n2 = Int(data[byte = pc + 1 : pf])
            except:
                pos = pc + 1
                continue

            pos = pf + 1
            tot += n1 * n2
        return tot

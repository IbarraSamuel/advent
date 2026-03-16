from advent_utils import AdventSolution


struct Solution(AdventSolution):
    comptime T = Int

    @staticmethod
    fn part_1(data: StringSlice) -> Self.T:
        pos = 0
        tot = 0
        while pos < len(data):
            pi = data.find("mul(", pos)
            if pi == -1:
                break
            pi += 4
            pc = data.find(",", start=pi + 1)
            if pc == -1:
                break
            try:
                n1 = Int(data[byte=pi:pc])
            except:
                pos = pi + 1
                continue

            pf = data.find(")", pc + 2)
            if pf == -1:
                break

            try:
                n2 = Int(data[byte = pc + 1 : pf])
            except:
                pos = pc + 1
                continue

            pos = pf + 1
            tot += n1 * n2
        return tot

    @staticmethod
    fn part_2(data: StringSlice) -> Self.T:
        pos = 0
        tot = 0
        n_dont = data.find("don't()")
        while pos < len(data):
            pi = data.find("mul(", pos)
            if pi == -1:
                # print("mul( not found")
                break

            if n_dont > -1 and n_dont < pi:
                do = data.find("do()", pos + 7)
                if do == -1:
                    break
                pos = do + 4
                n_dont = data.find("don't()", pos)
                continue

            pi += 4
            pc = data.find(",", start=pi + 1)
            if pc == -1:
                break
            try:
                n1 = Int(data[byte=pi:pc])
            except:
                pos = pi + 1
                continue

            pf = data.find(")", pc + 2)
            if pf == -1:
                break

            try:
                n2 = Int(data[byte = pc + 1 : pf])
            except:
                pos = pc + 1
                continue

            pos = pf + 1
            tot += n1 * n2
        return tot

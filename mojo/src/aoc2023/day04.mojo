from algorithm.functional import parallelize
from advent_utils import AdventSolution


struct Solution(AdventSolution):
    comptime T = UInt32

    @staticmethod
    fn part_1(data: StringSlice) -> UInt32:
        var input = data.splitlines()
        var total = 0

        @parameter
        fn calc_line(idx: Int):
            var winners = List[String]()
            var line = input[idx]
            var inp = line.find(": ") + 2
            var pipe = line.find("|")

            var win_str = line[inp : pipe - 1]
            var num_str = line[pipe + 2 :]
            var winner_amnt = 0

            var accm: String = ""
            for nm in win_str.codepoint_slices():
                if nm.isspace() and len(accm) > 0:
                    winners.append(accm)
                    accm = ""
                    continue

                accm += nm
            winners.append(accm)
            accm = ""

            for nm in num_str.codepoint_slices():
                if nm.isspace() and len(accm) > 0:
                    if accm in winners:
                        winner_amnt += 1
                    accm = ""

                    continue

                accm += nm

            if accm in winners:
                winner_amnt += 1
            total += 2 ** (winner_amnt - 1) if winner_amnt > 0 else 0

        parallelize[calc_line](len(input))
        return total

    @staticmethod
    fn part_2(data: StringSlice) -> UInt32:
        var input = data.splitlines()
        var total = 0
        var amount = List[Int]()
        for _ in range(len(input)):
            amount.append(1)

        fn calc_line(line: StringSlice) -> Int:
            var winners = List[String]()
            var inp = line.find(": ") + 2
            var pipe = line.find("|")

            var win_str = line[inp : pipe - 1]
            var num_str = line[pipe + 2 :]
            var winner_amnt = 0

            var accm: String = ""
            for nm in win_str.codepoint_slices():
                if nm.isspace() and len(accm) > 0:
                    winners.append(accm)
                    accm = ""
                    continue

                accm += nm
            winners.append(accm)
            accm = ""

            for nm in num_str.codepoint_slices():
                if nm.isspace() and len(accm) > 0:
                    if accm in winners:
                        winner_amnt += 1
                    accm = ""

                    continue

                accm += nm

            if accm in winners:
                winner_amnt += 1

            return winner_amnt

        for line in input:
            var amnt = calc_line(line)
            var times = amount.pop(0) if len(amount) > 0 else 1
            total += times
            for i in range(amnt):
                amount[i] += times

        return total

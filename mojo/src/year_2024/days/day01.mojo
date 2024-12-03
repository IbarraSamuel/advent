struct Solution:
    alias T = DType.int32

    @staticmethod
    fn part_1(data: String) -> Scalar[Self.T]:
        lines = data.split()
        t1, t2 = 0, 0
        try:
            for line in lines:
                ns = line[].split()
                t1 += int(ns[0])
                t2 += int(ns[1])
        except:
            pass
        return t2 - t1

    @staticmethod
    fn part_2(data: String) -> Scalar[Self.T]:
        return 0

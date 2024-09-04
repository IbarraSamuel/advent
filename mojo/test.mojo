fn main():
    alias Line = SIMD[DType.uint64, 4]
    line1 = Line(0, 1, 2, 3)
    line2 = Line(1, 2, 3, 4)
    print(line1)
    print(line2)
    print(line2 - line1)
    print(line1.shift_left[1]())
    print(line1.shift_right[1]())

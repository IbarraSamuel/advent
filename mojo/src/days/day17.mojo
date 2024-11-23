from advent_utils import TensorSolution, FileTensor

# Ideas
# 1. To invalidate other paths, you can store the init (x,y), end(x,y) and len(l) information
# and you can discard other paths if both start and end at the same place, but one is larger than others.
# We also need to consider direction and straight steps, to be fully compatible, because we might delete something we dont want.

fn calc_nums() -> List[Int]:
    # returns a list with uint8 from 0 - 9
    l = List[Int](capacity=10)
    for i in range(10):
        l.append(ord(str(i)))

    return l

alias NUMS = calc_nums()
alias Pos = SIMD[DType.uint8, 2]
# alias Dir = Int

@value
@register_passable("trivial")
struct Dir:
    alias UP = 1
    alias DOWN = 2
    alias LEFT = 3
    alias RIGHT = 4
    var v: Int


fn move(from: Dir, pos: Pos) -> (Pos, Pos, Pos):
    return pos, pos, pos

struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        t1 = FileTensor(data).clip()
        return 0

    @staticmethod
    fn part_2(owned data: FileTensor) raises -> Scalar[Self.dtype]:
        return 0

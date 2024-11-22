from advent_utils import TensorSolution, FileTensor

fn calc_nums() -> List[UInt8]:
    l = List[UInt8](capacity=10)
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

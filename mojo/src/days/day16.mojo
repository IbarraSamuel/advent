from advent_utils import TensorSolution, FileTensor, ceil_pow_of_two
from utils import IndexList, Index

alias RIGHT: UInt8 = 0
alias DOWN: UInt8 = 1
alias LEFT: UInt8 = 2
alias UP: UInt8 = 3

alias HORIZONTAL = ord("-")
alias VERTICAL = ord("|")
alias DIAG_45 = ord("/")
alias DIAG_135 = ord("\\")

alias DOT = ord(".")


@register_passable("trivial")
struct Mirror:
    alias HORIZONTAL = Self(HORIZONTAL)
    alias VERTICAL = Self(VERTICAL)
    alias DIAG_45 = Self(DIAG_45)
    alias DIAG_135 = Self(DIAG_135)
    var value: UInt8

    @implicit
    @always_inline("nodebug")
    fn __init__(out self, v: UInt8):
        self.value = v


@register_passable("trivial")
struct Direction:
    alias UP = Self(UP)
    alias DOWN = Self(DOWN)
    alias LEFT = Self(LEFT)
    alias RIGHT = Self(RIGHT)
    var value: UInt8

    @implicit
    @always_inline("nodebug")
    fn __init__(out self, v: UInt8):
        self.value = v

    @always_inline("nodebug")
    fn __eq__(self, other: Self) -> Bool:
        return self.value == other.value

    @always_inline("nodebug")
    fn __neq__(self, other: Self) -> Bool:
        return not self == other

    @always_inline
    fn reflect_once(self, mirror: Mirror) -> Self:
        """Self is the position relative to the mirror.
        If we should have two reflections, I will only give back the opposite dir.
        """

        if mirror.value == HORIZONTAL:
            if self == Self.LEFT or self == Self.RIGHT:
                return self
            elif self == Self.UP:
                return Self.DOWN
            else:
                return Self.UP

        elif mirror.value == VERTICAL:
            if self == Self.UP or self == Self.DOWN:
                return self
            elif self == Self.LEFT:
                return Self.RIGHT
            else:
                return Self.LEFT

        elif mirror.value == DIAG_45:
            if self == Self.RIGHT:
                return Self.DOWN
            elif self == Self.DOWN:
                return Self.RIGHT
            elif self == Self.LEFT:
                return Self.UP
            else:
                return Self.LEFT

        else:  # DIAG_135
            if self == Self.RIGHT:
                return Self.UP
            elif self == Self.UP:
                return Self.RIGHT
            elif self == Self.LEFT:
                return Self.DOWN
            else:
                return Self.LEFT


fn calc_next(
    owned pos: IndexList[2],
    dir: Direction,
    map: FileTensor,
    inout acc: Int,
) -> (IndexList[2], Direction):
    mirr = map.load(pos)
    next_dir = dir.reflect_once(mirr)
    npos = pos
    if next_dir == Direction.DOWN:
        delta = Index(1, 0)
    elif next_dir == Direction.UP:
        delta = Index(-1, 0)
    elif next_dir == Direction.RIGHT:
        delta = Index(0, 1)
    else:
        delta = Index(0, -1)
    while map.load(npos) == DOT:
        npos = npos + delta
    travel = pos - npos
    acc += abs(travel[0]) + abs(travel[1])
    return npos, next_dir


struct Solution(TensorSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(owned lines: FileTensor) raises -> Scalar[Self.dtype]:
        prev_y = lines.bytecount()

        i = 0
        while True:
            if lines[i] == ord("\n"):
                break
            i += 1

        new_tensor = FileTensor(
            shape=((prev_y + 1) // (i + 1), i + 1),
            ptr=lines._take_data_ptr(),
        )

        new_tensor[prev_y] = ord("\n")

        return 0

    @staticmethod
    fn part_2(owned lines: FileTensor) raises -> Scalar[Self.dtype]:
        return 0

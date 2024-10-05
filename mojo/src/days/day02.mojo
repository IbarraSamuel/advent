from advent_utils import AdventSolution
from algorithm.functional import vectorize
from algorithm.reduction import sum, _simd_sum

alias Game = (Int, Int, Int)
alias max_game: Game = (12, 13, 14)


@always_inline
fn create_game(card: String) -> Game:
    var r = 0
    var g = 0
    var b = 0
    var cards: List[String]
    try:
        cards = card.split(", ")
    except:
        return (0, 0, 0)

    @parameter
    for i in range(3):
        if i >= len(cards):
            break
        var color = cards[i]
        var space = color.find(" ")
        var val: Int
        try:
            val = atol(color[:space])
        except:
            return (0, 0, 0)
        if color.endswith("d"):
            r += val
        elif color.endswith("n"):
            g += val
        else:
            b += val

    return (r, g, b)


@always_inline
fn less_than_max(game: Game) -> Bool:
    return (
        game[0] <= max_game[0]
        and game[1] <= max_game[1]
        and game[2] <= max_game[2]
    )


@always_inline
fn calc_max(game: Game, other: Game) -> Game:
    return (
        max(game[0], other[0]),
        max(game[1], other[1]),
        max(game[2], other[2]),
    )


struct Solution(AdventSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1(input: List[String]) -> Scalar[Self.dtype]:
        var total = UInt32(0)

        @parameter
        fn calc_line[v: Int](idx: Int) capturing:
            var cards: List[String]
            try:
                cards = input[idx][input[idx].find(": ") + 2 :].split("; ")
            except:
                return

            for card in cards:
                var gm = create_game(card[])
                if not less_than_max(gm):
                    return
            total += idx + 1

        vectorize[calc_line, 1](len(input))

        return total

    @staticmethod
    fn part_2(input: List[String]) -> Scalar[Self.dtype]:
        var simd = SIMD[DType.uint32, 128](value=0)

        @parameter
        fn set_result[v: Int](idx: Int):
            var max_card = 0, 0, 0
            var first_space = input[idx].find(": ") + 2
            var cards: List[String]
            try:
                cards = input[idx][first_space:].split("; ")
            except:
                return

            for card in cards:
                var gm = create_game(card[])
                max_card = calc_max(max_card, gm)

            simd[idx] = max_card[0] * max_card[1] * max_card[2]

        vectorize[set_result, 1](len(input))
        return simd.reduce_add()

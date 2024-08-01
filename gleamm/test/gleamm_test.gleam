import advent_utils
import days/day01
import gleam/int
import gleam/io
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn day1_test() {
  day01.solution
  |> test_solution("../inputs/tests/day1_1.txt", option.Some(142), option.None)

  day01.solution
  |> test_solution("../inputs/tests/day1_2.txt", option.None, option.Some(281))
}

fn test_solution(
  solution: advent_utils.GenericSolution,
  path: String,
  part_1_result: option.Option(Int),
  part_2_result: option.Option(Int),
) {
  let advent_utils.Solution(part1, part2) = solution

  let lines = path |> advent_utils.read_file
  case lines {
    Error(_) -> { "Not able to read file " <> path } |> io.println_error
    Ok(lines) -> {
      case part_1_result {
        option.None -> "\nNothing for part 1." |> io.println
        option.Some(p1) -> lines |> part1 |> should.equal(p1 |> int.to_string)
      }
      case part_2_result {
        option.None -> "\nNothing for part 2." |> io.println
        option.Some(p2) -> lines |> part2 |> should.equal(p2 |> int.to_string)
      }
    }
  }
}

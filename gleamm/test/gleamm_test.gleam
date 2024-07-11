import advent_utils
import days/day01
import gleam/io
import gleam/option
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

pub fn solution_test(
  solution: advent_utils.GenericSolution,
  path: String,
  part_1_result: option.Option(String),
  part_2_result: option.Option(String),
) {
  let advent_utils.Solution(part1, part2) = solution
  let inp = path |> advent_utils.read_file
  case part_1_result {
    option.Some(p1) -> inp |> part1 |> should.equal(p1)
    option.None -> io.println("Nothing for part 1.")
  }
  case part_2_result {
    option.Some(p2) -> inp |> part2 |> should.equal(p2)
    option.None -> io.println("Nothing for part 2.")
  }
}

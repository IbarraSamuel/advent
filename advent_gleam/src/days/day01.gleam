import advent_utils.{type GenericSolution}
import gleam/string

pub fn part1(input: List(String)) -> String {
  input |> string.join("\n")
}

pub fn solution() -> GenericSolution {
  advent_utils.Solution(part1, part1)
}

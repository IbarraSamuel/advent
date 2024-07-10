import gleam/io
import gleam/result
import gleam/string
import simplifile.{read}

pub type GenericSolution {
  Solution(fn(List(String)) -> String, fn(List(String)) -> String)
}

pub fn read_file(path: String) -> List(String) {
  path |> read |> result.unwrap("Error reading file") |> string.split("\n")
}

pub fn run(solution: GenericSolution, path: String) {
  { "From file " <> path <> ":" } |> io.println
  let content = path |> read_file
  let Solution(part1, part2) = solution
  content |> part1 |> fn(x) { "\tPart 1 -> " <> x } |> io.debug
  content |> part2 |> fn(x) { "\tPart 2 -> " <> x } |> io.debug
}

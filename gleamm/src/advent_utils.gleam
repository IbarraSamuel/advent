import gleam/io
import gleam/result
import gleam/string
import simplifile.{read, type FileError}

pub type GenericSolution {
  Solution(fn(List(String)) -> String, fn(List(String)) -> String)
}

pub fn read_file(path: String) -> Result(List(String), FileError) {
  path
  |> read
  |> result.map(with=string.split("\n"))

  |> result.map(string.split("\n"))
}

pub fn run(path: String, solution: GenericSolution) {
  { "\nFrom " <> path <> " =>" } |> io.println
  let content = path |> read_file
  let Solution(part1, part2) = solution
  content |> part1 |> fn(res) { "\tPart 1: " <> res } |> io.println
  content |> part2 |> fn(res) { "\tPart 2: " <> res } |> io.println
}

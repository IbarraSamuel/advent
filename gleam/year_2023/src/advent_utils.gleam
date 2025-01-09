import gleam/io
import gleam/result
import gleam/string
import simplifile.{type FileError, read}

pub type GenericSolution {
  Solution(fn(List(String)) -> String, fn(List(String)) -> String)
}

pub fn read_file(path: String) -> Result(List(String), FileError) {
  path |> read |> result.map(fn(s) { string.split(s, "\n") })
}

pub fn run(path: String, solution: GenericSolution) {
  { "\nFrom " <> path <> " =>" } |> io.println
  let content = path |> read_file
  case content {
    Error(_) -> { "Error reading file " <> path } |> io.println
    Ok(lines) -> {
      let Solution(part1, part2) = solution
      lines |> part1 |> fn(res) { "\tPart 1: " <> res } |> io.println
      lines |> part2 |> fn(res) { "\tPart 2: " <> res } |> io.println
    }
  }
}

import gleam/int
import gleam/io

// import gleam/list
// import gleam/result
// import gleam/string
import simplifile.{read}

pub type Solution {
  Solution(part_1: fn(String) -> Int, part_2: fn(String) -> Int)
}

pub type Solver {
  Solver(idx: Int, solutions: List(Solution), path: String)
}

pub fn runner(path: String) -> Solver {
  Solver(idx: 0, solutions: [], path: path)
}

pub fn add(solver: Solver, solution: Solution) -> Solver {
  Solver(solver.idx + 1, [solution, ..solver.solutions], solver.path)
}

pub fn run(solver: Solver) {
  case solver.solutions {
    [first, ..rest] -> {
      let day = case solver.idx {
        i if i < 10 -> "0" <> int.to_string(i)
        i -> int.to_string(i)
      }
      let path = solver.path <> "day" <> day <> ".txt"
      let assert Ok(data) = path |> read

      { "Day " <> day <> " =>" } |> io.println
      let r1 = first.part_1(data)
      { "\tPart 1: " <> int.to_string(r1) } |> io.println
      let r2 = first.part_2(data)
      { "\tPart 2: " <> int.to_string(r2) } |> io.println
      run(Solver(solver.idx - 1, rest, solver.path))
    }
    _ -> Nil
  }
}

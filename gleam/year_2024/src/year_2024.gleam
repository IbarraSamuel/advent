import advent_utils.{add, run, runner}
import days/day01
import days/day02

pub fn main() {
  "../../inputs/2024/"
  |> runner
  |> add(day01.solution)
  |> add(day02.solution)
  |> run
}

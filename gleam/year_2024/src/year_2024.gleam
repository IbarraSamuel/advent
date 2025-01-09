import advent_utils.{add, run, runner}
import days/day01

pub fn main() {
  "../../inputs/2024/" |> runner |> add(day01.solution) |> run
}

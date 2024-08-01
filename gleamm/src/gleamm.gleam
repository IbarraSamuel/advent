import advent_utils.{run}
import days/day01
import days/day02

pub fn main() {
  "../inputs/day01.txt" |> run(day01.solution)
  "../inputs/day02.txt" |> run(day02.solution)
}

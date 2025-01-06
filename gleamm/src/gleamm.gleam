import advent_utils.{run}
import days/day01
import days/day02

pub fn main() {
  "../inputs/2023/day01.txt" |> run(day01.solution)
  "../inputs/2023/day02.txt" |> run(day02.solution)
}

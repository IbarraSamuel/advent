mod advent_utils;
mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;
mod day08;
mod day09;
mod day10;
mod day11;
mod day12;

use advent_utils::run;

fn main() -> advent_utils::GenericResult<()> {
    run::<day01::Solution>("../inputs/day1_1.txt", "../inputs/day1_2.txt")?;
    run::<day02::Solution>("../inputs/day2_1.txt", "../inputs/day2_1.txt")?;
    run::<day03::Solution>("../inputs/day3_1.txt", "../inputs/day3_1.txt")?;
    run::<day04::Solution>("../inputs/day4_1.txt", "../inputs/day4_1.txt")?;
    run::<day05::Solution>("../inputs/day5_1.txt", "../inputs/day5_1.txt")?;
    run::<day06::Solution>("../inputs/day6.txt", "../inputs/day6.txt")?;
    run::<day07::Solution>("../inputs/day7.txt", "../inputs/day7.txt")?;
    run::<day08::Solution>("../inputs/day8.txt", "../inputs/day8.txt")?;
    run::<day09::Solution>("../inputs/day9.txt", "../inputs/day9.txt")?;
    run::<day10::Solution>("../inputs/day10.txt", "../inputs/day10.txt")?;
    run::<day11::Solution>("../inputs/day11.txt", "../inputs/day11.txt")?;
    run::<day12::Solution>("../inputs/day12.txt", "../inputs/day12.txt")?;
    Ok(())
}

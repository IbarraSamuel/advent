// #![feature(iter_array_chunks)]
mod common;
mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;

fn main() -> common::GenericResult<()> {
    dbg!(
        common::solve_problem::<day1::Solution>("inputs/day1.txt", "inputs/day1.txt")?,
        common::solve_problem::<day2::Solution>("inputs/day2.txt", "inputs/day2.txt")?,
        common::solve_problem::<day3::Solution>("inputs/day3.txt", "inputs/day3.txt")?,
        common::solve_problem::<day4::Solution>("inputs/day4.txt", "inputs/day4.txt")?,
        common::solve_problem::<day5::Solution>("inputs/day5.txt", "inputs/day5.txt")?,
        common::solve_problem::<day6::Solution>("inputs/day6.txt", "inputs/day6.txt")?,
        common::solve_problem::<day7::Solution>("inputs/day7.txt", "inputs/day7.txt")?,
    );
    Ok(())
}

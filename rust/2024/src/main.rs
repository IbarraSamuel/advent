mod advent_utils;
mod days;

use advent_utils::Solver;

// TODO: Add library to be able to run doctests.
fn main() {
    Solver::builder()
        .add::<days::day01::Solution>("../inputs/2024/day01.txt")
        .compute()
}

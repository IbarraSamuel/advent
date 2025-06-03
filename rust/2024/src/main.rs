use aoc2024::days;

// TODO: Add library to be able to run doctests.
fn main() {
    aoc2024::Solver::from("../inputs/2024")
        .add::<days::day01::Solution>()
        .add::<days::day02::Solution>()
        .add::<days::day03::Solution>()
        .add::<days::day04::Solution>()
        .compute()
}

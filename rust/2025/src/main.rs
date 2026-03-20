use aoc2025::days;

// TODO: Add library to be able to run doctests.
fn main() {
    aoc2025::Solver::from("../inputs/2025")
        .add::<days::day01::Solution>()
        .add::<days::day02::Solution>()
        .add::<days::day03::Solution>()
        .add::<days::day04::Solution>()
        .add::<days::day05::Solution>()
        .compute()
}

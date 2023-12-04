mod advent_utils;
mod day1;
mod day2;
mod day3;

use advent_utils::run;

fn main() -> advent_utils::GenericResult<()> {
    run::<day1::Solution>("../inputs/day1_1.txt", "../inputs/day1_2.txt")?;
    run::<day2::Solution>("../inputs/day2_1.txt", "../inputs/day2_1.txt")?;
    run::<day3::Solution>("../inputs/day3_1.txt", "../inputs/day3_1.txt")?;
    Ok(())
}

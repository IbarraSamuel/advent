mod advent_utils;
mod day1;
mod day2;

use advent_utils::run;

fn main() -> advent_utils::GenericResult<()> {
    run::<day1::Solution>("../inputs/day1_1.txt", "../inputs/day1_2.txt")?;
    run::<day2::Solution>("../inputs/day2_1.txt", "../inputs/day2_1.txt")?;
    Ok(())
}

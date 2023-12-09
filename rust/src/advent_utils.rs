use std::path::Path;

pub type GenericResult<T> = Result<T, Box<dyn std::error::Error>>;

pub trait AdventSolution {
    fn part1(input: Vec<String>) -> GenericResult<String>;
    fn part2(input: Vec<String>) -> GenericResult<String>;
}

pub fn run<S: AdventSolution>(
    part_1: impl AsRef<Path>,
    part_2: impl AsRef<Path>,
) -> GenericResult<()> {
    let input_1 = read_input(part_1)?;
    let input_2 = read_input(part_2)?;
    println!(
        "Part 1: {} | Part 2: {}",
        S::part1(input_1)?,
        S::part2(input_2).unwrap_or("NOT IMPLEMENTED".to_string())
    );
    Ok(())
}

pub fn read_input(path: impl AsRef<Path>) -> Result<Vec<String>, std::io::Error> {
    std::fs::read_to_string(path).map(|s| s.lines().map(String::from).collect())
}

#[macro_export]
macro_rules! advent_test {
    ($input1: literal, $output1: literal, $input2: literal, $output2: literal) => {
        #[cfg(test)]
        mod test_solution {
            use super::Solution;
            use $crate::advent_utils::{read_input, AdventSolution, GenericResult};

            #[test]
            fn part_1() -> GenericResult<()> {
                let inp = read_input($input1)?;
                assert_eq!(Solution::part1(inp)?, $output1);
                Ok(())
            }

            #[test]
            fn part_2() -> GenericResult<()> {
                let inp = read_input($input2)?;
                assert_eq!(Solution::part2(inp)?, $output2);
                Ok(())
            }
        }
    };
}

use std::path::Path;

pub type GenericResult<T> = Result<T, Box<dyn std::error::Error>>;

pub trait AdventSolution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display>;
    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display>;
}

pub fn run<S: AdventSolution>(path: impl AsRef<Path>) -> GenericResult<()> {
    println!("From {:?} =>", &path.as_ref());
    let input = read_input(path)?;

    let result_1 = S::part1(input.clone())?;
    println!("\tPart 1: {result_1}");

    match S::part2(input) {
        Ok(result_2) => println!("\tPart 2: {result_2}\n"),
        _ => println!("NOT IMPLEMENTED!\n"),
    }
    Ok(())
}

pub fn read_input(path: impl AsRef<Path>) -> Result<Vec<String>, std::io::Error> {
    let stream = std::fs::read_to_string(path)?;
    let lines = stream.lines().map(String::from).collect::<Vec<_>>();
    Ok(lines)
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

#[macro_export]
macro_rules! advent_tests {
    (part 1 => ($($input1:literal => $output1:literal),+), part 2 => ($($input2:literal => $output2:literal),+)) => {
        #[cfg(test)]
        mod test_solution {
            use super::Solution;
            use $crate::advent_utils::{read_input, AdventSolution, GenericResult};

            #[test]
            fn part_1() -> GenericResult<()> {
                $(
                    let inp = read_input($input1)?;
                    assert_eq!(Solution::part1(inp)?, $output1);
                )+

                Ok(())
            }

            #[test]
            fn part_2() -> GenericResult<()> {
                $(
                    let inp = read_input($input2)?;
                    assert_eq!(Solution::part2(inp)?, $output2);
                )+
                Ok(())
            }
        }
    };
}

pub type GenericResult<T> = Result<T, GenericError>;
pub type GenericError = Box<dyn std::error::Error>;

pub trait AdventResult {
    fn calculation_1(input: Vec<String>) -> GenericResult<String>;
    fn calculation_2(input: Vec<String>) -> GenericResult<String>;
}

fn load_input(path: &str) -> std::io::Result<Vec<String>> {
    Ok(std::fs::read_to_string(path)?
        .split_terminator('\n')
        .map(String::from)
        .collect())
}

pub fn solve_problem<Fn>(file1: &str, file2: &str) -> GenericResult<String>
where
    Fn: AdventResult,
{
    let (i1, i2) = (load_input(file1)?, load_input(file2)?);
    let ans1 = Fn::calculation_1(i1)?;
    let ans2 = Fn::calculation_2(i2).unwrap_or("Missing...".into());
    let result = format!("(part_1: {ans1}, part_2: {ans2})");
    Ok(result)
}

/// This macro need your module `name` which contains a `Solution` struct that implements [AdventResult].
#[macro_export]
macro_rules! advent_test {
    ($meta: ident, $input: literal, $output1: literal, $output2: literal) => {
        #[cfg(test)]
        mod advent_tests {
            // use super::Solution;
            use super::{AdventResult, GenericResult};
            use $crate::$meta::Solution;

            #[test]
            fn case_1() -> GenericResult<()> {
                let inp = str_to_vec($input);
                assert_eq!($output1, Solution::calculation_1(inp)?);

                Ok(())
            }

            #[test]
            fn case_2() -> GenericResult<()> {
                let inp = str_to_vec($input);
                assert_eq!($output2, Solution::calculation_2(inp)?);
                Ok(())
            }

            fn str_to_vec(string: &str) -> Vec<String> {
                let inp = string
                    .split_terminator('\n')
                    .map(|s| s.replacen(' ', "", 4))
                    .collect::<Vec<_>>();
                inp[1..inp.len() - 1].into()
            }
        }
    };
}

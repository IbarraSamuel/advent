use crate::advent_utils::{AdventSolution, GenericResult};
use std::collections::HashMap;
use std::vec;

pub struct Solution;

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let result = input
            .into_iter()
            .map(|line| {
                let values = line.chars().filter(|c| c.is_ascii_digit());
                values.clone().next().unwrap().to_digit(10).unwrap() * 10
                    + values.last().unwrap().to_digit(10).unwrap()
            })
            .sum::<u32>();
        Ok(result)
    }

    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let to_check: HashMap<&str, u32> = HashMap::from_iter(vec![
            ("one", 1),
            ("two", 2),
            ("three", 3),
            ("four", 4),
            ("five", 5),
            ("six", 6),
            ("seven", 7),
            ("eight", 8),
            ("nine", 9),
            ("1", 1),
            ("2", 2),
            ("3", 3),
            ("4", 4),
            ("5", 5),
            ("6", 6),
            ("7", 7),
            ("8", 8),
            ("9", 9),
        ]);
        let result = input
            .into_iter()
            .filter_map(|line| {
                let first = to_check
                    .keys()
                    .filter_map(|&word| Some((word, line.find(word)?)))
                    .min_by_key(|&(_, idx)| idx)
                    .map(|(name, _)| to_check[name])?;

                let last = to_check
                    .keys()
                    .filter_map(|&word| Some((word, line.rfind(word)?)))
                    .max_by_key(|&(_, idx)| idx)
                    .map(|(name, _)| to_check[name])?;

                Some(first * 10 + last)
            })
            .sum::<u32>();

        Ok(result)
    }
}

crate::advent_tests!(
    part 1 => (
        "../../tests/2023/day1_1.txt" => 142
    ),
    part 2 => (
        "../../tests/2023/day1_2.txt" => 281
    )
);

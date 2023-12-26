use std::collections::HashMap;
use std::vec;

use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

impl AdventSolution<String> for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
        let result = input
            .into_iter()
            .filter_map(|line| {
                let values = line.chars().filter(|c| c.is_ascii_digit());
                format!("{}{}", values.clone().next()?, values.last()?)
                    .parse::<u32>()
                    .ok()
            })
            .sum::<u32>();
        Ok(result.to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
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

                to_check
                    .keys()
                    .filter_map(|&word| Some((word, line.rfind(word)?)))
                    .max_by_key(|&(_, idx)| idx)
                    .map(|(name, _)| first * 10 + to_check[name])
            })
            .sum::<u32>();

        Ok(result.to_string())
    }
}

crate::advent_test! {
    "../inputs/tests/day1_1.txt",
    "142",
    "./../inputs/tests/day1_2.txt",
    "281"
}

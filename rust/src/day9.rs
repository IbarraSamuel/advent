use crate::advent_test;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

fn calc_diff(values: &[i64]) -> Vec<i64> {
    values.windows(2).map(|w| w[1] - w[0]).collect()
}

fn calc_prev_and_next(values: &[i64]) -> (i64, i64) {
    let mut diffs = vec![values.to_vec()];
    loop {
        let last_diff = &diffs[diffs.len() - 1];
        if last_diff.iter().all(|v| *v == 0) {
            break;
        }
        diffs.push(calc_diff(last_diff));
    }

    let prev = diffs.iter().rev().fold(0, |acc, v| v[0] - acc);
    let next = diffs.iter().fold(0, |acc, v| v[v.len() - 1] + acc);
    (prev, next)
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
        let last_values = input
            .iter()
            .map(|s| {
                let numbers = s
                    .split_ascii_whitespace()
                    .filter_map(|n| n.parse::<i64>().ok())
                    .collect::<Vec<_>>();
                calc_prev_and_next(&numbers).1
            })
            .collect::<Vec<i64>>();

        Ok(last_values.iter().sum::<i64>().to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
        let last_values = input
            .iter()
            .map(|s| {
                let numbers = s
                    .split_ascii_whitespace()
                    .filter_map(|n| n.parse::<i64>().ok())
                    .collect::<Vec<_>>();
                calc_prev_and_next(&numbers).0
            })
            .collect::<Vec<i64>>();

        Ok(last_values.iter().sum::<i64>().to_string())
        // Ok("".to_string())
    }
}

advent_test!(
    "../inputs/tests/day9.txt",
    "114",
    "../inputs/tests/day9.txt",
    "2"
);

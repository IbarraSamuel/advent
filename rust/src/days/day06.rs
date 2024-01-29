use crate::advent_tests;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

struct Race {
    duration: usize,
    record: usize,
}

fn quadratic_solution(a: i64, b: i64, c: i64) -> (f64, f64) {
    let cns = -b as f64 / (2.0 * a as f64);
    let v = ((b.pow(2) - 4 * a * c) as f64).sqrt() / (2.0 * a as f64);
    (cns - v, cns + v)
}

impl Race {
    fn races_winning(&self) -> usize {
        // Since the nature of the function is quadratic, can be calculated using a function
        // If we see, the distance is a function of the time pressed. So:
        // t * (d - t)
        // -t^2 + d*t ..
        // If the value needs to be less than the record r. Then the equation is:
        // -t^2 + d*t = r. So looking for t, we get:
        // t^2 - d*t + r = 0. Solution is:
        // (-b +- root(b^2 - 4ac)) / 2a where a = 1, b = -duration and c = record
        let (a, b, c) = (1, -(self.duration as i64), self.record as i64);
        let (lower, upper) = quadratic_solution(a, b, c);
        let (lower, upper) = (
            (lower + 1.0).floor() as usize,
            (upper - 1.0).ceil() as usize,
        );
        upper - lower + 1
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let total_races = input[0].split_whitespace().count() - 1;
        let lines = input
            .iter()
            .map(|line| {
                line.split_ascii_whitespace()
                    .skip(1)
                    .filter_map(|v| v.parse::<usize>().ok())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();
        let result: usize = (0..total_races)
            .map(|r| {
                Race {
                    duration: lines[0][r],
                    record: lines[1][r],
                }
                .races_winning()
            })
            .product();
        Ok(result)
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        if let &[duration, record] = input
            .iter()
            .filter_map(|l| {
                l.split_whitespace()
                    .skip(1)
                    .collect::<String>()
                    .parse::<usize>()
                    .ok()
            })
            .collect::<Vec<_>>()
            .as_slice()
        {
            Ok(Race { duration, record }.races_winning())
        } else {
            panic!("could not happen")
        }
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day6.txt" => 288
    ),
    part 2 => (
        "../inputs/tests/day6.txt" => 71503
    )
);

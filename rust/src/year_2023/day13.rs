use crate::advent_tests;

use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

fn is_mirror(values: &[String]) -> Option<usize> {
    (1..values.len()).find(|&idx| {
        values[idx..values.len()]
            .iter()
            .zip(values[0..idx].iter().rev())
            .all(|(a, b)| a == b)
    })
}

fn almost_a_mirror(values: &[String]) -> Option<usize> {
    (1..values.len()).find(|&idx| {
        values[idx..values.len()]
            .iter()
            .zip(values[0..idx].iter().rev())
            .map(|(a, b)| {
                a.chars()
                    .zip(b.chars())
                    .map(|x| (x.0 != x.1) as usize)
                    .sum::<usize>()
            })
            .sum::<usize>()
            == 1
    })
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let total = input
            .split(|s| s.is_empty())
            .map(|h| {
                is_mirror(h)
                    .map(|x| x * 100)
                    .or_else(|| {
                        is_mirror(
                            &(0..h[0].len())
                                .map(|col| {
                                    h.iter()
                                        .filter_map(|s| s.chars().nth(col))
                                        .collect::<String>()
                                })
                                .collect::<Vec<_>>(),
                        )
                    })
                    .expect("No mirror found!")
            })
            .sum::<usize>();

        Ok(total)
    }

    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let total = input
            .split(|s| s.is_empty())
            .map(|h| {
                almost_a_mirror(h)
                    .map(|x| x * 100)
                    .or_else(|| {
                        almost_a_mirror(
                            &(0..h[0].len())
                                .map(|col| {
                                    h.iter()
                                        .filter_map(|s| s.chars().nth(col))
                                        .collect::<String>()
                                })
                                .collect::<Vec<_>>(),
                        )
                    })
                    .expect("No mirror found!")
            })
            .sum::<usize>();

        Ok(total)
    }
}

advent_tests!(
    part 1 => (
        "../tests/day13.txt" => 405
    ),
    part 2 => (
        "../tests/day13.txt" => 400
    )
);

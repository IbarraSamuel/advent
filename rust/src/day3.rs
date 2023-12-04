use std::{collections::HashSet, ops::Add};

use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

struct Number {
    x: usize,
    y: usize,
    len: usize,
    val: usize,
}

impl Number {
    fn validate(&self, input: &Vec<String>) -> Option<usize> {
        let &Self { x, y, len, val } = self;

        let upper = if y == 0 { 0 } else { y - 1 };
        let lower = if y == input.len() - 1 { y } else { y + 1 };
        let left = if x == 0 { 0 } else { x - 1 };
        let right = if x + len == input[y].len() {
            x + len
        } else {
            x + len + 1
        };

        input[upper][left..right]
            .chars()
            .chain(input[lower][left..right].chars())
            .chain(input[y][left..right].chars())
            .any(|c| !"1234567890.".contains(c))
            .then_some(val)
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
        let values: usize = input
            .iter()
            .enumerate()
            .map(|(y, line)| {
                line.chars()
                    .enumerate()
                    .fold::<(Option<String>, Vec<Option<usize>>), _>(
                        (None, vec![]),
                        |(grp, mut vc), (x, n)| match grp {
                            Some(s) if n.is_ascii_digit() && x == line.len() - 1 => {
                                vc.push(
                                    Number {
                                        x: x - s.len() - 1,
                                        y,
                                        len: s.len() + 1,
                                        val: s.add(&n.to_string()).parse::<usize>().unwrap(),
                                    }
                                    .validate(&input),
                                );
                                (None, vc)
                            }
                            Some(s) if n.is_ascii_digit() => (Some(s.add(&n.to_string())), vc),
                            Some(s) => {
                                vc.push(
                                    Number {
                                        x: x - s.len(),
                                        y,
                                        len: s.len(),
                                        val: s.parse::<usize>().unwrap(),
                                    }
                                    .validate(&input),
                                );
                                (None, vc)
                            }
                            None if n.is_ascii_digit() => (Some(n.to_string()), vc),
                            None => (grp, vc),
                        },
                    )
                    .1
            })
            .flatten()
            .filter_map(|v| v)
            .sum::<usize>();
        Ok(values.to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
        fn get_num(pos: (usize, usize), input: &Vec<String>) -> usize {
            assert!(input[pos.1].chars().nth(pos.0).unwrap().is_ascii_digit());

            input[pos.1]
                .chars()
                .skip(pos.0)
                .take_while(|c| c.is_ascii_digit())
                .collect::<String>()
                .parse::<usize>()
                .unwrap()
        }

        fn find_init_number((mut x, y): (usize, usize), input: &Vec<String>) -> (usize, usize) {
            assert!(input[y].chars().nth(x).unwrap().is_ascii_digit());

            if x == 0 {
                return (0, y);
            }

            // check for prev. digit
            while input[y].chars().nth(x - 1).unwrap().is_ascii_digit() {
                x -= 1;
                if x == 0 {
                    return (0, y);
                }
            }

            (x, y)
        }

        fn gear_value((x, y): (usize, usize), input: &Vec<String>) -> Option<usize> {
            let lower = y.max(1) - 1;
            let upper = y.min(input.len() - 2) + 1;
            let left = x.max(1) - 1;
            let right = x.min(input[y].len() - 2) + 1;

            let num_pos = input[lower][left..=right]
                .char_indices()
                .filter_map(|(x, c)| {
                    c.is_ascii_digit()
                        .then(|| find_init_number((left + x, lower), input))
                })
                .chain(
                    input[upper][left..=right]
                        .char_indices()
                        .filter_map(|(x, c)| {
                            c.is_ascii_digit()
                                .then(|| find_init_number((left + x, upper), input))
                        }),
                )
                .chain(input[y][left..=right].char_indices().filter_map(|(x, c)| {
                    c.is_ascii_digit()
                        .then(|| find_init_number((left + x, y), input))
                }))
                .collect::<HashSet<_>>();

            if num_pos.len() == 2 {
                Some(num_pos.iter().map(|&p| get_num(p, input)).product())
            } else {
                None
            }
        }

        let total_value = input
            .iter()
            .enumerate()
            .flat_map(|(y, line)| {
                line.char_indices()
                    .filter(|(_, c)| c == &'*')
                    .filter_map(|(x, _)| gear_value((x, y), &input))
                    .collect::<Vec<_>>()
            })
            .sum::<usize>();

        Ok(total_value.to_string())
    }
}

crate::advent_test! {
    "../inputs/tests/day3_1.txt",
    "4361",
    "../inputs/tests/day3_1.txt",
    "467835"
}

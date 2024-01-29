use std::collections::{BTreeMap, HashSet};

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

pub struct Solution {}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        fn inp_to_values((left, right): (&str, &str)) -> usize {
            let pow = left
                .split_whitespace()
                .filter_map(|v| v.parse::<usize>().ok())
                .collect::<HashSet<_>>()
                .intersection(
                    &right
                        .split_whitespace()
                        .filter_map(|v| v.parse::<usize>().ok())
                        .collect::<HashSet<_>>(),
                )
                .count();

            if pow == 0 {
                0
            } else {
                2_usize.pow(pow as u32 - 1)
            }
        }

        let out = input
            .into_iter()
            .map(|line| inp_to_values(line.split_once(": ").unwrap().1.split_once(" | ").unwrap()))
            .sum::<usize>();

        Ok(out)
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        fn inp_to_values((left, right): (&str, &str)) -> usize {
            left.split_whitespace()
                .filter_map(|v| v.parse::<usize>().ok())
                .collect::<HashSet<_>>()
                .intersection(
                    &right
                        .split_whitespace()
                        .filter_map(|v| v.parse::<usize>().ok())
                        .collect::<HashSet<_>>(),
                )
                .count()
        }
        let cards: Vec<(usize, (&str, &str))> = input
            .iter()
            .map(|line| line[5..].split_once(": ").unwrap())
            .map(|(a, b)| {
                (
                    a.trim_start().parse::<usize>().unwrap(),
                    b.split_once(" | ").unwrap(),
                )
            })
            .collect();

        let mut values: BTreeMap<usize, (usize, usize)> = cards
            .into_iter()
            .map(|(a, b)| (a, (inp_to_values(b), 1)))
            .collect();

        let mut tot = 0;
        for k in values.clone().keys() {
            let (rep, v) = values[k];
            tot += v;
            for i in (k + 1)..(k + rep + 1) {
                let (_, vl) = values.get_mut(&i).expect("Bad Position");
                *vl += v;
            }
        }
        Ok(tot)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day4_1.txt" => 13
    ),
    part 2 => (
        "../inputs/tests/day4_1.txt" => 30
    )
);

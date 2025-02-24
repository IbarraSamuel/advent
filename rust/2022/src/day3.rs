use std::collections::HashSet;

use crate::common::{AdventResult, GenericResult};

pub(super) struct Solution;

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        Ok(input
            .iter()
            .map(|s| {
                let (a, b) = s.split_at(s.len() / 2);
                let ha = a.chars().collect::<HashSet<_>>();
                let hb = b.chars().collect::<HashSet<_>>();
                ha.intersection(&hb)
                    .map(|&c| match c {
                        'a'..='z' => 1 + c as u32 - 'a' as u32,
                        'A'..='Z' => 1 + c as u32 - 'A' as u32 + 26,
                        _ => panic!(),
                    })
                    .map(u64::from)
                    .sum::<u64>()
            })
            .sum::<u64>()
            .to_string())
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        Ok(input
            .chunks_exact(3)
            .map(|slice| {
                slice
                    .iter()
                    .map(|s| s.chars().collect::<HashSet<_>>())
                    .reduce(|acc, n| acc.intersection(&n).copied().collect::<HashSet<_>>())
                    .expect("reduce operation failed")
                    .iter()
                    .map(|&c| match c {
                        'a'..='z' => 1 + c as u32 - 'a' as u32,
                        'A'..='Z' => 1 + c as u32 - 'A' as u32 + 26,
                        _ => panic!(),
                    })
                    .map(u64::from)
                    .sum::<u64>()
            })
            .sum::<u64>()
            .to_string())
    }
}

crate::advent_test! {
    day3,
    r#"
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    "#,
    "157",
    "70"
}

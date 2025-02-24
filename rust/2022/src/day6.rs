use crate::common::{AdventResult, GenericResult};

use std::collections::HashSet;

pub(super) struct Solution;

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        let sop = 4;
        (0..input[0].len())
            .find_map(|i| {
                input[0][i..i + sop]
                    .chars()
                    .collect::<HashSet<_>>()
                    .len()
                    .eq(&sop)
                    .then_some(i + sop)
            })
            .map(|u| u.to_string())
            .ok_or("No value found".into())
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        let som = 14;
        (0..input[0].len())
            .find_map(|i| {
                input[0][i..i + som]
                    .chars()
                    .collect::<HashSet<_>>()
                    .len()
                    .eq(&som)
                    .then_some(i + som)
            })
            .map(|u| u.to_string())
            .ok_or("No value found".into())
    }
}

crate::advent_test! {
    day6,
    r#"
    mjqjpqmgbljsphdztnvjfqwrcgsmlb
    "#,
    "7",
    "19"
}

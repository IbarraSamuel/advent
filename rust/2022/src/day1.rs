use crate::common::{AdventResult, GenericResult};

pub(super) struct Solution;

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        let output = input
            .split(|s| s.is_empty())
            .map(|v| v.iter().filter_map(|s| s.parse::<i64>().ok()).sum::<i64>())
            .max()
            .map(|n| n.to_string())
            .unwrap_or_default();

        Ok(output)
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        let mut results = input
            .split(|s| s.is_empty())
            .map(|v| v.iter().filter_map(|s| s.parse::<i64>().ok()).sum::<i64>())
            .collect::<Vec<_>>();

        results.sort();
        results.reverse();
        results.truncate(3);

        let output = results.iter().sum::<i64>().to_string();

        Ok(output)
    }
}

crate::advent_test! {
    day1,
    r#"
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
    "#,
    "24000",
    "45000"
}

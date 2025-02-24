use crate::common::{AdventResult, GenericResult};

pub(super) struct Solution;

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        Ok(input
            .iter()
            .filter_map(|s| s.split_once(','))
            .filter_map(|(a, b)| -> Option<((i32, i32), (i32, i32))> {
                let tpa = a.split_once('-')?;
                let tpb = b.split_once('-')?;
                Some((
                    (tpa.0.parse().ok()?, tpa.1.parse().ok()?),
                    (tpb.0.parse().ok()?, tpb.1.parse().ok()?),
                ))
            })
            .filter(|(a, b)| a.0 <= b.0 && b.1 <= a.1 || b.0 <= a.0 && a.1 <= b.1)
            .count()
            .to_string())
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        Ok(input
            .iter()
            .filter_map(|s| s.split_once(','))
            .filter_map(|(a, b)| -> Option<((i32, i32), (i32, i32))> {
                let tpa = a.split_once('-')?;
                let tpb = b.split_once('-')?;
                Some((
                    (tpa.0.parse().ok()?, tpa.1.parse().ok()?),
                    (tpb.0.parse().ok()?, tpb.1.parse().ok()?),
                ))
            })
            .filter(|(a, b)| {
                a.0 <= b.0 && b.0 <= a.1
                    || a.0 <= b.1 && b.1 <= a.1
                    || b.0 <= a.0 && a.0 <= b.1
                    || b.0 <= a.1 && a.1 <= b.1
            })
            .count()
            .to_string())
    }
}

crate::advent_test! {
    day4,
    r#"
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    "#,
    "2",
    "4"
}

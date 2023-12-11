use crate::advent_utils::{AdventSolution, GenericResult};
use std::collections::{HashMap, HashSet};
pub struct Solution;

type HashMapper<'t> = HashMap<&'t str, (&'t str, Vec<(usize, usize, usize)>)>;

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
        let seeds = input[0]
            .strip_prefix("seeds: ")
            .unwrap()
            .split_whitespace()
            .filter_map(|s| s.parse::<usize>().ok())
            .collect::<Vec<_>>();

        let parse_maps: HashMapper = input
            .split(|l| l.is_empty())
            .skip(1)
            .map(|collection| {
                let (from, to) = collection
                    .first()
                    .unwrap()
                    .strip_suffix(" map:")
                    .unwrap()
                    .split_once("-to-")
                    .unwrap();
                let mappers = collection
                    .iter()
                    .skip(1)
                    .filter_map(|line| {
                        if let &[a, b, c] = line
                            .split_ascii_whitespace()
                            .filter_map(|v| v.parse::<usize>().ok())
                            .collect::<Vec<_>>()
                            .as_slice()
                        {
                            Some((b, a, c))
                        } else {
                            None
                        }
                    })
                    .collect::<Vec<_>>();
                (from, (to, mappers))
            })
            .collect::<HashMap<_, _>>();
        let final_values = seeds
            .iter()
            .map(|n| {
                let mut res = *n;
                let mut step = "seed";
                while let Some((next, mappers)) = parse_maps.get(&step) {
                    for &(init, end, len) in mappers {
                        if init <= res && res < init + len {
                            res = end + (res - init);
                            break;
                        }
                    }
                    step = next;
                }
                res
            })
            .min()
            .unwrap();
        Ok(final_values.to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
        #[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
        struct Range {
            init: usize,
            end: usize,
        }
        impl From<(usize, usize)> for Range {
            fn from((init, end): (usize, usize)) -> Self {
                Self { init, end }
            }
        }

        impl Range {
            fn overlap(&self, other: &Range) -> Option<Range> {
                let init = self.init.max(other.init);
                let end = self.end.min(other.end);
                if init < end {
                    Some((init, end).into())
                } else {
                    None
                }
            }

            fn apply_jump(&self, jump: i64) -> Range {
                let init = (self.init as i64 + jump) as usize;
                let end = (self.end as i64 + jump) as usize;
                (init, end).into()
            }

            fn split_range(
                &self,
                other: &RangeMap,
            ) -> Option<(Option<Range>, Range, Option<Range>)> {
                let Some(overlap) = self.overlap(&other.range) else {
                    return None;
                };

                let left = if self.init < overlap.init {
                    Some((self.init, overlap.init).into())
                } else {
                    None
                };
                let right = if overlap.end < self.end {
                    Some((overlap.end, self.end).into())
                } else {
                    None
                };
                Some((left, overlap, right))
            }
        }

        #[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Hash)]
        struct RangeMap {
            range: Range,
            jump: i64,
        }
        impl From<(usize, usize, i64)> for RangeMap {
            fn from((init, end, jump): (usize, usize, i64)) -> Self {
                Self {
                    range: Range { init, end },
                    jump,
                }
            }
        }

        fn apply_stage_transformation(
            mappers: &[RangeMap],
            ranges: HashSet<Range>,
        ) -> HashSet<Range> {
            let mut new_ranges = vec![];
            let modified_ranges = mappers.iter().fold(ranges, |rng, mapper| {
                apply_range_map(mapper, rng, &mut new_ranges)
            });
            new_ranges.into_iter().chain(modified_ranges).collect()
        }

        fn apply_range_map(
            mapper: &RangeMap,
            ranges: HashSet<Range>,
            new_ranges: &mut Vec<Range>,
        ) -> HashSet<Range> {
            let mut modified: Vec<Range> = vec![];
            for range in ranges {
                if let Some((left, overlap, right)) = range.split_range(mapper) {
                    if let Some(left) = left {
                        modified.push(left);
                    }

                    if let Some(right) = right {
                        modified.push(right);
                    }

                    new_ranges.push(overlap.apply_jump(mapper.jump));
                } else {
                    modified.push(range);
                }
            }

            modified.into_iter().collect()
        }

        let seeds = input[0]
            .strip_prefix("seeds: ")
            .unwrap()
            .split_whitespace()
            .filter_map(|s| s.parse::<usize>().ok())
            .collect::<Vec<_>>();

        let mut ranges: HashSet<Range> = seeds
            .chunks_exact(2)
            .map(|chunk| (chunk[0], chunk[0] + chunk[1]).into())
            .collect();

        let stages = input
            .split(|l| l.is_empty())
            .skip(1)
            .map(|col| {
                col[0]
                    .strip_suffix(" map:")
                    .unwrap()
                    .split_once("-to-")
                    .unwrap()
            })
            .collect::<HashMap<_, _>>();

        let modifiers = input
            .split(|l| l.is_empty())
            .skip(1)
            .map(|raw_stage| {
                let stage_name = raw_stage[0]
                    .strip_suffix(" map:")
                    .unwrap()
                    .split_once("-to-")
                    .unwrap()
                    .1;

                let stage_ranges: Vec<RangeMap> = raw_stage
                    .iter()
                    .skip(1)
                    .filter_map(|modifier| {
                        if let &[end, init, rng] = modifier
                            .split_ascii_whitespace()
                            .map(|v| v.parse::<usize>().unwrap())
                            .collect::<Vec<_>>()
                            .as_slice()
                        {
                            Some(RangeMap::from((init, init + rng, end as i64 - init as i64)))
                        } else {
                            None
                        }
                    })
                    .collect();

                (stage_name, stage_ranges)
            })
            .collect::<HashMap<_, _>>();

        let mut step = "seed";
        while let Some(next) = stages.get(&step) {
            step = next;
            ranges = apply_stage_transformation(&modifiers[next], ranges);
        }

        Ok(ranges
            .iter()
            .min_by_key(|Range { init, .. }| init)
            .unwrap()
            .init
            .to_string())
    }
}

crate::advent_test! {
    "../inputs/tests/day5_1.txt",
    "35",
    "../inputs/tests/day5_1.txt",
    "46"
}

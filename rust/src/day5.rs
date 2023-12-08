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

        impl RangeMap {
            fn split_range(
                &self,
                other: &RangeMap,
            ) -> Option<(Option<RangeMap>, RangeMap, Option<RangeMap>)> {
                let Some((left, overlap, right)) = self.range.split_range(&other.range) else {
                    return None;
                };
                println!("  Sections are: {:?}", (&left, &overlap, &right));
                let overlap = RangeMap {
                    range: overlap,
                    jump: self.jump,
                };

                let left_map = left.map(|left| {
                    if left.init == self.range.init {
                        RangeMap {
                            range: left,
                            jump: self.jump,
                        }
                    } else {
                        RangeMap {
                            range: left,
                            jump: other.jump,
                        }
                    }
                });
                let right_map = right.map(|right| {
                    if right.end == self.range.end {
                        RangeMap {
                            range: right,
                            jump: self.jump,
                        }
                    } else {
                        RangeMap {
                            range: right,
                            jump: other.jump,
                        }
                    }
                });
                Some((left_map, overlap, right_map))
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

            fn split_range(&self, other: &Range) -> Option<(Option<Range>, Range, Option<Range>)> {
                let Some(overlap) = self.overlap(other) else {
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

        println!("modifiers: {:#?}", modifiers);

        let mut step = "seed";
        while let Some(next) = stages.get(&step) {
            step = next;
            println!("==================Step: {:?} ================", step);
            let mut new_ranges = HashSet::with_capacity(ranges.len());
            let mut banned = HashSet::new();
            for input_range @ Range { init, end } in ranges {
                println!("\nChecking range: {:?} ====>>", input_range);
                if banned.contains(&input_range) {
                    println!("Range banned, skipping");
                    continue;
                }
                for range_map in modifiers[step].iter() {
                    print!(
                        "Checking {:?} against {:?} with jump {}\t|| ",
                        input_range, range_map.range, range_map.jump
                    );
                    let Some((left, overlap, right)) = input_range.split_range(&range_map.range)
                    else {
                        println!("No overlap, pushing {:?}\t", input_range);
                        new_ranges.insert((init, end).into());
                        continue;
                    };
                    print!("Overlap found: ({:?})\t", overlap);

                    new_ranges.remove(&input_range);
                    banned.insert(input_range);

                    if let Some(left) = left {
                        print!("Left: {:?}\t", left);
                        new_ranges.insert(left);
                    }
                    if let Some(right) = right {
                        print!("Right: {:?}\t", right);
                        new_ranges.insert(right);
                    }
                    let init = overlap.init as i64 + range_map.jump;
                    let end = overlap.end as i64 + range_map.jump;
                    println!("New range: {:?}\n", (init, end));
                    new_ranges.insert((init as usize, end as usize).into());
                    break;
                }
            }
            ranges = new_ranges;
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

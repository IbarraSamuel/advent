use crate::advent_utils::{AdventSolution, GenericResult};

use crate::advent_test;

pub struct Solution;

#[derive(Debug)]
struct Line {
    groups: Vec<usize>,
    boxes: Vec<BoxState>,
}

impl From<(&str, &str)> for Line {
    fn from((footprint, raw_groups): (&str, &str)) -> Self {
        let mut boxes: Vec<BoxState> = footprint
            .trim_matches('.')
            .split('.')
            .filter(|&v| !v.is_empty())
            .flat_map(|v| {
                if v.chars().all(|c| c == '#') {
                    // those full of # separated by dot.
                    vec![BoxState::Hash(v.len()), BoxState::Dot]
                } else {
                    v.split_inclusive('?')
                        .map(|v| BoxState::Unknown(v.len()))
                        .chain(vec![BoxState::Dot])
                        .collect()
                }
            })
            .collect();
        boxes.pop();

        let groups = raw_groups
            .split(',')
            .map(|v| dbg!(v.parse::<usize>()).unwrap())
            .collect();
        Self { groups, boxes }
    }
}

#[derive(Debug, Clone)]
enum BoxState {
    Unknown(usize),
    Hash(usize),
    Dot,
}

#[derive(Debug)]
struct Data {
    groups: String,
    variations: Vec<Variation>,
}

#[derive(Debug)]
struct Variation {
    groups: String,
    remaining: String,
    accum: usize,
    divergence_points: Vec<usize>,
}

impl From<(&str, &str)> for Data {
    fn from((footprint, groups): (&str, &str)) -> Self {
        let groups = groups.to_string();
        let variable_len = footprint.chars().filter(|&c| c == '?').count();
        let mut variations = Vec::with_capacity(variable_len.pow(2));
        variations.push(Variation {
            groups: String::new(),
            accum: 0,
            remaining: footprint.to_string(),
            divergence_points: footprint
                .char_indices()
                .filter_map(|(i, c)| if c == '?' { Some(i) } else { None })
                .rev()
                .collect(),
        });
        Self { groups, variations }
    }
}

fn calc_options(data: Data) -> usize {
    // println!();
    let mut variations = data.variations;
    let mut count = 0;

    while let Some(mut variation) = variations.pop() {
        if variation.groups == data.groups {
            // means that we found a valid one.
            count += 1;
            continue;
        }
        // println!("working on {:?} -- {:?}", &data.groups, &variation);
        if variation.divergence_points.is_empty() && variation.remaining.is_empty() {
            if variation.accum == 0 {
                // if there is no more divergence points, and the remaining is empty, it means that the variation is not valid.
                continue;
            }
            let new_group = update_group(&variation.groups, variation.accum);
            if still_valid(&new_group, &data.groups) {
                variations.push(Variation {
                    groups: new_group,
                    remaining: String::new(),
                    accum: 0,
                    divergence_points: Vec::new(),
                });
            }
            // if there is no more divergence points, and the remaining is empty, it means that the variation is not valid.
            continue;
        }
        let Some(div_point) = variation.divergence_points.pop() else {
            // in case there is no more divergence points, but still the groups are not the same, it means that the variation is not valid.
            if let Some(new_group) =
                calc_new_group(&variation.remaining.clone(), &mut variation, &data.groups)
            {
                let new_group = update_group(&new_group, variation.accum);
                if still_valid(&new_group, &data.groups) {
                    variations.push(Variation {
                        groups: new_group,
                        remaining: String::new(),
                        accum: 0,
                        divergence_points: Vec::new(),
                    });
                }
            };

            continue;
        };
        let new_div_points = variation
            .divergence_points
            .iter()
            .map(|p| *p - div_point - 1)
            .collect::<Vec<_>>();

        let to_check = variation.remaining[..div_point].to_string();
        let var_remaining = variation.remaining[div_point + 1..].to_string();

        let Some(new_groups) = calc_new_group(&to_check, &mut variation, &data.groups) else {
            continue;
        };

        // if we use # in the position...
        let hash_accum = variation.accum + 1;
        variations.push(Variation {
            groups: new_groups.clone(),
            remaining: var_remaining.clone(),
            accum: hash_accum,
            divergence_points: new_div_points.clone(),
        });

        let new_groups = update_group(&new_groups, variation.accum);
        if still_valid(&new_groups, &data.groups) {
            variations.push(Variation {
                groups: new_groups,
                remaining: var_remaining,
                accum: 0,
                divergence_points: new_div_points,
            });
        }
    }
    // println!(
    //     "valid ones are: {:?}",
    //     &data
    //         .variations
    //         .iter()
    //         .map(|v| &v.groups)
    //         .collect::<Vec<_>>()
    // );
    count
}

fn calc_new_group(to_check: &str, variation: &mut Variation, guide_group: &str) -> Option<String> {
    to_check
        .chars()
        .try_fold(variation.groups.clone(), |acc, n| {
            if n == '.' {
                let acum = update_group(&acc, variation.accum);
                variation.accum = 0;
                if still_valid(&acum, guide_group) {
                    Some(acum)
                } else {
                    None
                }
            } else if n == '#' {
                variation.accum += 1;
                Some(acc)
            } else {
                unreachable!("Invalid char: {}", n);
            }
        })
}

fn update_group(group: &str, value: usize) -> String {
    if value == 0 {
        group.to_string()
    } else if group.is_empty() {
        format!("{}", value)
    } else {
        format!("{},{}", group, value)
    }
}

fn still_valid(groups: &str, variation_group: &str) -> bool {
    variation_group.starts_with(groups)
}

fn still_possible(boxes: &[BoxState], groups: &[usize]) -> bool {
    let init_hashes_match = boxes
        .iter()
        .filter(|v| !matches!(v, BoxState::Dot))
        .take_while(|v| matches!(v, BoxState::Hash(_)))
        .zip(groups)
        .all(|bs| match bs {
            (BoxState::Hash(v), g) => v == g,
            _ => false,
        });
    let not_too_much_hashes = boxes
        .iter()
        .filter(|v| matches!(v, BoxState::Hash(_)))
        .count()
        <= groups.len();
    let not_less_spaces =
        boxes.iter().filter(|v| !matches!(v, BoxState::Dot)).count() >= groups.len();
    let too_many_unknowns = boxes
        .iter()
        .filter(|v| !matches!(v, BoxState::Dot))
        .enumerate()
        .find_map(|(i, v)| match v {
            BoxState::Unknown(unk_len) => Some(*unk_len > groups.get(i).unwrap_or(&0) + 1),
            _ => None,
        })
        .unwrap_or(false);

    // if !init_hashes_match {
    //     println!("-- NOT POSSIBLE PATH because hashes don't match");
    // } else if !not_too_much_hashes {
    //     println!("-- NOT POSSIBLE PATH because too much hashes");
    // } else if !not_less_spaces {
    //     println!("-- NOT POSSIBLE PATH because not enough spaces");
    // }
    init_hashes_match && not_too_much_hashes && not_less_spaces && !too_many_unknowns
}

fn see_options(boxes: &[BoxState], groups: &[usize]) -> usize {
    // print!("{} ON {:?} -- ", "----".repeat(depth), &boxes);
    if !still_possible(boxes, groups) {
        return 0;
    }

    if let Some((idx, &BoxState::Unknown(unknown_len))) = boxes
        .iter()
        .enumerate()
        .find(|(_, b)| matches!(b, BoxState::Unknown { .. }))
    {
        // print!("-- Found unknown with len {:?} at {} --", unknown_len, idx);
        // if groups
        //     .get(idx)
        //     .map(|n| unknown_len > n + 1)
        //     .unwrap_or(false)
        // {
        //     println!(
        //         "-- NOT POSSIBLE PATH because unknown is too big: {} > {} + 1 = {}",
        //         unknown_len,
        //         groups.get(idx).unwrap_or(&0),
        //         unknown_len > groups.get(idx).unwrap_or(&0) + 1
        //     );
        //     return 0;
        // }

        // println!("-- Searching...");
        let mut dot_box = boxes.to_vec();

        if unknown_len == 1 {
            // means that the box was a unique question mark with no other values in there
            dot_box[idx] = BoxState::Dot;
        } else {
            // means that there was some fixed values, so we can replace it to be the val - 1
            dot_box[idx] = BoxState::Hash(unknown_len - 1);
            dot_box.insert(idx + 1, BoxState::Dot);
        }

        let mut hash_box = boxes.to_vec();

        match boxes.get(idx + 1) {
            Some(BoxState::Unknown(current)) => {
                // If the next one is still not fixed, I will add the data to the next one, and remove the current one.
                hash_box[idx + 1] = BoxState::Unknown(current + unknown_len);
                hash_box.remove(idx);
            }
            Some(BoxState::Hash(_)) | Some(BoxState::Dot) | None => {
                // if the next one is fixed or there is no next, I will update the current one to be fixed.
                hash_box[idx] = BoxState::Hash(unknown_len);
            }
        }
        see_options(&hash_box, groups) + see_options(&dot_box, groups)
    } else if boxes
        .iter()
        .filter_map(|v| match v {
            BoxState::Hash(v) => Some(*v),
            _ => None,
        })
        .collect::<Vec<_>>()
        .eq(groups)
    {
        // println!("-- VALID...");
        1
    } else {
        // println!("-- NOT VALID BUT COMPLETED...");
        0
    }
}

fn calculate_possibilities(input: &str) -> usize {
    let raw_line = input.split_once(' ').unwrap();
    let line = Line::from(raw_line);
    // println!(
    //     "START for LINE {:?} and Groups {:?}\n",
    //     &line.boxes, &line.groups
    // );
    see_options(&line.boxes, &line.groups)
    // println!("count: {}\n\n", count);
    // count
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let combinations = input
            .into_iter()
            .map(|s| {
                let (footprint, groups) = s.split_once(' ').unwrap();
                let data = Data::from((footprint, groups));
                calc_options(data)
            })
            .sum::<usize>();

        Ok(combinations)
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        // todo!()
        let combinations = input
            .into_iter()
            .map(|line| {
                let (footprint, groups) = line.split_once(' ').unwrap();
                let new_footprint = [footprint; 5].join("?");
                let new_groups = [groups; 5].join(",");

                println!("{} -- {}", new_footprint, new_groups);
                let data = Data::from((new_footprint.as_str(), new_groups.as_str()));
                calc_options(data)
            })
            .sum::<usize>();
        Ok(combinations)
    }
}

advent_test!(
    "../inputs/tests/day12.txt",
    21,
    "../inputs/tests/day12.txt",
    525152
);

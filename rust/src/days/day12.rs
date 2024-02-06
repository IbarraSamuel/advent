use crate::advent_tests;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;


use std::io::{self};

const fn should_insert_it(
    footprint: &[u8],
    group_size: usize,
    groups_len: usize,
    current_position: usize,
    group_idx: usize,
) -> bool {
    let mut i = current_position;
    let mut contains_hash = false;
    while i < footprint.len() {
        if footprint[i] == b'.' && i < current_position + group_size {
            // The group size shifted by the current position should not contain a dot, if it does, we skip.
            return false;
        }
        if footprint[i] == b'#' && i >= current_position + group_size {
            contains_hash = true;
            break;
        }
        i += 1;
    }
    // The group size shifted by the current position should be inside the footprint, if not, we skip.
    current_position + group_size - 1 < footprint.len()
    // then we will check one of two conditions:
    && (
        // if we are at the last group, we will check if the rest of the footprint is empty (should not have more hashes after).
        (group_idx == groups_len - 1
        && !contains_hash)
        // if we are not at the last group, we will check if the next position is empty (should not have a hash).
        || (group_idx < groups_len - 1
            && current_position + group_size < footprint.len()
            && footprint[current_position + group_size] != b'#'))
}

fn solve(input: Vec<String>) -> io::Result<usize> {
    let ways = input
        .iter()
        .map(|line| {
            let (footprint, raw_groups) = line.split_once(' ').unwrap();
            let groups = raw_groups.split(',').map(|n| n.parse::<usize>().unwrap());
            let all_groups_size = groups.clone().sum::<usize>(); // total amount of hashes needed.
            let groups_len = groups.clone().count();

            groups
                .enumerate()
                .fold(
                    (vec![(0, 1)], all_groups_size),
                    |(acc, rem_group_size), (group_idx, group_size)| {
                        (
                            acc.iter().fold(
                                Vec::with_capacity(30),
                                |mut new_positions, &(k, v)| {
                                    // starting from the first position, we go from our position to the last position we can use without compromising next groups.
                                    for current_position in k..(footprint.len() - rem_group_size
                                        + group_size
                                        + groups_len
                                        - group_idx
                                        - 1)
                                    {
                                        if should_insert_it(
                                            footprint.as_bytes(),
                                            group_size,
                                            groups_len,
                                            current_position,
                                            group_idx,
                                        ) {
                                            if let Some(last) =
                                                new_positions.iter_mut().find(|(pos, _)| {
                                                    *pos == current_position + group_size + 1
                                                })
                                            {
                                                *last = (last.0, last.1 + v);
                                            } else {
                                                new_positions
                                                    .push((current_position + group_size + 1, v));
                                            }
                                        }

                                        if &footprint[current_position..current_position + 1] == "#"
                                        {
                                            break;
                                        }
                                    }
                                    new_positions
                                },
                            ),
                            rem_group_size - group_size,
                        )
                    },
                )
                .0
                .iter()
                .map(|(_, v)| v)
                .sum::<usize>()
        })
        .sum::<usize>();

    Ok(ways)
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let combinations = solve(input)?;
        Ok(combinations)
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        // todo!();
        let new_input = input
            .into_iter()
            .map(|line| {
                let (footprint, groups) = line.split_once(' ').unwrap();
                let new_footprint = [footprint; 5].join("?");
                let new_groups = [groups; 5].join(",");
                [new_footprint, new_groups].join(" ")
            })
            .collect::<Vec<_>>();
        let combinations = solve(new_input)?;
        Ok(combinations)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day12.txt" => 21
    ),
    part 2 => (
        "../inputs/tests/day12.txt" => 525152
    )
);

// #[test]
// fn group_in_vec() {
//     let input = vec!["1 1,2,3".to_string()];
//     assert_eq!(result, 1);
// }
// #[test]
// fn test_should_insert_it() {
//     let footprint = "???.###";
//     let group_size = 1;
//     let current_position = 0;
//     let group_idx = 0;

//     let n = current_position;
//     let groups_len = group_size;
//     let footprint_len = footprint.len();

//     let first_result = n + group_size - 1 < footprint_len
//     // The group size shifted by the current position should not contain a dot, if it does, we skip.
//     && !footprint[n..n + group_size].contains('.')
//     // then we will check one of two conditions:
//     && (
//         // if we are at the last group, we will check if the rest of the footprint is empty (should not have more hashes after).
//         (group_idx == groups_len - 1
//         && !footprint[n + group_size..].contains('#'))
//         // if we are not at the last group, we will check if the next position is empty (should not have a hash).
//         || (group_idx < groups_len - 1
//             && n + group_size < footprint_len
//             && footprint[n + group_size..n +group_size + 1] != *"#"));
//     let val = should_insert_it(footprint, group_size, current_position, group_idx);
//     assert_eq!(val, first_result);
// }

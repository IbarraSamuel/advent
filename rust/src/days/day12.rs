use crate::advent_utils::{AdventSolution, GenericResult};
use crate::{advent_tests};

pub struct Solution;

use std::collections::HashMap;
use std::io::{self};

fn solve(input: Vec<String>) -> io::Result<usize> {
    let mut ways = 0;

    for row in input {
        // let row = line?;
        let (footprint, raw_groups) = row.split_once(' ').unwrap();
        let groups: Vec<usize> = raw_groups.split(',').map(|n| n.parse().unwrap()).collect();
        let mut remaining_groups_size = groups.iter().sum::<usize>(); // total amount of hashes needed.
        let footprint_len = footprint.len();
        let groups_len = groups.len();
        let mut remaining_groups = groups_len;

        let mut positions: HashMap<usize, usize> = HashMap::new();
        positions.insert(0, 1);
        // For each group in the groups, we will process each one.
        for (group_idx, &group_size) in groups.iter().enumerate() {
            // we will have a set of valid positions for each group differently.
            let mut new_positions: HashMap<usize, usize> = HashMap::new();
            remaining_groups_size -= group_size;
            remaining_groups -= 1;
            let needed_space_for_the_rest = remaining_groups_size - remaining_groups;
            // for each position in the positions collected from the previous group, we will process the new positions.
            for (&k, &v) in positions.iter() {
                // starting from the first position, we go from our position to the last position we can use without compromising next groups.
                for n in k..(footprint_len - needed_space_for_the_rest) {
                    // The group size shifted by the current position should be inside the footprint, if not, we skip.
                    if n + group_size - 1 < footprint_len
                        // The group size shifted by the current position should not contain a dot, if it does, we skip.
                        && !footprint[n..n + group_size].contains('.')
                        // then we will check one of two conditions:
                        && (
                            // if we are at the last group, we will check if the rest of the footprint is empty (should not have more hashes after).
                            (group_idx == groups_len - 1
                            && !footprint[n + group_size..].contains('#'))
                            // if we are not at the last group, we will check if the next position is empty (should not have a hash).
                            || (group_idx < groups_len - 1
                                && n + group_size < footprint_len
                                && footprint.chars().nth(n + group_size).unwrap() != '#'))
                    {
                        // if all conditions are met, we will add the new position to the new positions.
                        *new_positions.entry(n + group_size + 1).or_insert(0) += v;
                    }
                    if footprint.chars().nth(n).unwrap() == '#' {
                        break;
                    }
                }
            }
            positions = new_positions;
        }
        ways += positions.values().sum::<usize>();
    }
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

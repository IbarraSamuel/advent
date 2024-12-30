use std::collections::HashMap;

use crate::advent_tests;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

enum Direction {
    Left,
    Right,
}

impl From<char> for Direction {
    fn from(value: char) -> Self {
        match value {
            'L' => Self::Left,
            'R' => Self::Right,
            _ => panic!("Unknown direction: {}", value),
        }
    }
}

fn lcm(first: usize, second: usize) -> usize {
    let (mut max, mut min) = (first.max(second), first.min(second));

    while max % min != 0 {
        (max, min) = (min, max % min);
    }

    first * second / min
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let pattern = input[0].chars().map(Direction::from).collect::<Vec<_>>();

        let nodes = input
            .iter()
            .skip(2)
            .map(|line| {
                let (name, childs) = line.split_once(" = ").unwrap();
                let (left, right) = childs
                    .strip_prefix('(')
                    .unwrap()
                    .strip_suffix(')')
                    .unwrap()
                    .split_once(", ")
                    .unwrap();
                (name, (left, right))
            })
            .collect::<HashMap<_, _>>();

        let mut node_name = "AAA";
        let mut iterations = 0;

        for d in pattern.iter().cycle() {
            iterations += 1;
            node_name = match d {
                Direction::Left => nodes[node_name].0,
                Direction::Right => nodes[node_name].1,
            };
            if node_name == "ZZZ" {
                break;
            }
        }

        Ok(iterations)
    }

    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let pattern = input[0].chars().map(Direction::from).collect::<Vec<_>>();

        let nodes = input
            .iter()
            .skip(2)
            .map(|line| {
                let (name, childs) = line.split_once(" = ").unwrap();
                let (left, right) = childs
                    .strip_prefix('(')
                    .unwrap()
                    .strip_suffix(')')
                    .unwrap()
                    .split_once(", ")
                    .unwrap();
                (name, (left, right))
            })
            .collect::<HashMap<_, _>>();

        let init_nodes = nodes
            .keys()
            .cloned()
            .filter(|&k| k.ends_with('A'))
            .collect::<Vec<_>>();

        let cycles = init_nodes
            .iter()
            .map(|mut init| {
                let mut z_values = HashMap::new();
                for (i, dir) in pattern.iter().cycle().enumerate() {
                    if init.ends_with('Z') {
                        if z_values.contains_key(init) {
                            return (i) - z_values[init];
                        }
                        z_values.entry(init).or_insert(i);
                    }
                    init = match &dir {
                        Direction::Left => &nodes[init].0,
                        Direction::Right => &nodes[init].1,
                    };
                }
                panic!("No Z found");
            })
            .collect::<Vec<_>>();

        let final_prod = cycles.into_iter().reduce(lcm).unwrap();

        Ok(final_prod)
    }
}

advent_tests!(
    part 1 => (
        "../../tests/2023/day8_1.txt" => 2
    ),
    part 2 => (
        "../../tests/2023/day8_2.txt" => 6
    )
);

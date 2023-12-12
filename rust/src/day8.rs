use std::collections::HashMap;

use rayon::iter::{
    IntoParallelIterator, IntoParallelRefIterator, ParallelBridge, ParallelIterator,
};
use rayon::vec;

use crate::advent_test;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

struct Graph {
    nodes: HashMap<Box<str>, Node>,
}

struct Node {
    left_edge: Option<Box<Edge>>,
    right_edge: Option<Box<Edge>>,
}

struct Edge {
    from: Box<str>,
    to: Box<str>,
}

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

impl Iterator for Direction {
    type Item = Self;

    fn next(&mut self) -> Option<Self::Item> {
        match self {
            Self::Left => {
                *self = Self::Right;
                Some(Self::Left)
            }
            Self::Right => {
                *self = Self::Left;
                Some(Self::Right)
            }
        }
    }
}

fn lcm(first: usize, second: usize) -> usize {
    first * second / gcd(first, second)
}

fn gcd(first: usize, second: usize) -> usize {
    let mut max = first;
    let mut min = second;
    if min > max {
        let val = max;
        max = min;
        min = val;
    }

    loop {
        let res = max % min;
        if res == 0 {
            return min;
        }

        max = min;
        min = res;
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
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

        Ok(iterations.to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
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
            .par_bridge()
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

        Ok(final_prod.to_string())
    }
}

advent_test! {
    "../inputs/tests/day8_1.txt",
    "2",
    "../inputs/tests/day8_2.txt",
    "6"
}

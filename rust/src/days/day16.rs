use std::{borrow::BorrowMut, collections::HashSet, io::Write};

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

const MIRRORS: [u8; 4] = [b'/', b'\\', b'|', b'-'];

enum Mirror {
    Zero,
    FortyFive,
    Ninety,
    OneThirtyFive,
}

impl From<&u8> for Mirror {
    fn from(value: &u8) -> Self {
        match value {
            b'/' => Mirror::FortyFive,
            b'\\' => Mirror::OneThirtyFive,
            b'|' => Mirror::Ninety,
            b'-' => Mirror::Zero,
            _ => unreachable!("Invalid mirror"),
        }
    }
}

impl Mirror {
    fn reflect(
        &self,
        direction: &Direction,
        (x, y): (usize, usize),
    ) -> (Option<Direction>, Option<Direction>) {
        match *self {
            Mirror::Zero => match direction {
                Direction::Left { .. } => (Some(Direction::Left { x, y }), None),
                Direction::Right { .. } => (Some(Direction::Right { x, y }), None),
                Direction::Up { .. } | Direction::Down { .. } => (
                    Some(Direction::Right { x, y }),
                    Some(Direction::Left { x, y }),
                ),
            },
            Mirror::FortyFive => match direction {
                Direction::Left { .. } => (Some(Direction::Down { x, y }), None),
                Direction::Right { .. } => (Some(Direction::Up { x, y }), None),
                Direction::Up { .. } => (Some(Direction::Right { x, y }), None),
                Direction::Down { .. } => (Some(Direction::Left { x, y }), None),
            },
            Mirror::Ninety => match direction {
                Direction::Left { .. } | Direction::Right { .. } => {
                    (Some(Direction::Up { x, y }), Some(Direction::Down { x, y }))
                }
                Direction::Up { .. } => (Some(Direction::Up { x, y }), None),
                Direction::Down { .. } => (Some(Direction::Down { x, y }), None),
            },
            Mirror::OneThirtyFive => match direction {
                Direction::Left { .. } => (Some(Direction::Up { x, y }), None),
                Direction::Right { .. } => (Some(Direction::Down { x, y }), None),
                Direction::Up { .. } => (Some(Direction::Left { x, y }), None),
                Direction::Down { .. } => (Some(Direction::Right { x, y }), None),
            },
        }
    }
}

pub struct Solution;

#[derive(Debug, PartialEq, Eq, Hash)]
enum Direction {
    Left { x: usize, y: usize },
    Right { x: usize, y: usize },
    Up { x: usize, y: usize },
    Down { x: usize, y: usize },
}

impl Direction {
    fn overlaps(&self, other: &Direction, ctx: &[&[u8]], mut non: Vec<String>) -> bool {
        let d = self.ray_distance(ctx, &mut non);
        let d2 = other.ray_distance(ctx, &mut non);
        if d == 0 || d2 == 0 {
            return false;
        }

        match (self, other) {
            (&Direction::Left { x, y }, &Direction::Up { x: x2, y: y2 }) => {
                x > x2 && y < y2 && x < x2 + 2 + d && y + 2 + d2 > y2
            }
            (&Direction::Left { x, y }, &Direction::Down { x: x2, y: y2 }) => {
                x > x2 && y > y2 && x < x2 + 2 + d && y < y2 + 2 + d2
            }
            (&Direction::Right { x, y }, &Direction::Up { x: x2, y: y2 }) => {
                x < x2 && y < y2 && x + 2 + d > x2 && y + 2 + d2 > y2
            }
            (&Direction::Right { x, y }, &Direction::Down { x: x2, y: y2 }) => {
                x < x2 && y > y2 && x + 2 + d > x2 && y < y2 + 2 + d2
            }
            (&Direction::Up { x, y }, &Direction::Left { x: x2, y: y2 }) => {
                x < x2 && y > y2 && x + 2 + d2 > x2 && y < y2 + 2 + d
            }
            (&Direction::Up { x, y }, &Direction::Right { x: x2, y: y2 }) => {
                x > x2 && y > y2 && x < x2 + 2 + d2 && y < y2 + 2 + d
            }
            (&Direction::Down { x, y }, &Direction::Left { x: x2, y: y2 }) => {
                x < x2 && y < y2 && x + 2 + d2 > x2 && y + 2 + d > y2
            }
            (&Direction::Down { x, y }, &Direction::Right { x: x2, y: y2 }) => {
                x > x2 && y < y2 && x < x2 + 2 + d2 && y + 2 + d > y2
            }
            _ => false,
        }
    }

    fn next(&self, ctx: &[&[u8]]) -> (Option<Self>, Option<Self>) {
        match *self {
            Direction::Left { x, y } => ctx[y][0..x]
                .iter()
                .enumerate()
                .rev()
                .find(|&(_, a)| MIRRORS.contains(a))
                .map(|(xi, v)| Mirror::from(v).reflect(self, (xi, y)))
                .unwrap_or((None, None)),
            Direction::Right { x, y } => ctx[y][x + 1..]
                .iter()
                .enumerate()
                .find(|&(_, a)| MIRRORS.contains(a))
                .map(|(xi, v)| Mirror::from(v).reflect(self, (x + 1 + xi, y)))
                .unwrap_or((None, None)),
            Direction::Up { x, y } => ctx[0..y]
                .iter()
                .enumerate()
                .rev()
                .map(|(yi, ln)| (yi, ln[x]))
                .find(|&(_, a)| MIRRORS.contains(&a))
                .map(|(yi, v)| Mirror::from(&v).reflect(self, (x, yi)))
                .unwrap_or((None, None)),
            Direction::Down { x, y } => ctx[y + 1..]
                .iter()
                .enumerate()
                .map(|(yi, ln)| (yi, ln[x]))
                .find(|&(_, a)| MIRRORS.contains(&a))
                .map(|(yi, v)| Mirror::from(&v).reflect(self, (x, y + 1 + yi)))
                .unwrap_or((None, None)),
        }
    }

    fn ray_distance(&self, ctx: &[&[u8]], visualizer: &mut [String]) -> usize {
        let distance = match *self {
            Direction::Left { x, y } => ctx[y][0..x]
                .iter()
                .rev()
                .take_while(|a| !MIRRORS.contains(a))
                .count(),
            Direction::Right { x, y } => ctx[y][x + 1..]
                .iter()
                .take_while(|a| !MIRRORS.contains(a))
                .count(),
            Direction::Up { x, y } => ctx[0..y]
                .iter()
                .rev()
                .map(|ln| ln[x])
                .take_while(|a| !MIRRORS.contains(a))
                .count(),
            Direction::Down { x, y } => ctx[y + 1..]
                .iter()
                .map(|ln| ln[x])
                .take_while(|a| !MIRRORS.contains(a))
                .count(),
        };
        match *self {
            Direction::Left { x, y } => {
                visualizer[y].replace_range(x - distance..=x, &"<".repeat(distance + 1))
            }
            Direction::Right { x, y } => {
                visualizer[y].replace_range(x..=x + distance, &">".repeat(distance + 1))
            }
            Direction::Up { x, y } => {
                visualizer[y - distance..=y]
                    .iter_mut()
                    .for_each(|ln| ln.replace_range(x..=x, "^"));
            }
            Direction::Down { x, y } => {
                visualizer[y..=y + distance]
                    .iter_mut()
                    .for_each(|ln| ln.replace_range(x..=x, "v"));
            }
        };

        std::io::stdout().flush().unwrap();
        distance
    }
}

fn calculate(ctx: &[&[u8]]) -> usize {
    let mut queue = Vec::with_capacity(
        ctx.iter()
            .map(|ln| ln.iter().filter(|a| MIRRORS.contains(a)).count())
            .sum::<usize>(),
    );
    queue.push(Direction::Right { x: 0, y: 0 });
    let mut used: HashSet<Direction> = Default::default();
    let mut visualizer = ctx
        .iter()
        .map(|ln| String::from_utf8_lossy(ln).to_string())
        .collect::<Vec<_>>();

    while let Some(next_direction) = queue.pop() {
        if let (Some(new_direction), other) = next_direction.next(ctx) {
            if !used.contains(&new_direction) {
                queue.push(new_direction);
            }
            if let Some(other_direction) = other {
                if !used.contains(&other_direction) {
                    queue.push(other_direction);
                }
            }
        }
        used.insert(next_direction);
    }

    println!("Used: {:#?}", used);

    let mut overlapping = 0;
    for i in used.iter() {
        for a in used.iter() {
            if i != a && i.overlaps(a, ctx, visualizer.clone()) {
                overlapping += 1;
            }
        }
    }

    let res = used
        .iter()
        .map(|dir| match dir {
            Direction::Up { x, y }
            | Direction::Down { x, y }
            | Direction::Left { x, y }
            | Direction::Right { x, y } => (x, y),
        })
        .collect::<HashSet<_>>()
        .len()
        + used
            .into_iter()
            .map(|direction| direction.ray_distance(ctx, &mut visualizer))
            .sum::<usize>()
        - overlapping / 2;

    println!("{}\n\n", visualizer.join("\n"));
    res
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let new_input = input.iter().map(|s| s.as_bytes()).collect::<Vec<_>>();
        Ok(calculate(&new_input))
        // Ok(0)
    }

    fn part2(_input: Vec<String>) -> GenericResult<usize> {
        Ok(0)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day16.txt" => 46
    )
);

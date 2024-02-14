use std::collections::HashSet;

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

const MIRRORS: [u8; 4] = [b'/', b'\\', b'|', b'-'];

pub struct Solution;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
enum Direction {
    Left { x: usize, y: usize },
    Right { x: usize, y: usize },
    Up { x: usize, y: usize },
    Down { x: usize, y: usize },
}

impl Direction {
    fn next(&self, ctx: &[&[u8]]) -> (Option<Self>, Option<Self>) {}

    fn ray_distance(&self, ctx: &[&[u8]]) -> usize {}
}

fn calculate(ctx: &[&[u8]]) -> usize {
    let mut queue = Vec::with_capacity(
        ctx.iter()
            .map(|ln| ln.iter().filter(|a| MIRRORS.contains(a)).count())
            .sum::<usize>(),
    );
    queue.push(Direction::Right { x: 0, y: 0 });
    let mut used: HashSet<Direction> = Default::default();
    while let Some(new_direction) = queue.pop() {
        used.insert(new_direction.clone());
        if let (Some(new_direction), other) = new_direction.next(ctx) {
            if !used.contains(&new_direction) {
                queue.push(new_direction);
            }
            if let Some(other_direction) = other {
                if !used.contains(&other_direction) {
                    queue.push(other_direction);
                }
            }
        }
    }
    used.len()
        + used
            .into_iter()
            .map(|direction| direction.ray_distance(ctx))
            .sum::<usize>();
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let new_input = input.iter().map(|s| s.as_bytes()).collect::<Vec<_>>();
        Ok(calculate(&new_input))
    }

    fn part2(_input: Vec<String>) -> GenericResult<usize> {
        todo!()
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day16.txt" => 46
    )
);

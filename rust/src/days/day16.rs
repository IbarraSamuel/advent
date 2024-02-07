use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

pub struct Solution;

#[derive(Debug)]
struct Position(usize, usize);

fn calc_reflections(input: &[String]) -> usize {
    let mut reflections = 0;
    let (first_line, remaining) = input[0].split_once(['/', '\\', '|']).unwrap_or((&input[0], ""));
    if remaining.is_empty() {
        return input[0].len();
    }

    
    while let Some((x,y)) = 
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        Ok(calc_reflections(&input))
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        todo!()
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day16.txt" => 46
    )
);

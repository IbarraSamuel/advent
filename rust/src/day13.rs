use crate::advent_test;

use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let mut secuence = vec![];
        let horizontal_values = input
            .iter()
            .map(|line| {
                line.char_indices()
                    .map(|(idx, c)| idx * 10 + c.to_digit(10).unwrap() as usize)
                    .sum::<usize>()
            })
            .collect::<Vec<_>>();

        for v in horizontal_values {
            if !secuence.contains(&v) {
                secuence.push(v);
            }
            else if {}
            
        }
        
        let vertical_values = (0..input[0].len())
            .map(|idx| {
                input
                    .iter()
                    .map(|line| line.chars().nth(idx).unwrap())
                    .enumerate()
                    .map(|(idx, c)| idx * 10 + c.to_digit(10).unwrap() as usize)
                    .sum::<usize>()
            })
            .collect::<Vec<_>>();
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        todo!()
    }
}

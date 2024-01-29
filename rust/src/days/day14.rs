use crate::advent_utils::{AdventSolution, GenericResult};
use crate::{advent_tests};

pub struct Solution;

fn calc_weight(column: String) -> usize {
    column
        .split('#')
        .zip(format!("#{column}").char_indices().filter_map(|(idx, c)| {
            if c == '#' {
                Some(column.len() + 1 - idx)
            } else {
                None
            }
        }))
        .map(|(v, idx)| {
            let amount = v.chars().filter(|&c| c == 'O').count();
            (idx - amount..idx).sum::<usize>()
        })
        .sum::<usize>()
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let val = (0..input[0].len())
            .map(|col| {
                calc_weight(
                    input
                        .iter()
                        .map(|row| row.chars().nth(col).unwrap())
                        .collect::<String>(),
                )
            })
            .sum::<usize>();
        Ok(val)
    }

    fn part2(_input: Vec<String>) -> GenericResult<usize> {
        Ok(0)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day14.txt" => 136
    ),
    part 2 => (
        "../inputs/tests/day14.txt" => 0
    )
);

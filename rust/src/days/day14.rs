use crate::advent_tests;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

#[derive(Hash, PartialEq, Eq, Clone, Debug)]
pub struct Maze(Vec<String>);

impl Maze {
    fn calculate(&self) -> usize {
        self.0
            .iter()
            .map(|line| {
                line.char_indices()
                    .filter_map(|(idx, v)| if v == 'O' { Some(idx + 1) } else { None })
                    .sum::<usize>()
            })
            .sum::<usize>()
    }

    fn rotate(&self) -> Self {
        Maze(
            (0..self.0[0].len())
                .map(|col| {
                    self.0.iter().rev().fold(String::new(), |mut acc, row| {
                        acc.push_str(&row[col..col + 1]);
                        acc
                    })
                })
                .collect::<_>(),
        )
    }

    fn tilt_right(&self) -> Self {
        Maze(
            self.0
                .iter()
                .map(|line| {
                    let mut new_line = line.split('#').fold(String::new(), |mut acc, rng| {
                        let count = rng.chars().filter(|&c| c == 'O').count();
                        acc.push_str(&".".repeat(rng.len() - count));
                        acc.push_str(&"O".repeat(count));
                        acc.push('#');
                        acc
                    });
                    new_line.pop();
                    new_line
                })
                .collect::<Vec<_>>(),
        )
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        Ok(Maze(input).rotate().tilt_right().calculate())
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        let mut positions: Vec<Maze> = Vec::with_capacity(1000);
        let (cycles, iteration);
        positions.push(Maze(input));

        loop {
            let new_maze = positions
                .last()
                .unwrap()
                .rotate()
                .tilt_right()
                .rotate()
                .tilt_right()
                .rotate()
                .tilt_right()
                .rotate()
                .tilt_right();
            if let Some((index, _)) = positions.iter().enumerate().find(|(_, a)| a == &&new_maze) {
                iteration = positions.len();
                cycles = iteration - index;
                break;
            }

            positions.push(new_maze);
        }
        let valid_idx = (1e9 as usize - iteration) % cycles + (iteration - cycles);
        let final_position = &positions[valid_idx];
        Ok(final_position.rotate().calculate())
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day14.txt" => 136
    ),
    part 2 => (
        "../inputs/tests/day14.txt" => 64
    )
);

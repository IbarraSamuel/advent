use std::collections::HashMap;

use crate::advent_tests;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

#[derive(Hash, PartialEq, Eq, Clone, Debug)]
pub struct Maze(Vec<String>);

impl Maze {
    fn calculate(self) -> usize {
        self.rotate()
            .0
            .into_iter()
            .map(|mut line| {
                line.insert(0, '#');
                let indices = &line
                    .char_indices()
                    .filter_map(|(a, b)| if b == '#' { Some(a) } else { None })
                    .collect::<Vec<usize>>();
                line.split_inclusive('#')
                    .zip(indices)
                    .map(|(rng, &idx)| {
                        let count = rng.chars().filter(|&c| c == 'O').count();
                        (idx - count..idx).sum::<usize>()
                    })
                    .sum::<usize>()
            })
            .sum::<usize>()
    }

    fn rotate(self) -> Self {
        Maze(
            (0..self.0[0].len())
                .map(|col| {
                    self.0
                        .iter()
                        .rev()
                        .map(|row| row.chars().nth(col).unwrap())
                        .collect::<String>()
                })
                .collect::<_>(),
        )
    }

    fn tilt_right(self) -> Self {
        Maze(
            self.0
                .into_iter()
                .map(|mut line| {
                    line.split_inclusive('#')
                        .map(|rng| {
                            let hash = if rng.contains('#') { "#" } else { "" };
                            let len = rng.len();
                            let count = rng.chars().filter(|&c| c == 'O').count();
                            format!("{}{}{hash}", ".".repeat(len - count), "O".repeat(count))
                        })
                        .collect::<String>()
                })
                .collect::<Vec<_>>(),
        )
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
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

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        let mut maze = Maze(input).rotate();
        let mut positions: HashMap<Maze, usize> = HashMap::with_capacity(1000000000);
        let mut iteration = 0;
        let cycles;

        loop {
            let stored_pos = positions.entry(maze.clone()).or_insert(iteration);
            if *stored_pos != iteration {
                cycles = iteration - *stored_pos;
                break;
            }
            iteration += 1;
            maze = dbg!(maze
                .rotate()
                .tilt_right()
                .rotate()
                .tilt_right()
                .rotate()
                .tilt_right()
                .rotate()
                .tilt_right());
        }
        let valid_idx = (1e9 as usize - iteration) % cycles + (iteration - cycles);
        println!("{}", valid_idx);
        let final_position = positions
            .into_iter()
            .find(|(_, b)| *b == valid_idx)
            .unwrap()
            .0
            .calculate();
        Ok(final_position)
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

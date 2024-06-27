use std::collections::HashMap;

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

pub struct Solution;

struct Step<'t> {
    label: &'t str,
    value: usize,
}

struct Operation<'t> {
    box_no: u8,
    todo: Modifier<'t>,
}

enum Modifier<'t> {
    Add(Step<'t>),
    Delete(&'t str),
}

type Box<'t> = Vec<Step<'t>>;
type Boxes<'t> = HashMap<u8, Box<'t>>;

impl<'t> From<&'t str> for Operation<'t> {
    fn from(s: &'t str) -> Self {
        let (label, number) = s.split_once(['-', '=']).unwrap();
        let should_add = s.contains('=');
        Self {
            box_no: label
                .chars()
                .fold(0, |acc, c| (((acc as usize + c as usize) * 17) % 256) as u8),
            todo: if should_add {
                Modifier::Add(Step {
                    label,
                    value: number.parse().unwrap(),
                })
            } else {
                Modifier::Delete(label)
            },
        }
    }
}

impl<'t> Operation<'t> {
    fn apply(&self, boxes: &mut Boxes<'t>) {
        boxes.entry(self.box_no).and_modify(|bx| match &self.todo {
            Modifier::Add(step @ Step { label, value }) => {
                if let Some(mut_step) = bx.iter_mut().find(|s| &s.label == label) {
                    mut_step.value = *value;
                } else {
                    bx.push(Step { ..*step });
                }
            }
            Modifier::Delete(label) => {
                bx.iter()
                    .position(|s| &s.label == label)
                    .map(|pos| bx.remove(pos));
            }
        });
    }
}

const fn final_val(line: &str) -> usize {
    let mut total = 0;
    let mut accum = 0;
    let mut i = 0;
    let len = line.len();
    let line_bytes = line.as_bytes();
    while i < len {
        if line_bytes[i] == b',' {
            total += accum;
            accum = 0;
        } else {
            accum = ((accum + line_bytes[i] as usize) * 17) % 256;
        }

        i += 1;
    }
    total + accum
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        Ok(final_val(&input[0]))
    }

    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let boxes = input[0].split(',').map(Operation::from).fold(
            (0..u8::MAX)
                .map(|v| (v, vec![]))
                .collect::<HashMap<_, Vec<Step<'_>>>>(),
            |mut acc, n| {
                n.apply(&mut acc);
                acc
            },
        );
        let total = boxes
            .iter()
            .map(|(no, bx)| {
                bx.iter()
                    .enumerate()
                    .map(|(pos, Step { value, .. })| (*no as usize + 1) * (pos + 1) * value)
                    .sum::<usize>()
            })
            .sum::<usize>();
        Ok(total)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day15.txt" => 1320
    ),
    part 2 => (
        "../inputs/tests/day15.txt" => 145
    )
);

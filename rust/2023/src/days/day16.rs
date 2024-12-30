use std::collections::HashSet;

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

pub struct Solution;

fn calc_energized(input: &[&[u8]], start: (isize, isize, isize, isize)) -> usize {
    let mut queue = vec![start];
    let mut seen = HashSet::new();

    while let Some((mut row, mut col, drow, dcol)) = queue.pop() {
        row += drow;
        col += dcol;

        if row < 0 || row as usize >= input.len() || col < 0 || col as usize >= input[0].len() {
            continue;
        }

        let new_pos = input[row as usize][col as usize];

        match new_pos {
            b'.' => {
                queue.push((row, col, drow, dcol));
                seen.insert((row, col, drow, dcol));
            }
            b'\\' if !seen.contains(&(row, col, dcol, drow)) => {
                queue.push((row, col, dcol, drow));
                seen.insert((row, col, dcol, drow));
            }
            b'/' if !seen.contains(&(row, col, -dcol, -drow)) => {
                queue.push((row, col, -dcol, -drow));
                seen.insert((row, col, -dcol, -drow));
            }
            b'|' if drow != 0 => {
                queue.push((row, col, drow, dcol));
                seen.insert((row, col, drow, dcol));
            }
            b'|' => {
                if !seen.contains(&(row, col, 1, 0)) {
                    queue.push((row, col, 1, 0));
                    seen.insert((row, col, 1, 0));
                }
                if !seen.contains(&(row, col, -1, 0)) {
                    queue.push((row, col, -1, 0));
                    seen.insert((row, col, -1, 0));
                }
            }
            b'-' if dcol != 0 => {
                queue.push((row, col, drow, dcol));
                seen.insert((row, col, drow, dcol));
            }
            b'-' => {
                if !seen.contains(&(row, col, 0, 1)) {
                    queue.push((row, col, 0, 1));
                    seen.insert((row, col, 0, 1));
                }
                if !seen.contains(&(row, col, 0, -1)) {
                    queue.push((row, col, 0, -1));
                    seen.insert((row, col, 0, -1));
                }
            }
            _ => continue,
        }
    }
    seen.iter()
        .map(|(row, col, _, _)| (row, col))
        .collect::<HashSet<_>>()
        .len()
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let new_input = input.iter().map(|s| s.as_bytes()).collect::<Vec<_>>();
        Ok(calc_energized(&new_input, (0, -1, 0, 1)))
    }

    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let new_input = input.iter().map(|s| s.as_bytes()).collect::<Vec<_>>();
        let result = (0..new_input.len()).fold(0, |acc, n| {
            acc.max(calc_energized(&new_input, (n as isize, -1, 0, 1)))
                .max(calc_energized(
                    &new_input,
                    (n as isize, new_input.len() as isize, 0, -1),
                ))
        });
        Ok((0..new_input[0].len()).fold(result, |acc, n| {
            acc.max(calc_energized(&new_input, (-1, n as isize, 1, 0)))
                .max(calc_energized(
                    &new_input,
                    (new_input.len() as isize, n as isize, -1, 0),
                ))
        }))
    }
}

advent_tests!(
    part 1 => (
        "../../tests/2023/day16.txt" => 46
    ),
    part 2 => (
        "../../tests/2023/day16.txt" => 51
    )
);

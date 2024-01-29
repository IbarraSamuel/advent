use crate::advent_tests;
use crate::advent_utils::{AdventSolution, GenericResult};

pub struct Solution;

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<isize> {
        let empty_rows = input
            .iter()
            .enumerate()
            .filter_map(|(idx, line)| (!line.contains('#')).then_some(idx as isize))
            .collect::<Vec<_>>();

        let empty_cols = (0..input[0].len())
            .filter(|idx| !input.iter().any(|line| line.chars().nth(*idx) == Some('#')))
            .map(|idx| idx as isize)
            .collect::<Vec<_>>();

        let galaxies = input
            .iter()
            .enumerate()
            .flat_map(|(y, line)| {
                line.char_indices()
                    .filter_map(move |(x, char)| (char == '#').then_some((x as isize, y as isize)))
            })
            .collect::<Vec<_>>();

        let mut steps = 0;
        for (xi, yi) in &galaxies {
            for (xf, yf) in &galaxies {
                let x_expand =
                    empty_cols.iter().filter(|x| **x > *xi && **x < *xf).count() as isize * 2;
                let y_expand =
                    empty_rows.iter().filter(|y| **y > *yi && **y < *yf).count() as isize * 2;
                steps += (xi - xf).abs() + x_expand + (yi - yf).abs() + y_expand;
            }
        }

        Ok(steps / 2)
    }

    fn part2(input: Vec<String>) -> GenericResult<isize> {
        let empty_rows = input
            .iter()
            .enumerate()
            .filter_map(|(idx, line)| (!line.contains('#')).then_some(idx as isize))
            .collect::<Vec<_>>();

        let empty_cols = (0..input[0].len())
            .filter(|idx| !input.iter().any(|line| line.chars().nth(*idx) == Some('#')))
            .map(|idx| idx as isize)
            .collect::<Vec<_>>();

        let galaxies = input
            .iter()
            .enumerate()
            .flat_map(|(y, line)| {
                line.char_indices()
                    .filter_map(move |(x, char)| (char == '#').then_some((x as isize, y as isize)))
            })
            .collect::<Vec<_>>();

        let mut steps = 0;
        for (xi, yi) in &galaxies {
            for (xf, yf) in &galaxies {
                // if xi >= xf || yi >= yf {
                //     continue;
                // }
                let x_expand = empty_cols
                    .iter()
                    .filter(|x| **x > *xi.min(xf) && **x < *xi.max(xf))
                    .count() as isize;
                let y_expand = empty_rows
                    .iter()
                    .filter(|y| **y > *yi.min(yf) && **y < *yf.max(yi))
                    .count() as isize;
                steps += (xi - xf).abs()
                    + x_expand * (1000000 - 1)
                    + (yi - yf).abs()
                    + y_expand * (1000000 - 1);
            }
        }
        Ok(steps / 2)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day11.txt" => 374
    ),
    part 2 => (
        "../inputs/tests/day11.txt" => 82000210
    )
);

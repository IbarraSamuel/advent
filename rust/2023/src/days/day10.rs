use std::borrow::BorrowMut;
use std::ops::Not;

use crate::advent_utils::{AdventSolution, GenericResult};

use crate::advent_tests;

pub struct Solution;

#[derive(Debug, PartialEq, Eq, Copy, Clone)]
struct Pipe {
    char: char,
    position: (usize, usize),
    start: (usize, usize),
    end: (usize, usize),
    in_maze: bool,
}

impl From<((usize, usize), char)> for Pipe {
    fn from(((x, y), c): ((usize, usize), char)) -> Self {
        let (st, end) = match c {
            '|' => ((0, 1), (0, -1)),
            '-' => ((1, 0), (-1, 0)),
            'L' => ((0, 1), (1, 0)),
            'J' => ((0, 1), (-1, 0)),
            '7' => ((0, -1), (-1, 0)),
            'F' => ((0, -1), (1, 0)),
            '.' => ((0, 0), (0, 0)),
            'S' => ((0, 0), (0, 0)),
            _ => panic!("Invalid pipe character: {}", c),
        };

        let start_pos = ((x as isize + st.0) as usize, (y as isize - st.1) as usize);
        let end_pos = ((x as isize + end.0) as usize, (y as isize - end.1) as usize);

        Self {
            char: c,
            start: start_pos,
            end: end_pos,
            position: (x, y),
            in_maze: false,
        }
    }
}

impl Pipe {
    /// Returns the next pipe and the position of the prev pipe.
    fn next(&self, from: (usize, usize), map: &mut [Vec<Pipe>]) -> ((usize, usize), Pipe) {
        let (x, y) = self.position;
        map[y][x].in_maze = true;

        let (pos, pipe) = if from == self.position {
            let (ymin, ymax) = (y.saturating_sub(1), (y + 1).min(map.len() - 1));
            let (xmin, xmax) = (x.saturating_sub(1), (x + 1).min(map[0].len() - 1));
            let pipe = map[ymin..=ymax]
                .iter_mut()
                .flat_map(|row| row[xmin..=xmax].iter_mut())
                .find(|pipe| {
                    "S.".contains(pipe.char).not()
                        && (pipe.start == self.position || pipe.end == self.position)
                })
                .expect("No pipe connected to S.");
            ((x, y), pipe)
        } else if from == self.start {
            (self.position, map[self.end.1][self.end.0].borrow_mut())
        } else if from == self.end {
            (self.position, map[self.start.1][self.start.0].borrow_mut())
        } else {
            panic!("Invalid pipe position: {:?}", from);
        };

        pipe.in_maze = true;
        (pos, *pipe)
    }

    fn cast_s_to_piece(&self, init: &Pipe, end: &Pipe) -> Pipe {
        let mut pipe = "7FJL|-"
            .chars()
            .map(|c| Pipe::from((self.position, c)))
            .find(|pipe| {
                pipe.start == init.position && pipe.end == end.position
                    || pipe.start == end.position && pipe.end == init.position
            })
            .expect("Is not possible to cast S to a piece");
        pipe.in_maze = true;
        pipe
    }
}

fn get_inners_count(map: &[Vec<Pipe>]) -> usize {
    map.iter()
        .map(|line| {
            let mut within = 0;
            let mut count = 0;
            let mut expecting = None;
            for pipe in line {
                if pipe.in_maze && "FL".contains(pipe.char) {
                    expecting = match pipe.char {
                        'F' => Some('J'),
                        'L' => Some('7'),
                        _ => None,
                    };
                } else if pipe.in_maze && pipe.char != '-' {
                    count += match expecting {
                        Some(c) if pipe.char == c => 1,
                        Some(_) => 0,
                        None => 1,
                    };
                    expecting = None;
                } else if count % 2 == 1 && !pipe.in_maze {
                    within += 1;
                }
            }
            within
        })
        .sum()
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let mut map = input
            .iter()
            .enumerate()
            .map(|(y, line)| {
                line.char_indices()
                    .map(|(x, char)| Pipe::from(((x, y), char)))
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        let mut pipe = *map
            .iter()
            .find_map(|row| row.iter().find(|pipe| pipe.char == 'S'))
            .expect("No S pipe found :(");

        let mut pos = pipe.position;

        let mut count: usize = 0;
        // let mut positions = Vec::new();
        loop {
            (pos, pipe) = pipe.next(pos, &mut map);
            count += 1;
            // positions.push(pos);
            if pipe.char == 'S' {
                break;
            }
        }

        Ok(count / 2)
    }

    fn part2(input: Vec<String>) -> GenericResult<impl std::fmt::Display> {
        let mut map = input
            .iter()
            .enumerate()
            .map(|(y, line)| {
                line.char_indices()
                    .map(|(x, char)| Pipe::from(((x, y), char)))
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        let mut pipe = *map
            .iter()
            .find_map(|row| row.iter().find(|pipe| pipe.char == 'S'))
            .expect("No S pipe found :(");

        let mut pos = pipe.position;

        // let mut count: usize = 0;
        // let mut maze = Vec::with_capacity(map.len() * map[0].len());

        // using the first step as the begining.
        (pos, pipe) = pipe.next(pos, &mut map);
        let end = pipe;
        let mut init = pipe;

        while pipe.char != 'S' {
            init = pipe;
            (pos, pipe) = pipe.next(pos, &mut map);
            // count += 1;
            // maze.push(Pipe { ..*pipe });
        }

        for row in map.iter_mut() {
            if let Some(v) = row.iter_mut().find(|pipe| pipe.char == 'S') {
                *v = pipe.cast_s_to_piece(&init, &end);
                break;
            }
        }

        // let maze_pos = maze.into_iter().map(|p| p.position).collect::<Vec<_>>();
        let inners = get_inners_count(&map);

        Ok(inners)
    }
}

advent_tests!(
    part 1 => (
        "../../tests/2023/day10.txt" => 8
    ),
    part 2 => (
        "../../tests/2023/day10_2.txt" => 4,
        "../../tests/2023/day10_3.txt" => 8,
        "../../tests/2023/day10_4.txt" => 10
    )
);

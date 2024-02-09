use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

const MIRRORS: [u8; 4] = [b'/', b'\\', b'|', b'-'];

pub struct Solution;

#[derive(Debug, Clone, PartialEq)]
struct Position(usize, usize);

#[derive(Debug)]
enum Direction {
    Left,
    Right,
    Up,
    Down,
}

struct Movement {
    direction: Direction,
    position: Position,
}

fn check_next(
    Movement {
        direction,
        position,
    }: Movement,
    input: &[&[u8]],
    mut used: Vec<Position>,
) -> usize {
    if used.contains(&position) {
        return 0;
    }

    let Position(x, y) = position;
    let new_position = match direction {
        Direction::Right => input[y]
            .iter()
            .enumerate()
            .skip(x)
            .find(|(_, c)| MIRRORS.contains(c) && **c != b'-')
            .map(|(idx, _)| (idx, y)),
        Direction::Left => input[y][..=x]
            .iter()
            .enumerate()
            .rev()
            .find(|(_, c)| MIRRORS.contains(c) && **c != b'-')
            .map(|(idx, _)| (idx, y)),
        Direction::Down => (y..input.len())
            .map(|idx| (idx, input[idx][x]))
            .find(|(_, c)| MIRRORS.contains(c) && *c != b'|')
            .map(|(idx, _)| (x, idx)),
        Direction::Up => (0..=y)
            .map(|idx| (idx, input[idx][x]))
            .rev()
            .find(|(_, c)| MIRRORS.contains(c) && *c != b'|')
            .map(|(idx, _)| (x, idx)),
    };

    if let Some((xf, yf)) = new_position {
        used.push(Position(xf, yf));
        match (input[yf][xf], direction) {
            (b'|', Direction::Left) | (b'|', Direction::Right) => {
                check_next(
                    Movement {
                        direction: Direction::Up,
                        position: Position(xf, yf),
                    },
                    input,
                    used.clone(),
                ) + check_next(
                    Movement {
                        direction: Direction::Down,
                        position: Position(xf, yf),
                    },
                    input,
                    used,
                )
            }
            (b'|', Direction::Up) | (b'-', Direction::Down) => {
                check_next(
                    Movement {
                        direction: Direction::Left,
                        position: Position(xf, yf),
                    },
                    input,
                    used.clone(),
                ) + check_next(
                    Movement {
                        direction: Direction::Right,
                        position: Position(xf, yf),
                    },
                    input,
                    used,
                )
            }
            (b'/', Direction::Right) | (b'\\', Direction::Left) => check_next(
                Movement {
                    direction: Direction::Up,
                    position: Position(xf, yf),
                },
                input,
                used,
            ),
            (b'\\', Direction::Right) | (b'/', Direction::Left) => check_next(
                Movement {
                    direction: Direction::Down,
                    position: Position(xf, yf),
                },
                input,
                used,
            ),
            (b'/', Direction::Up) | (b'\\', Direction::Down) => check_next(
                Movement {
                    direction: Direction::Right,
                    position: Position(xf, yf),
                },
                input,
                used,
            ),
            (b'\\', Direction::Up) | (b'/', Direction::Down) => check_next(
                Movement {
                    direction: Direction::Left,
                    position: Position(xf, yf),
                },
                input,
                used,
            ),
            _ => unreachable!("should never happen"),
        }
    } else {
        match direction {
            Direction::Right => input[y].len() - (x + 1),
            Direction::Left => x + 1,
            Direction::Down => input.len() - (y + 1),
            Direction::Up => y + 1,
        }
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let movement = Movement {
            direction: Direction::Right,
            position: Position(0, 0),
        };
        let new_input = input.iter().map(|s| s.as_bytes()).collect::<Vec<_>>();
        let result = check_next(movement, &new_input, vec![Position(0, 0)]);
        Ok(result)
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

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

const MIRRORS: [u8; 4] = [b'/', b'\\', b'|', b'-'];

pub struct Solution;

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct Position(usize, usize);

#[derive(Debug, PartialEq, Eq, Clone)]
enum Direction {
    Left,
    Right,
    Up,
    Down,
}

#[derive(Eq, PartialEq, Debug, Clone)]
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
    mut used: Vec<Movement>,
) -> isize {
    if used.contains(&Movement {
        direction: direction.clone(),
        position: position.clone(),
    }) {
        return -1;
    }
    let repeated = used.iter().filter(|m| m.position == position).count();

    let mirror: String;
    let Position(x, y) = position;
    used.push(Movement {
        direction: direction.clone(),
        position: position.clone(),
    });

    let new_position = match direction {
        Direction::Right => input[y]
            .iter()
            .enumerate()
            .skip(x + 1)
            .find(|(_, c)| MIRRORS.contains(c) && **c != b'-')
            .map(|(idx, _)| (idx, y)),
        Direction::Left => input[y][..x]
            .iter()
            .enumerate()
            .rev()
            .find(|(_, c)| MIRRORS.contains(c) && **c != b'-')
            .map(|(idx, _)| (idx, y)),
        Direction::Down => (y + 1..input.len())
            .map(|idx| (idx, input[idx][x]))
            .find(|(_, c)| MIRRORS.contains(c) && *c != b'|')
            .map(|(idx, _)| (x, idx)),
        Direction::Up => (0..y)
            .map(|idx| (idx, input[idx][x]))
            .rev()
            .find(|(_, c)| MIRRORS.contains(c) && *c != b'|')
            .map(|(idx, _)| (x, idx)),
    };

    // dbg!(&new_position);
    if let Some((xf, yf)) = &new_position {
        assert!(MIRRORS.contains(&input[*yf][*xf]));
        mirror = format!("{:?}", (xf, yf));
        let portion = match &direction {
            Direction::Right => input[*yf][x + 1..=*xf].to_vec(),
            Direction::Left => input[*yf][*xf..x].to_vec(),
            Direction::Down => input[y + 1..=*yf]
                .iter()
                .map(|s| s[*xf])
                .collect::<Vec<_>>(),
            Direction::Up => input[*yf..y].iter().map(|s| s[*xf]).collect::<Vec<_>>(),
        }
        .iter()
        .map(|c| *c as char)
        .collect::<String>();
        println!(
            "From {:?} going {:?} to {:?} .. Section: {:?}",
            (x, y),
            &direction,
            (xf, yf),
            portion
        );
    } else {
        mirror = "none".into();
    }

    let value = if let Some((xf, yf)) = new_position {
        assert!(MIRRORS.contains(&input[yf][xf]));

        (match (input[yf][xf], &direction) {
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
            (b'-', Direction::Up) | (b'-', Direction::Down) => {
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
        }) - repeated as isize
            + xf.abs_diff(x) as isize
            + yf.abs_diff(y) as isize
    } else {
        (match &direction {
            Direction::Right => input[y].len() - 1 - x,
            Direction::Left => x,
            Direction::Down => input.len() - 1 - y,
            Direction::Up => y,
        }) as isize
            - repeated as isize
    };
    println!(
        "From {:?} going {:?} to {:?} =>>>> with value {:?}",
        (x, y),
        &direction,
        mirror,
        value
    );
    value
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let movement = Movement {
            direction: Direction::Right,
            position: Position(0, 0),
        };
        let new_input = input.iter().map(|s| s.as_bytes()).collect::<Vec<_>>();
        let result = check_next(movement, &new_input, vec![]);
        Ok(result as usize)
    }

    fn part2(_input: Vec<String>) -> GenericResult<usize> {
        todo!()
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day16.txt" => 46
    )
);

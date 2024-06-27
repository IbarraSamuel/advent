use std::collections::HashSet;

use crate::{
    advent_tests,
    advent_utils::{AdventSolution, GenericResult},
};

enum Mirror {
    None,
    Zero,
    FortyFive,
    Ninety,
    OneThirtyFive,
}

impl From<&u8> for Mirror {
    fn from(value: &u8) -> Self {
        match value {
            b'/' => Mirror::FortyFive,
            b'\\' => Mirror::OneThirtyFive,
            b'|' => Mirror::Ninety,
            b'-' => Mirror::Zero,
            b'.' => Mirror::None,
            _ => panic!("Invalid mirror"),
        }
    }
}

// impl Mirror {
//     fn reflect(
//         &self,
//         direction: &Direction,
//         (x, y): (usize, usize),
//     ) -> (Option<Direction>, Option<Direction>) {
//         match *self {
//             Mirror::None => (Some(direction.clone()), None),
//             Mirror::Zero => match direction {
//                 Direction::Left { .. } => (Some(Direction::Left { x, y }), None),
//                 Direction::Right { .. } => (Some(Direction::Right { x, y }), None),
//                 Direction::Up { .. } | Direction::Down { .. } => (
//                     Some(Direction::Right { x, y }),
//                     Some(Direction::Left { x, y }),
//                 ),
//             },
//             Mirror::FortyFive => match direction {
//                 Direction::Left { .. } => (Some(Direction::Down { x, y }), None),
//                 Direction::Right { .. } => (Some(Direction::Up { x, y }), None),
//                 Direction::Up { .. } => (Some(Direction::Right { x, y }), None),
//                 Direction::Down { .. } => (Some(Direction::Left { x, y }), None),
//             },
//             Mirror::Ninety => match direction {
//                 Direction::Left { .. } | Direction::Right { .. } => {
//                     (Some(Direction::Up { x, y }), Some(Direction::Down { x, y }))
//                 }
//                 Direction::Up { .. } => (Some(Direction::Up { x, y }), None),
//                 Direction::Down { .. } => (Some(Direction::Down { x, y }), None),
//             },
//             Mirror::OneThirtyFive => match direction {
//                 Direction::Left { .. } => (Some(Direction::Up { x, y }), None),
//                 Direction::Right { .. } => (Some(Direction::Down { x, y }), None),
//                 Direction::Up { .. } => (Some(Direction::Left { x, y }), None),
//                 Direction::Down { .. } => (Some(Direction::Right { x, y }), None),
//             },
//         }
//     }
// }

pub struct Solution;

// #[derive(Debug, PartialEq, Eq, Hash, Clone)]
// enum Direction {
//     Left { x: usize, y: usize },
//     Right { x: usize, y: usize },
//     Up { x: usize, y: usize },
//     Down { x: usize, y: usize },
// }

// impl Direction {
//     fn dx(&self) -> (i8, i8) {
//         match self {
//             Direction::Left { .. } => (-1, 0),
//             Direction::Right { .. } => (1, 0),
//             Direction::Up { .. } => (0, -1),
//             Direction::Down { .. } => (0, 1),
//         }
//     }

//     fn pos(&self) -> (usize, usize) {
//         match self {
//             Direction::Left { x, y }
//             | Direction::Right { x, y }
//             | Direction::Up { x, y }
//             | Direction::Down { x, y } => (*x, *y),
//         }
//     }

//     fn next_pos(&self) -> Option<(usize, usize)> {
//         let (x, y) = self.pos();
//         let (dx, dy) = self.dx();
//         if (x as isize + dx as isize) < 0 || (y as isize + dy as isize) < 0 {
//             None
//         } else {
//             Some((
//                 (x as isize + dx as isize) as usize,
//                 (y as isize + dy as isize) as usize,
//             ))
//         }
//     }

//     fn next_dir(&self, ctx: &[&[u8]]) -> (Option<Direction>, Option<Direction>) {
//         if let Some((x, y)) = self.next_pos() {
//             if x >= ctx[0].len() || y >= ctx.len() {
//                 return (None, None);
//             }
//             Mirror::from(&ctx[y][x]).reflect(self, (x, y))
//         } else {
//             (None, None)
//         }
//     }
// }

// fn calculate(ctx: &[&[u8]], init: Option<Direction>) -> usize {
//     let mut queue: Vec<Direction> = Vec::with_capacity(
//         ctx.iter()
//             .map(|ln| ln.iter().filter(|a| MIRRORS.contains(a)).count())
//             .sum::<usize>()
//             * 2,
//     );
//     let mut used: HashSet<Direction> = HashSet::with_capacity(queue.capacity());
//     if init.is_some() {
//         used.insert(init.clone().unwrap());
//     }
//     queue.push(init.unwrap_or(Direction::Right { x: 0, y: 0 }));

//     while let Some(next_direction) = queue.pop() {
//         match next_direction.next_dir(ctx) {
//             (Some(dir1), Some(dir2)) => {
//                 if !used.contains(&dir1) {
//                     queue.push(dir1.clone());
//                 }
//                 if !used.contains(&dir2) {
//                     queue.push(dir2.clone());
//                 }
//             }
//             (Some(dir1), None) => {
//                 if !used.contains(&dir1) {
//                     queue.push(dir1.clone());
//                 }
//             }
//             (None, Some(dir2)) => {
//                 if !used.contains(&dir2) {
//                     queue.push(dir2.clone());
//                 }
//             }
//             (None, None) => (),
//         }
//         used.insert(next_direction);
//     }

//     used.iter()
//         .map(|dir| match dir {
//             Direction::Up { x, y }
//             | Direction::Down { x, y }
//             | Direction::Left { x, y }
//             | Direction::Right { x, y } => (x, y),
//         })
//         .collect::<HashSet<_>>()
//         .len()
// }

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
        // let init =
        //     MIRRORS
        //         .contains(&new_input[0][0])
        //         .then(|| match Mirror::from(&new_input[0][0]) {
        //             Mirror::Zero => Direction::Right { x: 0, y: 0 },
        //             Mirror::FortyFive => Direction::Up { x: 0, y: 0 },
        //             Mirror::Ninety => Direction::Down { x: 0, y: 0 },
        //             Mirror::OneThirtyFive => Direction::Down { x: 0, y: 0 },
        //             Mirror::None => Direction::Right { x: 0, y: 0 },
        //         });
        // Ok(calculate(&new_input, init))
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
        "../inputs/tests/day16.txt" => 46
    ),
    part 2 => (
        "../inputs/tests/day16.txt" => 51
    )
);

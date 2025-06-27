use crate::advent_utils::Solution as AdventSolution;

// #[derive(PartialEq)]
// enum Dir {
//     Up,
//     Down,
//     Left,
//     Right,
//     UpLeft,
//     UpRight,
//     DownLeft,
//     DownRight,
// }

// impl Dir {
//     fn delta(&self) -> (i8, i8) {
//         let yi = match self {
//             Dir::Up | Dir::UpLeft | Dir::UpRight => -1,
//             Dir::Down | Dir::DownLeft | Dir::DownRight => 1,
//             _ => 0,
//         };
//         let xi = match self {
//             Dir::Left | Dir::UpLeft | Dir::DownLeft => -1,
//             Dir::Right | Dir::UpRight | Dir::DownRight => 1,
//             _ => 0,
//         };
//         (xi, yi)
//     }
// }
pub struct Solution;

impl AdventSolution for Solution {
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day04.txt").unwrap();
    /// assert_eq!(days::day04::Solution::part_1(&input), 18);
    /// let input = std::fs::read_to_string("../../tests/2024/day044.txt").unwrap();
    /// assert_eq!(days::day04::Solution::part_1(&input), 4);
    /// ```
    fn part_1(data: &str) -> usize {
        let mut tot = 0;
        let bytes = data.as_bytes();
        let xmax = data.find("\n").expect("no lines found?");
        let ymax = data.len() / (xmax + 1);
        println!("xmax is {xmax} and ymax is {ymax}");

        let idx = |x, y| x + y * (xmax + 1);

        for (y, line) in data.lines().enumerate() {
            let mut last = 0;
            while let Some(x) = line[last..].find('X').map(|x| x + last) {
                last = x + 1;

                tot += (x < xmax - 3
                    && bytes[idx(x + 1, y)] == b'M'
                    && bytes[idx(x + 2, y)] == b'A'
                    && bytes[idx(x + 3, y)] == b'S') as usize
                    + (x > 2
                        && bytes[idx(x - 1, y)] == b'M'
                        && bytes[idx(x - 2, y)] == b'A'
                        && bytes[idx(x - 3, y)] == b'S') as usize
                    + (x < xmax - 3
                        && y < ymax - 3
                        && bytes[idx(x + 1, y + 1)] == b'M'
                        && bytes[idx(x + 2, y + 2)] == b'A'
                        && bytes[idx(x + 3, y + 3)] == b'S') as usize
                    + (x > 2
                        && y > 2
                        && bytes[idx(x - 1, y - 1)] == b'M'
                        && bytes[idx(x - 2, y - 2)] == b'A'
                        && bytes[idx(x - 3, y - 3)] == b'S') as usize
                    + (x < xmax - 3
                        && y > 2
                        && bytes[idx(x + 1, y - 1)] == b'M'
                        && bytes[idx(x + 2, y - 2)] == b'A'
                        && bytes[idx(x + 3, y - 3)] == b'S') as usize
                    + (x > 2
                        && y < ymax - 3
                        && bytes[idx(x - 1, y + 1)] == b'M'
                        && bytes[idx(x - 2, y + 2)] == b'A'
                        && bytes[idx(x - 3, y + 3)] == b'S') as usize
                    + (y < ymax - 3
                        && bytes[idx(x, y + 1)] == b'M'
                        && bytes[idx(x, y + 2)] == b'A'
                        && bytes[idx(x, y + 3)] == b'S') as usize
                    + (y > 2
                        && bytes[idx(x, y - 1)] == b'M'
                        && bytes[idx(x, y - 2)] == b'A'
                        && bytes[idx(x, y - 3)] == b'S') as usize;
            }
        }

        tot
    }
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day04.txt").unwrap();
    /// assert_eq!(days::day04::Solution::part_2(&input), 9);
    /// ```
    fn part_2(data: &str) -> usize {
        let mut tot = 0;
        // let ymax = data.lines().count();
        let xmax = data.find("\n").expect("not a single row?");
        let lines = data.lines();

        for ((prev, line), next) in lines.clone().zip(lines.clone().skip(1)).zip(lines.skip(2)) {
            let mut last = 1;
            while let Some(x) = line[last..].find("A").map(|x| x + last)
                && x != xmax - 1
            {
                last = x + 1;

                let pr = prev.as_bytes();
                let ne = next.as_bytes();
                if (pr[x - 1] == b'M' && ne[x + 1] == b'S'
                    || pr[x - 1] == b'S' && ne[x + 1] == b'M')
                    && (ne[x - 1] == b'M' && pr[x + 1] == b'S'
                        || ne[x - 1] == b'S' && pr[x + 1] == b'M')
                {
                    tot += 1;
                }
            }
        }

        tot
    }
}

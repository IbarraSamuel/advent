use std::io::Write;

use crate::advent_utils::Solution as AdventSolution;

pub struct Solution;

const M: u8 = b'M';
const A: u8 = b'A';
const S: u8 = b'S';

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

        let idx = |x, y| x + y * (xmax + 1);

        let mut last = 0;
        use std::fs::File;

        let mut f = File::create("rs.txt").unwrap();
        loop {
            _ = f.write_all(tot.to_string().as_bytes());
            _ = f.write_all(b"\n");
            let lnr = data[last..].find("X");
            if lnr.is_none() {
                break;
            }
            let lnr = lnr.unwrap() + last;
            last = lnr + 1;
            let (x, y) = (lnr % (xmax + 1), lnr / (xmax + 1));

            tot += (x < xmax - 3
                && bytes[idx(x + 1, y)] == M
                && bytes[idx(x + 2, y)] == A
                && bytes[idx(x + 3, y)] == S) as usize
                + (x > 2
                    && bytes[idx(x - 1, y)] == M
                    && bytes[idx(x - 2, y)] == A
                    && bytes[idx(x - 3, y)] == S) as usize
                + (x < xmax - 3
                    && y < ymax - 3
                    && bytes[idx(x + 1, y + 1)] == M
                    && bytes[idx(x + 2, y + 2)] == A
                    && bytes[idx(x + 3, y + 3)] == S) as usize
                + (x > 2
                    && y > 2
                    && bytes[idx(x - 1, y - 1)] == M
                    && bytes[idx(x - 2, y - 2)] == A
                    && bytes[idx(x - 3, y - 3)] == S) as usize
                + (x < xmax - 3
                    && y > 2
                    && bytes[idx(x + 1, y - 1)] == M
                    && bytes[idx(x + 2, y - 2)] == A
                    && bytes[idx(x + 3, y - 3)] == S) as usize
                + (x > 2
                    && y < ymax - 3
                    && bytes[idx(x - 1, y + 1)] == M
                    && bytes[idx(x - 2, y + 2)] == A
                    && bytes[idx(x - 3, y + 3)] == S) as usize
                + (y < ymax - 3
                    && bytes[idx(x, y + 1)] == M
                    && bytes[idx(x, y + 2)] == A
                    && bytes[idx(x, y + 3)] == S) as usize
                + (y > 2
                    && bytes[idx(x, y - 1)] == M
                    && bytes[idx(x, y - 2)] == A
                    && bytes[idx(x, y - 3)] == S) as usize;
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
                if (pr[x - 1] == M && ne[x + 1] == S || pr[x - 1] == S && ne[x + 1] == M)
                    && (ne[x - 1] == M && pr[x + 1] == S || ne[x - 1] == S && pr[x + 1] == M)
                {
                    tot += 1;
                }
            }
        }

        tot
    }
}

use crate::advent_utils::Solution as AdventSolution;

pub struct Solution;

impl AdventSolution for Solution {
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day03.txt").unwrap();
    /// assert_eq!(days::day03::Solution::part_1(&input), 161);
    /// ```
    fn part_1(data: &str) -> usize {
        let mut pos = 0;
        let mut tot = 0;
        while pos < data.len() {
            let mut pi = match data[pos..].find("mul(") {
                Some(pi) => pi + pos,
                None => break,
            };
            pi += 4;
            let pc = match data[pi + 1..].find(",") {
                Some(pc) => pc + pi + 1,
                None => break,
            };
            let Ok(n1) = data[pi..pc].parse::<usize>() else {
                pos = pi + 1;
                continue;
            };
            let pf = match data[pc + 2..].find(")") {
                Some(pf) => pf + pc + 2,
                None => break,
            };
            let Ok(n2) = data[pc + 1..pf].parse::<usize>() else {
                pos = pc + 1;
                continue;
            };

            pos = pf + 1;
            tot += n1 * n2;
        }
        tot
    }
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day032.txt").unwrap();
    /// assert_eq!(days::day03::Solution::part_2(&input), 48);
    /// ```
    fn part_2(data: &str) -> usize {
        let mut pos = 0;
        let mut tot = 0;
        let mut n_dont = data.find("don't()");
        while pos < data.len() {
            let mut pi = match data[pos..].find("mul(") {
                Some(pi) => pi + pos,
                None => break,
            };
            if n_dont.is_some() && n_dont.unwrap() < pi {
                if let Some(o) = data[pos + 7..].find("do()") {
                    pos = o + pos + 7 + 4;
                } else {
                    break;
                }

                n_dont = data[pos..].find("don't()").map(|v| v + pos);
                continue;
            }
            pi += 4;
            let pc = match data[pi + 1..].find(",") {
                Some(pc) => pc + pi + 1,
                None => break,
            };
            let Ok(n1) = data[pi..pc].parse::<usize>() else {
                pos = pi + 1;
                continue;
            };
            let pf = match data[pc + 2..].find(")") {
                Some(pf) => pf + pc + 2,
                None => break,
            };
            let Ok(n2) = data[pc + 1..pf].parse::<usize>() else {
                pos = pc + 1;
                continue;
            };

            pos = pf + 1;
            tot += n1 * n2;
        }
        tot
    }
}

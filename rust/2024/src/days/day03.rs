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
            let Some(mut pi) = data[pos..].find("mul(") else {
                break;
            };
            pi += 4;
            let Some(pc) = data[pos + pi + 1..].find(",") else {
                break;
            };
            let Ok(n1) = data[pos + pi + 1..pos + pi + 1 + pc].parse::<usize>() else {
                pos += pi + 1;
                continue;
            };
            let Some(pf) = data[pos + pi + 1 + pc + 2..].find(")") else {
                break;
            };
            let Ok(n2) = data[pos + pi + 1 + pc + 1..pos + pi + 1 + pc + 2 + pf].parse::<usize>()
            else {
                pos += pc + 1;
                continue;
            };
            println!("{} * {} = {}", n1, n2, n1 * n2);

            pos += pf + 1;
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
            let Some(mut pi) = data[pos..].find("mul(") else {
                break;
            };

            if n_dont.is_some() && n_dont.unwrap() < pos {
                let Some(doo) = data[pos + 7..].find("do()") else {
                    break;
                };
                pos = doo + 4;
                n_dont = data[pos..].find("don't()");
                continue;
            }
            pi += 4;
            let Some(pc) = data[pi + 1..].find(",") else {
                break;
            };
            let Ok(n1) = data[pi..pc].parse::<usize>() else {
                pos = pi + 1;
                continue;
            };
            let Some(pf) = data[pc + 2..].find(")") else {
                break;
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

use crate::advent_utils::Solution as AdventSolution;
pub struct Solution;

impl AdventSolution for Solution {
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day01.txt").unwrap();
    /// assert_eq!(days::day01::Solution::part_1(&input), 11);
    /// ```
    fn part_1(input: &str) -> u32 {
        let vals = input.lines().map(|line| {
            let v = line
                .split_ascii_whitespace()
                .map(|s| s.parse::<u32>().unwrap())
                .collect::<Vec<_>>();
            (v[0], v[1])
        });
        let mut p1: Vec<u32> = vals.clone().map(|(a, _)| a).collect();
        let mut p2: Vec<u32> = vals.map(|(_, b)| b).collect();
        p1.sort();
        p2.sort();

        let mut tot = 0;
        for i in 0..(p1.len()) {
            tot += p1[i].abs_diff(p2[i])
        }
        tot
    }
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day01.txt").unwrap();
    /// assert_eq!(days::day01::Solution::part_2(&input), 31);
    /// ```
    fn part_2(input: &str) -> u32 {
        use std::collections::HashMap;
        let lines = input.lines();
        let mut map: HashMap<&str, u32> = HashMap::new();

        for v in lines
            .clone()
            .map(|line| line.split_whitespace().nth(1).unwrap())
        {
            *map.entry(v).or_insert(0) += 1;
        }

        lines
            .map(|line| map.get(line.split_once(" ").unwrap().0).unwrap_or(&0))
            .sum::<u32>()
    }
}

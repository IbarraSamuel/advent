use std::collections::HashMap;

use crate::advent_utils::Solution as AdventSolution;

pub struct Solution;

const fn build_indexes<const SIZE: usize>() -> [usize; SIZE] {
    let mut res = [0; SIZE];
    let mut idx = 0;
    while idx < SIZE {
        res[idx] = idx;
        idx += 1;
    }
    res
}

impl AdventSolution for Solution {
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day05.txt").unwrap();
    /// assert_eq!(days::day05::Solution::part_1(&input), 143);
    /// ```
    fn part_1(data: &str) -> usize {
        const ZORD: u8 = b'0';
        let order_split = data.find("\n\n").unwrap();
        let rest = &data[order_split + 2..];
        let order = &data[0..order_split];

        let mut next_dct: HashMap<&str, Vec<&str>> = HashMap::new();
        let mut prev_dct: HashMap<&str, Vec<&str>> = HashMap::new();
        for line in order.lines() {
            let (f, l) = line.split_once("|").unwrap();
            next_dct.entry(f).or_default().push(l);
            prev_dct.entry(l).or_default().push(f);
        }

        rest.lines()
            .map(|line| {
                let mut readed_idx: usize = 1;
                loop {
                    if line.len() == readed_idx * 3 - 1 {
                        let bts = line[line.len() / 2 - 1..line.len() / 2 + 1].as_bytes();
                        return 10 * bts[0] as isize - 11 * ZORD as isize + bts[1] as isize;
                    }

                    let val = &line[readed_idx * 3..readed_idx * 3 + 2];
                    let prev_values = &line[0..readed_idx * 3];

                    // if val in prev_dct:
                    let res = prev_dct.get(val);
                    let found =
                        res.map_or(false, |res| res.iter().any(|v| prev_values.contains(v)));
                    if !found {
                        return 0;
                    }

                    // no next should be found
                    let res = next_dct.get(val);
                    let found =
                        res.map_or(false, |res| res.iter().any(|v| prev_values.contains(v)));
                    if found {
                        return 0;
                    }
                    readed_idx += 1;
                }
            })
            .sum::<isize>() as usize
    }
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day05.txt").unwrap();
    /// assert_eq!(days::day05::Solution::part_2(&input), 0);
    /// ```
    fn part_2(_data: &str) -> usize {
        const ZORD: u8 = b'0';
        const INDEXES: [usize; 32] = build_indexes();
        let tot = 0;
        tot
    }
}

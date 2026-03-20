use crate::advent_utils::Solution as AdventSolution;

pub struct Solution;

type Validator = fn(&Vec<i32>, fn(&Vec<i32>) -> Vec<i32>) -> bool;

impl AdventSolution for Solution {
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day02.txt").unwrap();
    /// assert_eq!(days::day02::Solution::part_1(&input), 2);
    /// ```
    fn part_1(data: &str) -> usize {
        data.lines()
            .map(|l| {
                l.split_whitespace()
                    .filter_map(|s| s.parse::<i32>().ok())
                    .collect::<Vec<_>>()
                    .windows(2)
                    .map(|w| w[0] - w[1])
                    .collect::<Vec<_>>()
            })
            .filter(|l| {
                !l.is_empty()
                    && (l.iter().all(|v| v.abs() <= 3))
                    && (l.iter().all(|&i| i < 0) || l.iter().all(|&i| i > 0))
            })
            .count()
    }
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day02.txt").unwrap();
    /// assert_eq!(days::day02::Solution::part_2(&input), 4);
    /// let input2 = std::fs::read_to_string("../../tests/2024/day022.txt").unwrap();
    /// assert_eq!(days::day02::Solution::part_2(&input2), 28);
    /// ```
    fn part_2(data: &str) -> usize {
        data.lines()
            .filter(|l| {
                let diff: fn(&Vec<i32>) -> Vec<i32> =
                    |lst| lst.windows(2).map(|sl| sl[0] - sl[1]).collect();
                let validate: Validator = |lst, diff| {
                    let df = diff(lst);
                    df.iter().all(|&v| (1..=3).contains(&v.abs()))
                        && (df.iter().all(|v| v.is_positive())
                            || df.iter().all(|v| v.is_negative()))
                };

                let mut nums: Vec<i32> = l
                    .split_ascii_whitespace()
                    .filter_map(|s| s.parse().ok())
                    .collect();

                if validate(&nums, diff) {
                    return true;
                }

                let difs = diff(&nums);
                let mags = difs
                    .iter()
                    .map(|&v| ((1..=3).contains(&v.abs()), v > 0, v < 0))
                    .collect::<Vec<_>>();
                let pos = mags.iter().filter(|(_, b, _)| *b).count();
                let neg = mags.iter().filter(|(_, _, c)| *c).count();
                let failed = mags
                    .into_iter()
                    .enumerate()
                    .find(|&(_, (a, b, c))| !(a && (if pos > neg { b } else { c })))
                    .unwrap()
                    .0;
                let mut v1 = nums.clone();
                v1.remove(failed);
                nums.remove((failed + 1).min(nums.len() - 1));
                if validate(&v1, diff) || validate(&nums, diff) {
                    return true;
                };

                false
            })
            .count()
    }
}

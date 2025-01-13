use crate::advent_utils::Solution as AdventSolution;

pub struct Solution;

fn check_correctness(nums: &[i32]) -> bool {
    let diffs = nums.windows(2).map(|v| v[1] - v[0]).collect::<Vec<_>>();
    diffs.iter().all(|d| (1..3).contains(&d.abs()))
        && (diffs.iter().all(|d| d.signum() == -1) || diffs.iter().all(|d| d.signum() == 1))
}

impl AdventSolution for Solution {
    /// ```
    /// # use aoc2024::days;
    /// # use aoc2024::Solution as _;
    /// let input = std::fs::read_to_string("../../tests/2024/day02.txt").unwrap();
    /// assert_eq!(days::day02::Solution::part_1(&input), 2);
    /// ```
    fn part_1(data: &str) -> usize {
        data.lines()
            .filter(|l| {
                let mut prev = 0;
                let mut orig_diff = 0;
                for i in l
                    .split_ascii_whitespace()
                    .filter_map(|v| v.parse::<i32>().ok())
                {
                    let diff = prev - i;
                    if prev == 0 {
                        prev = i;
                        continue;
                    }
                    if orig_diff == 0 {
                        orig_diff = diff.signum();
                        prev = i;
                        continue;
                    }
                    if orig_diff != diff.signum() {
                        return false;
                    }

                    if diff.abs() > 3 || diff.abs() < 1 {
                        return false;
                    }
                    prev = i;
                }

                true
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
                let nums = l
                    .split_ascii_whitespace()
                    .filter_map(|v| v.parse::<i32>().ok())
                    .collect::<Vec<_>>();
                let diffs = nums.windows(2).map(|v| v[1] - v[0]).collect::<Vec<_>>();
                if check_correctness(&nums) {
                    return true;
                }
                // Then here drop the bad one and try again.
                // Start with magnitude since it's more precise.
                // 1. Find the number.
                // 2. Change both the prev and the next.
                // 3. If nothing found, go with the next rule.
                if let Some(bad) = diffs.iter().find(|v| !(1..3).contains(*v)) {
                    let first = nums
                        .iter()
                        .enumerate()
                        .filter(|(idx, _)| (*idx as i32) == *bad)
                        .map(|(_, b)| *b)
                        .collect::<Vec<_>>();
                    let second = nums
                        .iter()
                        .enumerate()
                        .filter(|(idx, _)| (*idx as i32) == *bad + 1)
                        .map(|(_, b)| *b)
                        .collect::<Vec<_>>();
                    if check_correctness(&first) || check_correctness(&second) {
                        return true;
                    }
                }
                let dir_plus_v = diffs.iter().map(|&d| d.is_positive()).collect::<Vec<_>>();
                let p = dir_plus_v.iter().filter(|&&v| v).count();
                let n = dir_plus_v.len() - p;
                let bad = dir_plus_v
                    .iter()
                    .enumerate()
                    .find(|(_, &b)| b == (p > n))
                    .unwrap()
                    .0;
                let first = nums
                    .iter()
                    .enumerate()
                    .filter(|(idx, _)| (*idx) == bad)
                    .map(|(_, b)| *b)
                    .collect::<Vec<_>>();
                let second = nums
                    .iter()
                    .enumerate()
                    .filter(|(idx, _)| (*idx) == bad + 1)
                    .map(|(_, b)| *b)
                    .collect::<Vec<_>>();
                if check_correctness(&first) || check_correctness(&second) {
                    return true;
                }
                false
            })
            .count()
    }
}

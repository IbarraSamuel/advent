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
                        let bts = &line.as_bytes()[line.len() / 2 - 1..line.len() / 2 + 1];
                        return 10 * bts[0] as isize - 11 * ZORD as isize + bts[1] as isize;
                    }

                    let val = &line[readed_idx * 3..readed_idx * 3 + 2];
                    let prev_values = &line[0..readed_idx * 3];

                    // if val in prev_dct:
                    let res = prev_dct.get(val);
                    let found = res.is_some_and(|res| res.iter().any(|v| prev_values.contains(v)));
                    if !found {
                        return 0;
                    }

                    // no next should be found
                    let res = next_dct.get(val);
                    let found = res.is_some_and(|res| res.iter().any(|v| prev_values.contains(v)));
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
    /// assert_eq!(days::day05::Solution::part_2(&input), 123);
    /// ```
    fn part_2(data: &str) -> usize {
        const ZORD: u8 = b'0';
        const INDEXES: [usize; 32] = build_indexes();
        let order_split = data.find("\n\n").unwrap();
        let rules = data[0..order_split]
            .lines()
            .map(|line| (&line[..2], &line[3..]))
            .collect::<Vec<_>>();

        data[order_split + 2..]
            .lines()
            .map(|page| {
                for (f, l) in &rules {
                    let fi = page.find(f);
                    let li = page.find(l);

                    if fi.is_some() && li.is_some() && fi > li {
                        let _idxs = order_manual(INDEXES, page, &rules);
                        let middle = page.len() / 2;
                        let _mididx = _idxs[(middle - 1) / 3];
                        let _middle = _mididx * 3 + 1;
                        let _nbr = &page[_middle as usize - 1.._middle as usize + 1];
                        let bts = _nbr.as_bytes();
                        return 10 * bts[0] as isize - 11 * ZORD as isize + bts[1] as isize;
                    }
                }
                0
            })
            .sum::<isize>() as usize
    }
}

fn order_manual(indexes: [usize; 32], page: &str, rules: &[(&str, &str)]) -> [usize; 32] {
    let mut done = false;
    let mut idx = indexes;
    let mut used_rules = Vec::<(usize, usize)>::new();
    for (first, last) in rules {
        let of = page.find(first);
        let ol = page.find(last);
        if let (Some(of), Some(ol)) = (of, ol) {
            used_rules.push((of, ol));
            let fi = idx.iter().position(|v| v.eq(&of)).unwrap();
            let li = idx.iter().position(|v| v.eq(&ol)).unwrap();
            if fi > li {
                idx.swap(fi, li);
            }
        }
    }

    while !done {
        done = true;
        for (of, ol) in &used_rules {
            let fi = idx.iter().position(|v| v.eq(of)).unwrap();
            let li = idx.iter().position(|v| v.eq(ol)).unwrap();
            if fi > li {
                idx.swap(fi, li);
            }
        }
    }

    idx
}

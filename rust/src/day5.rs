use crate::advent_utils::{AdventSolution, GenericResult};
use rayon::{
    iter::{IntoParallelIterator, ParallelIterator},
    slice::ParallelSlice,
};
use std::collections::{HashMap, HashSet};
pub struct Solution;

type HashMapper<'t> = HashMap<&'t str, (&'t str, Vec<(usize, usize, usize)>)>;

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
        let seeds = input[0]
            .strip_prefix("seeds: ")
            .unwrap()
            .split_whitespace()
            .filter_map(|s| s.parse::<usize>().ok())
            .collect::<Vec<_>>();

        let parse_maps: HashMapper = input
            .split(|l| l.is_empty())
            .skip(1)
            .map(|collection| {
                let (from, to) = collection
                    .first()
                    .unwrap()
                    .strip_suffix(" map:")
                    .unwrap()
                    .split_once("-to-")
                    .unwrap();
                let mappers = collection
                    .iter()
                    .skip(1)
                    .filter_map(|line| {
                        if let &[a, b, c] = line
                            .split_ascii_whitespace()
                            .filter_map(|v| v.parse::<usize>().ok())
                            .collect::<Vec<_>>()
                            .as_slice()
                        {
                            Some((b, a, c))
                        } else {
                            None
                        }
                    })
                    .collect::<Vec<_>>();
                (from, (to, mappers))
            })
            .collect::<HashMap<_, _>>();
        let final_values = seeds
            .iter()
            .map(|n| {
                let mut res = *n;
                let mut step = "seed";
                while let Some((next, mappers)) = parse_maps.get(&step) {
                    for &(init, end, len) in mappers {
                        if init <= res && res < init + len {
                            res = end + (res - init);
                            break;
                        }
                    }
                    step = next;
                }
                res
            })
            .min()
            .unwrap();
        Ok(final_values.to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
        let seeds = input[0]
            .strip_prefix("seeds: ")
            .unwrap()
            .split_whitespace()
            .filter_map(|s| s.parse::<usize>().ok())
            .collect::<Vec<_>>();

        let mut ranges = seeds
            .par_chunks_exact(2)
            .map(|chunk| (chunk[0], chunk.iter().sum::<usize>()))
            .collect::<Vec<_>>();

        let stages = input
            .split(|l| l.is_empty())
            .skip(1)
            .map(|col| {
                col[0]
                    .strip_suffix(" map:")
                    .unwrap()
                    .split_once("-to-")
                    .unwrap()
            })
            .collect::<HashMap<_, _>>();

        let parse_maps: HashMap<&str, Vec<(usize, usize, usize)>> = input
            .split(|l| l.is_empty())
            .skip(1)
            .map(|collection| {
                let op_name = collection
                    .first()
                    .unwrap()
                    .strip_suffix(" map:")
                    .unwrap()
                    .split_once("-to-")
                    .unwrap()
                    .1;
                let mappers = collection
                    .iter()
                    .skip(1)
                    .filter_map(|line| {
                        if let &[a, b, c] = line
                            .split_ascii_whitespace()
                            .filter_map(|v| v.parse::<usize>().ok())
                            .collect::<Vec<_>>()
                            .as_slice()
                        {
                            Some((b, a, c))
                        } else {
                            None
                        }
                    })
                    .collect::<_>();
                (op_name, mappers)
            })
            .collect::<HashMap<_, _>>();

        let final_values = seeds
            .into_par_iter()
            .map(|mut n| {
                let mut step = "seed";
                while let Some((next, mappers)) = parse_maps.get(&step) {
                    for &(init, end, len) in mappers {
                        if init <= n && n < init + len {
                            n = end + (n - init);
                            break;
                        }
                    }
                    step = next;
                }
                n
            })
            .min()
            .unwrap();
        Ok(final_values.to_string())
    }
}

crate::advent_test! {
    "../inputs/tests/day5_1.txt",
    "35",
    "../inputs/tests/day5_1.txt",
    "46"
}

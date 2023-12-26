use crate::advent_utils::{AdventSolution, GenericResult};
// use std::collections::HashMap;
pub struct Solution;

struct Bag(usize, usize, usize);

impl Bag {
    fn new() -> Self {
        Self(0, 0, 0)
    }

    fn update(&self, bag: &str) -> Bag {
        match bag.split_once(' ').unwrap() {
            (n, "red") => Bag(self.0 + n.parse::<usize>().unwrap(), self.1, self.2),
            (n, "green") => Bag(self.0, self.1 + n.parse::<usize>().unwrap(), self.2),
            (n, "blue") => Bag(self.0, self.1, self.2 + n.parse::<usize>().unwrap()),
            _ => panic!("Unknown color: {}", bag),
        }
    }

    fn max(&self, other: &Self) -> Self {
        Self(
            self.0.max(other.0),
            self.1.max(other.1),
            self.2.max(other.2),
        )
    }

    fn mul(&self) -> usize {
        self.0 * self.1 * self.2
    }
}

impl AdventSolution<String> for Solution {
    fn part1(input: Vec<String>) -> GenericResult<String> {
        let result = input
            .into_iter()
            .filter_map(|line| {
                let (game, raw_bags) = line.split_once(": ").unwrap();
                let id = game
                    .strip_prefix("Game ")
                    .unwrap()
                    .parse::<usize>()
                    .unwrap();
                raw_bags
                    .split("; ")
                    .map(
                        |bag| match bag.split(", ").collect::<Vec<&str>>().as_slice() {
                            [one] => Bag::new().update(one),
                            [one, two] => Bag::new().update(one).update(two),
                            [one, two, three] => Bag::new().update(one).update(two).update(three),
                            _ => panic!("Unknown bag: {}", bag),
                        },
                    )
                    .all(|bag| bag.0 <= 12 && bag.1 <= 13 && bag.2 <= 14)
                    .then_some(id)
            })
            .sum::<usize>();

        Ok(result.to_string())
    }

    fn part2(input: Vec<String>) -> GenericResult<String> {
        let result = input
            .into_iter()
            .map(|line| {
                line.split_once(": ")
                    .unwrap()
                    .1
                    .split("; ")
                    .fold(Bag(0, 0, 0), |acc, n| {
                        match n.split(", ").collect::<Vec<&str>>().as_slice() {
                            [one] => Bag::new().update(one).max(&acc),
                            [one, two] => Bag::new().update(one).update(two).max(&acc),
                            [one, two, three] => {
                                Bag::new().update(one).update(two).update(three).max(&acc)
                            }
                            _ => panic!("Unknown bag"),
                        }
                    })
                    .mul()
            })
            .sum::<usize>();

        Ok(result.to_string())
    }
}

crate::advent_test! {
    "../inputs/tests/day2_1.txt",
    "8",
    "../inputs/tests/day2_1.txt",
    "2286"
}

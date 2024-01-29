use std::collections::HashMap;

use crate::advent_utils::{AdventSolution, GenericResult};
use crate::{advent_test, advent_tests};

pub struct Solution;

#[derive(Debug)]
struct Card(usize);

impl From<char> for Card {
    fn from(value: char) -> Self {
        match value {
            'A' => Card(14),
            'K' => Self(13),
            'Q' => Self(12),
            'J' => Self(11),
            'T' => Self(10),
            _ => Self(value.to_digit(10).unwrap() as usize),
        }
    }
}

#[derive(Debug)]
struct Hand([Card; 5]);

impl From<&str> for Hand {
    fn from(value: &str) -> Self {
        let hand = value
            .chars()
            .map(|c| c.into())
            .collect::<Vec<Card>>()
            .try_into()
            .expect("Problem Parsing Card");

        Self(hand)
    }
}

impl Hand {
    fn value(&self) -> usize {
        let mut counts = HashMap::with_capacity(5);
        for card in &self.0 {
            *counts.entry(card.0).or_insert(0) += 1_usize
        }

        let card_category: usize = counts.values().map(|&v| v.pow(v as u32)).product();

        let cardv = self
            .0
            .iter()
            .rev()
            .enumerate()
            .map(|(i, c)| c.0 * 10_usize.pow(i as u32 * 2))
            .sum::<usize>();

        card_category * 10_usize.pow(self.0.len() as u32 * 2) + cardv
    }

    fn value_2(&self) -> usize {
        let mut counts = HashMap::with_capacity(5);
        for card in &self.0 {
            *counts
                .entry(if card.0 == 11 { 1 } else { card.0 })
                .or_insert(0) += 1_usize
        }

        // if the card is 1, I will add it to the top count of the hand.
        let max_card = *counts
            .iter()
            .filter(|(k, _)| **k != 1)
            .max_by_key(|(k, v)| *v * 100 + *k)
            .unwrap_or((&14, &0))
            .0;

        let joker_value = counts.remove_entry(&1).unwrap_or((0, 0)).1;
        *counts.entry(max_card).or_insert(0) += joker_value;
        let card_category: usize = counts.values().map(|&v| v.pow(v as u32)).product();

        let cardv = self
            .0
            .iter()
            .rev()
            .enumerate()
            .map(|(i, c)| (if c.0 == 11 { 1 } else { c.0 }) * 10_usize.pow(i as u32 * 2))
            .sum::<usize>();

        card_category * 10_usize.pow(self.0.len() as u32 * 2) + cardv
    }
}

impl AdventSolution for Solution {
    fn part1(input: Vec<String>) -> GenericResult<usize> {
        let mut hands = input
            .iter()
            .map(|s| {
                let (hand, bid) = s.split_once(' ').unwrap();
                let hand = Hand::from(hand);
                let bid = bid.parse::<usize>().unwrap();
                (hand, bid)
            })
            .collect::<Vec<_>>();

        hands.sort_by_key(|(hand, _)| hand.value());

        let result: usize = hands
            .iter()
            .enumerate()
            .map(|(pos, (_, bid))| (pos + 1) * bid)
            .sum();
        Ok(result)
    }

    fn part2(input: Vec<String>) -> GenericResult<usize> {
        let mut hands = input
            .iter()
            .map(|s| {
                let (hand, bid) = s.split_once(' ').unwrap();
                let hand = Hand::from(hand);
                let bid = bid.parse::<usize>().unwrap();
                (hand, bid)
            })
            .collect::<Vec<_>>();

        // Using value 2 instead of value to have the second version.
        hands.sort_by_key(|(hand, _)| hand.value_2());

        let result: usize = hands
            .iter()
            .enumerate()
            .map(|(pos, (_, bid))| (pos + 1) * bid)
            .sum();
        Ok(result)
    }
}

advent_tests!(
    part 1 => (
        "../inputs/tests/day7.txt" => 6440
    ),
    part 2 => (
        "../inputs/tests/day7.txt" => 5905
    )
);

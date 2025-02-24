use crate::common::{AdventResult, GenericResult};

pub(super) struct Solution;

#[derive(PartialEq)]
enum GameOption {
    Rock,
    Paper,
    Cissors,
}

impl From<&str> for GameOption {
    fn from(value: &str) -> Self {
        match value {
            "X" | "A" => Self::Rock,
            "Y" | "B" => Self::Paper,
            "Z" | "C" => Self::Cissors,
            _ => panic!(),
        }
    }
}

impl From<&GameOption> for i64 {
    fn from(value: &GameOption) -> Self {
        match value {
            GameOption::Rock => 1,
            GameOption::Paper => 2,
            GameOption::Cissors => 3,
        }
    }
}

impl GameOption {
    fn get_result(&self, other: &Self) -> GameResult {
        match (other, self) {
            (Self::Rock, Self::Paper) => GameResult::Win,
            (Self::Rock, Self::Cissors) => GameResult::Loose,
            (Self::Paper, Self::Rock) => GameResult::Loose,
            (Self::Paper, Self::Cissors) => GameResult::Win,
            (Self::Cissors, Self::Rock) => GameResult::Win,
            (Self::Cissors, Self::Paper) => GameResult::Loose,
            _ => GameResult::Tie,
        }
    }

    fn infer_decision(other: Self, result: &GameResult) -> Self {
        [Self::Rock, Self::Paper, Self::Cissors]
            .into_iter()
            .find(|mine| Self::get_result(mine, &other).eq(result))
            .unwrap()
    }
}

#[derive(PartialEq)]
enum GameResult {
    Win,
    Loose,
    Tie,
}

impl From<&GameResult> for i64 {
    fn from(value: &GameResult) -> Self {
        match value {
            GameResult::Win => 6,
            GameResult::Tie => 3,
            GameResult::Loose => 0,
        }
    }
}

impl From<&str> for GameResult {
    fn from(value: &str) -> Self {
        match value {
            "X" => Self::Loose,
            "Y" => Self::Tie,
            "Z" => Self::Win,
            _ => panic!(),
        }
    }
}

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        let output = input
            .iter()
            .filter_map(|v| {
                v.split_once(' ').map(|(other, mine)| {
                    let mine = mine.into();
                    let other = other.into();
                    let result = GameOption::get_result(&mine, &other);
                    i64::from(&result) + i64::from(&mine)
                })
            })
            .sum::<i64>()
            .to_string();

        Ok(output)
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        let output = input
            .iter()
            .filter_map(|v| {
                v.split_once(' ').map(|(other, result)| {
                    let result: GameResult = result.into();
                    let other = other.into();
                    let mine = GameOption::infer_decision(other, &result);
                    i64::from(&result) + i64::from(&mine)
                })
            })
            .sum::<i64>()
            .to_string();

        Ok(output)
    }
}

crate::advent_test! {
    day2,
    r#"
    A Y
    B X
    C Z
    "#,
    "15",
    "12"
}

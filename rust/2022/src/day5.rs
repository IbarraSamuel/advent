use crate::common::{AdventResult, GenericResult};

pub(super) struct Solution;

struct Input {
    stacks: Vec<Stack>,
    instructions: Vec<Instruction>,
}

type Stack = Vec<char>;

struct Instruction {
    quantity: usize,
    from: usize,
    to: usize,
}

fn parse_input(input: Vec<String>) -> Option<Input> {
    let (raw_stacks, raw_instr) = input.split_at(input.iter().position(|s| s.is_empty())?);

    let stacks = (0..raw_stacks.last()?.split_whitespace().count())
        .map(|x| {
            raw_stacks
                .iter()
                .rev()
                .skip(1)
                .filter_map(move |s| s.chars().nth(x * 4 + 1).filter(|&c| !c.is_whitespace()))
                .collect::<Stack>()
        })
        .collect::<Vec<_>>();

    let instructions = raw_instr
        .iter()
        .filter_map(|s| {
            if let &[quantity, from, to] = s
                .split_whitespace()
                .filter_map(|s| s.parse::<usize>().ok())
                .collect::<Vec<_>>()
                .as_slice()
            {
                Some(Instruction { quantity, from, to })
            } else {
                None
            }
        })
        .collect();

    Some(Input {
        stacks,
        instructions,
    })
}

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        dbg!(&input);
        let Input {
            mut stacks,
            instructions,
        } = parse_input(input).ok_or("Bad input parsing")?;

        for Instruction { quantity, from, to } in instructions {
            let split_index = stacks[from - 1].len() - quantity;
            let mut to_move = stacks[from - 1].split_off(split_index);
            to_move.reverse();
            stacks[to - 1].append(&mut to_move);
        }

        let result = stacks.iter().filter_map(|v| (v.last())).collect::<String>();

        Ok(result)
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        let Input {
            mut stacks,
            instructions,
        } = parse_input(input).ok_or("Bad input parsing")?;

        for Instruction { quantity, from, to } in instructions {
            let split_index = stacks[from - 1].len() - quantity;
            let mut to_move = stacks[from - 1].split_off(split_index);
            stacks[to - 1].append(&mut to_move);
        }

        let result = stacks.iter().filter_map(|v| (v.last())).collect::<String>();

        Ok(result)
    }
}

crate::advent_test! {
    day5,
    r#"
        [D]    
    [N] [C]    
    [Z] [M] [P]
     1   2   3 

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    "#,
    "CMZ",
    "MCD"
}

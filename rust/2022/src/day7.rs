use std::fmt::{Debug, Display};

use crate::common::{AdventResult, GenericResult};
use std::collections::HashMap;

pub(super) struct Solution;

#[derive(Debug)]
enum Operation<'a> {
    Cd(Cd<'a>),
    Ls(Vec<File<'a>>),
    File(File<'a>),
}

#[derive(Debug)]
enum Cd<'a> {
    Root,
    Up,
    Down(&'a str),
}

#[derive(Debug, Clone)]
enum File<'a> {
    File { size: u32, name: &'a str },
    Dir(&'a str),
}

struct Dir<'a> {
    content: HashMap<&'a str, File<'a>>,
    name: String,
    parent: Option<&'a Dir<'a>>,
}

impl<'a> From<&'a String> for Operation<'a> {
    fn from(value: &String) -> Self {
        match value.split(' ').collect::<Vec<_>>()[..] {
            ["$", "ls"] => Operation::Ls(vec![]),
            ["$", "cd", "/"] => Operation::Cd(Cd::Root),
            ["$", "cd", ".."] => Operation::Cd(Cd::Up),
            ["$", "cd", dir] => Operation::Cd(Cd::Down(dir.clone().into())),
            ["dir", name] => Operation::File(File::Dir(name.clone().into())),
            [size, name] => Operation::File(File::File {
                size: size.parse().unwrap(),
                name: name.clone().into(),
            }),
            _ => panic!("Bad path not covered"),
        }
    }
}

impl AdventResult for Solution {
    fn calculation_1(input: Vec<String>) -> GenericResult<String> {
        let operations = input
            .iter()
            .map(|&s| Operation::from(&s))
            .collect::<Vec<_>>();
        todo!()
    }

    fn calculation_2(input: Vec<String>) -> GenericResult<String> {
        Ok("".into())
    }
}

crate::advent_test! {
    day7,
    r#"
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    "#,
    "95437",
    ""
}

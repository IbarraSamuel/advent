use std::path::Path;

pub trait Solution {
    fn part_1(data: &str) -> u32;
    fn part_2(data: &str) -> u32;
}

type DaySolution = (&'static str, fn(&str) -> u32, fn(&str) -> u32);

pub struct Solver {
    i: usize,
    solutions: [DaySolution; 25],
}

impl Solver {
    pub fn builder() -> Self {
        Self {
            i: 0,
            solutions: [("", |_| 0, |_| 0); 25],
        }
    }
    pub fn add<S: Solution>(&self, path: &'static str) -> Self {
        let mut s = Self { ..*self };
        s.solutions[s.i] = (path, S::part_1, S::part_2);
        s.i += 1;
        s
    }

    pub fn compute(self) {
        for (path, part_1, part_2) in self.solutions {
            run(path, part_1, part_2);
        }
    }
}
pub fn run<P: AsRef<Path>>(path: P, part_1: fn(&str) -> u32, part_2: fn(&str) -> u32) {
    if path.as_ref().to_str().unwrap() == "" {
        return;
    }
    println!("From {:?} =>", path.as_ref());
    let data = std::fs::read_to_string(path).expect("Error while reading the file. Aborting.");
    let data = data.trim();

    let result_1 = part_1(data);
    println!("\tPart 1: {result_1}");

    let result_2 = part_2(data);
    println!("\tPart 2: {result_2}");
}

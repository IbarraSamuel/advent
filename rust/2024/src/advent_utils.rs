use std::path::Path;
type DaySolution = (fn(&str) -> u32, fn(&str) -> u32);

pub trait Solution {
    fn part_1(data: &str) -> u32;
    fn part_2(data: &str) -> u32;
}

pub struct Solver {
    i: usize,
    solutions: [DaySolution; 25],
    path: &'static Path,
}

impl Solver {
    pub fn from(path: &'static str) -> Self {
        Self {
            i: 0,
            solutions: [(|_| 0, |_| 0); 25],
            path: path.as_ref(),
        }
    }
    pub fn add<S: Solution>(&self) -> Self {
        let mut s = Self { ..*self };
        s.solutions[s.i] = (S::part_1, S::part_2);
        s.i += 1;
        s
    }

    pub fn compute(self) {
        for (n, (part_1, part_2)) in self.solutions.into_iter().enumerate() {
            let fname = format!("day{:02}.txt", n + 1);
            let path = self.path.join(fname);
            run(path, part_1, part_2);
        }
    }
}
pub fn run(path: std::path::PathBuf, part_1: fn(&str) -> u32, part_2: fn(&str) -> u32) {
    if !path.exists() {
        return;
    }
    println!("From {:?} =>", path);
    let data = std::fs::read_to_string(path).expect("Error while reading the file. Aborting.");
    let data = data.trim();

    let result_1 = part_1(data);
    println!("\tPart 1: {result_1}");

    let result_2 = part_2(data);
    println!("\tPart 2: {result_2}");
}

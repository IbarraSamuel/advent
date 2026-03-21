use std::path::Path;
use toml;
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
            let day = format!("{:02}", n + 1);
            let fname = format!("day{day}.txt");
            let path = self.path.join(fname);
            run(path, day, part_1, part_2);
        }
    }
}

pub fn run(
    path: std::path::PathBuf,
    day: String,
    part_1: fn(&str) -> u32,
    part_2: fn(&str) -> u32,
) {
    if !path.exists() {
        return;
    }
    println!("Day {day} =>");
    let data = std::fs::read_to_string(path).expect("Error while reading the file. Aborting.");

    let result_1 = part_1(&data);
    println!("\tPart 1: {result_1}");

    let result_2 = part_2(&data);
    println!("\tPart 2: {result_2}\n");
}

pub fn read_toml(file: std::path::PathBuf) -> Result<toml::Table, toml::de::Error> {
    let file_data = std::fs::read_to_string(file).unwrap();
    file_data.parse::<toml::Table>()
}

fn run_test(
    year: u32,
    day: u8,
    part: u8,
    solution: fn(&str) -> u32,
    toml_content: toml::Table,
) -> Result<(), dyn std::error::Error> {
    let file = file!();
    let current_file = std::path::PathBuf::from(file);
    let Some(config_path) = current_file
        .parent()
        .and_then(|p| p.parent())
        .and_then(|p| p.parent())
        .and_then(|p| p.parent())
        .map(|p| p.join("advent_config.toml"))
    else {
        return "Not Valid config path!".into();
    };
    let Some(test_cases) = toml_content
        .get("tests")
        .and_then(|t| t.get("year"))
        .and_then(|t| t.get(String::from(year)))
        .and_then(|t| t.get("day"))
        .and_then(|t| t.get(String::from(day)))
        .and_then(|t| t.get("part"))
        .and_then(|t| t.get(String::from(part)))
    else {
        return "Failed to get testcases for given year/day/part.".into();
    };

    let Some(cases) = test_cases.as_array() else {
        return "test cases are not lists.".into();
    };

    let cases = cases.iter().filter_map(|v| {
        let file = v.get("file")?.as_str()?;
        let expected = v.get("expected")?.as_integer()? as u32;

        Some((file, expected))
    });

    for (file, expected) in cases {
        let content = std::fs::read_to_string(file)?;
        assert_eq!(solution(&content), expected);
    }
    Ok(())
}

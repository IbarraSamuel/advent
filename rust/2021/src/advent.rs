#![allow(unused)]

mod common_definitions {
    use std::fs::read_to_string;
    pub(super) fn read_input(path: &str) -> Vec<String> {
        read_to_string(path)
            .expect("Error reading file")
            .split('\n')
            .map(|s| s.to_string())
            .collect()
    }

    pub enum ChallengeStep {
        Star1,
        Star2
    }
}

pub mod day_1 {
    use std::fs;

    pub fn run() {
        println!("Day 1:");
        let input: Vec<u32> = fs::read_to_string("./../day1/input.txt")
            .expect("Error reading file!")
            .split('\n')
            .map(|v| {
                v.parse::<u32>()
                    .expect(["Error parsing ", v].concat().as_str())
            })
            .collect();

        println!("{}", count_with_noise(&input));
    }

    fn count_increases(input_values: &[u32]) -> u32 {
        input_values
            .iter()
            .fold((0, 0), |acc, &n| {
                if acc.1 < n {
                    (acc.0 + 1, n)
                } else {
                    (acc.0, n)
                }
            })
            .0
            - 1
    }

    fn count_with_noise(measurements: &[u32]) -> u32 {
        let values: Vec<u32> = (0..measurements.len() - 2)
            .map(|i| (0..3).map(|j| measurements[i + j]).sum::<u32>())
            .collect();

        count_increases(&values.as_slice())
    }
}

pub mod day_2 {
    use std::fs;

    pub fn run() {
        println!("Day 2:");
        let path = "./../day2/input.txt";
        println!("{}", part_1(path));
    }

    enum Direction {
        Forward(usize),
        Down(usize),
        Up(usize),
        None,
    }

    impl Direction {
        fn new(dir: &str, quant: usize) -> Self {
            match dir {
                "forward" => Self::Forward(quant),
                "up" => Self::Up(quant),
                "down" => Self::Down(quant),
                _ => Self::None,
            }
        }

        fn act_pos(self, Position(x, y): &Position, Aim(a): &Aim) -> Option<(Position, Aim)> {
            match self {
                Self::Forward(dx) => Some((Position(x + dx, *y + *a * dx), Aim(*a))),
                Self::Up(dy) => Some((Position(*x, *y), Aim(*a - dy))),
                Self::Down(dy) => Some((Position(*x, *y), Aim(*a + dy))),
                Self::None => None,
            }
        }
    }

    struct Person<'t> {
        name: String,
        age: u8,
        work: Workplace<'t>,
    }

    enum Workplace<'t> {
        Public(&'t str),
        Private(&'t str),
    }

    struct Position(usize, usize);
    struct Aim(usize);

    fn part_1(path: &str) -> usize {
        let (mut pos, mut aim) = (Position(0, 0), Aim(0));
        let person = Person {
            name: "Samuel".to_string(),
            age: 18,
            work: Workplace::Private("UTP"),
        };

        fs::read_to_string(path)
            .expect("error reading input")
            .split('\n')
            .map(|s| {
                let (dir, quant) = s.split_once(' ').expect("error splitting");
                let quant = quant
                    .parse::<usize>()
                    .expect("Error parsing usize from input");
                Direction::new(dir, quant)
            })
            .for_each(|dir| {
                let tp = dir
                    .act_pos(&pos, &aim)
                    .expect("a bad value found in the input array");
                pos = tp.0;
                aim = tp.1;
            });

        return pos.0 * pos.1;
    }
}

pub mod day_3 {
    use std::fs;
    pub fn run() {
        let path = "./../day3/input.txt";

        let input_string = fs::read_to_string(path).expect("Error reading file");

        let bytes_vec: Vec<Vec<u8>> = input_string
            .split('\n')
            .map(|s| {
                s.chars()
                    .map(|c| match c {
                        '1' => 1,
                        '2' => 0,
                        _ => 0,
                    })
                    .collect()
            })
            .collect();

        println!("Power consumption: {:?}", power_consumption(&bytes_vec));
        println!("Life support rating: {:?}", life_support_rating(bytes_vec));
        // let gamma_rate: &[bool] =
    }

    fn power_consumption(bytes: &Vec<Vec<u8>>) -> usize {
        let mut gamma_rate = String::new();
        let mut epsilon_rate = String::new();

        for pos in 0..bytes[0].len() {
            let arr = bytes
                .iter()
                .map(|b| b[pos] as usize)
                .collect::<Vec<usize>>();
            let total = arr.iter().sum::<usize>() as f32;
            let mean = total / arr.len() as f32;
            if mean > 0.5 {
                gamma_rate.push('1');
                epsilon_rate.push('0');
            } else {
                gamma_rate.push('0');
                epsilon_rate.push('1');
            }
        }

        let gamma = usize::from_str_radix(gamma_rate.as_str(), 2).expect("Error getting dec");
        let epsilon = usize::from_str_radix(epsilon_rate.as_str(), 2).expect("Error getting dec");
        gamma * epsilon
    }

    fn life_support_rating(bytes: Vec<Vec<u8>>) -> Option<usize> {
        let mut oxygen: Vec<Vec<u8>> = bytes.clone();
        let mut co2: Vec<Vec<u8>> = bytes.clone();

        for pos in 0..bytes[0].len() {
            if oxygen.len() > 1 {
                let oxygen_values: Vec<usize> = oxygen.iter().map(|v| v[pos] as usize).collect();
                let oxygen_mean =
                    oxygen_values.iter().sum::<usize>() as f32 / oxygen_values.len() as f32;
                let oxygen_most = if oxygen_mean >= 0.5 { 1. } else { 0. };
                oxygen = oxygen
                    .into_iter()
                    .filter(|v| v[pos] as f32 == oxygen_most)
                    .collect();
            }

            if co2.len() > 1 {
                let co2_values: Vec<usize> = co2.iter().map(|v| v[pos] as usize).collect();
                let co2_mean = co2_values.iter().sum::<usize>() as f32 / co2_values.len() as f32;
                let co2_most = if co2_mean >= 0.5 { 0. } else { 1. };
                co2 = co2
                    .into_iter()
                    .filter(|v| v[pos] as f32 == co2_most)
                    .collect();
            }
        }

        if oxygen.len() != 1 || co2.len() != 1 {
            println!("Error in this program");
            println!("oxygen len: {}", oxygen.len());
            println!("co2 len: {}", co2.len());
            return None;
        }

        let oxygen_str = oxygen[0]
            .iter()
            .map(|v| format!("{}", v))
            .collect::<Vec<String>>()
            .concat();
        let co2_str = co2[0]
            .iter()
            .map(|v| format!("{}", v))
            .collect::<Vec<String>>()
            .concat();

        let ox = usize::from_str_radix(oxygen_str.as_str(), 2).expect("Error getting dec");
        let co = usize::from_str_radix(co2_str.as_str(), 2).expect("Error getting dec");
        println!("ox:{}, co:{}", &ox, &co);
        Some(ox * co)
    }
}

pub mod day_4 {
    use super::common_definitions::read_input;
    pub fn run() {
        let path = "./../day4/input.txt";
        let input = read_input(path);
        let numbers = get_numbers(&input);
        let boards = get_boards(&input);
        let (winner, used_n) =
            get_winner_board_and_number(numbers, boards).expect("No winner in this program!");
        println!("Result: {}", get_result_value(winner, used_n));
    }

    fn get_numbers(input: &Vec<String>) -> Vec<u32> {
        input[0]
            .split(',')
            .filter_map(|s| s.parse::<u32>().ok())
            .collect()
    }

    fn get_boards(input: &Vec<String>) -> Vec<Vec<Vec<u32>>> {
        input
            .split(|s| s == "")
            .skip(1)
            .map(|str_arr| {
                // aqui construimos un tablero
                str_arr
                    .iter()
                    .map(|row| {
                        // construimos las filas
                        row.trim()
                            .split(' ')
                            .filter_map(|s| s.parse::<u32>().ok())
                            .collect::<Vec<_>>()
                    })
                    .collect::<Vec<_>>()
            })
            .collect()
    }

    fn board_is_winner(board: &Vec<Vec<u32>>, used: &Vec<u32>) -> bool {
        let row_winner = board
            .iter()
            .any(|row| row.iter().all(|n| used.iter().any(|u| u == n)));

        let col_winner = (0..board[0].len()).any(|c_idx| {
            board
                .iter()
                .map(|rw| &rw[c_idx])
                .all(|v| used.iter().any(|u| u == v))
        });

        row_winner || col_winner
    }

    /// Returns the winner board and the last number that get this board to win!
    fn get_winner_board_and_number(
        numbers: Vec<u32>,
        mut boards: Vec<Vec<Vec<u32>>>,
    ) -> Option<(Vec<Vec<u32>>, Vec<u32>)> {
        let mut used = Vec::with_capacity(numbers.len());

        for n in numbers {
            used.push(n);
            for board in boards.clone() {
                if board_is_winner(&board, &used) {
                    if boards.len() == 1 {
                        return Some((board, used));
                    }
                    let idx = boards.iter().position(|b| b == &board).unwrap();
                    boards.remove(idx);
                }
            }
        }

        println!("You dont have a winner! :(");
        return None;
    }

    fn get_result_value(mut board: Vec<Vec<u32>>, used: Vec<u32>) -> u32 {
        let total_sum: u32 = board
            .iter()
            .map(|row| {
                row.into_iter()
                    .filter(|&n| !used.iter().any(|v| v == n))
                    .sum::<u32>()
            })
            .sum();

        println!(
            "Total sum: {}, winner_number: {}",
            &total_sum,
            used[used.len() - 1]
        );

        total_sum * used.last().unwrap()
    }
}

pub mod day_5 {
    use super::common_definitions::read_input;
    use std::{collections::HashMap, hash::Hash};

    pub fn run() {
        let path = "./../day5/input.txt";
        let input = read_input(path);
        let pair_positions_vec = input_to_positions_vec(&input);
        let routes_vec = pair_positions_vec
            .iter()
            .map(|(p1, p2)| p1.only_square_distance_points(p2))
            .filter_map(|r| r)
            .collect::<Vec<_>>();
        let mut position_count = HashMap::<Position, usize>::new();
        let count = count_vectors_repeated(&mut position_count, &routes_vec);

        println!("Repeated: {}", count);
    }

    fn input_to_positions_vec(input: &Vec<String>) -> Vec<(Position, Position)> {
        input
            .iter()
            .map(|s: &String| {
                let (p1, p2) = s.split_once(" -> ").unwrap();
                let (x1, y1) = p1.split_once(',').unwrap();
                let (x2, y2) = p2.split_once(',').unwrap();
                let (x1, y1) = (x1.parse::<usize>().unwrap(), y1.parse::<usize>().unwrap());
                let (x2, y2) = (x2.parse::<usize>().unwrap(), y2.parse::<usize>().unwrap());
                (Position { x: x1, y: y1 }, Position { x: x2, y: y2 })
            })
            .collect::<Vec<_>>()
    }

    fn count_vectors_repeated(
        position_count: &mut HashMap<Position, usize>,
        routes: &Vec<Vec<Position>>,
    ) -> usize {
        routes.iter().flatten().for_each(|pos| {
            let counter = position_count.entry(pos.clone()).or_insert(0);
            *counter += 1;
        });

        position_count.retain(|_, &mut c| c > 1);
        position_count.len()
    }

    #[derive(PartialEq, Eq, Clone, Hash, Debug)]
    struct Position {
        x: usize,
        y: usize,
    }

    impl Position {
        fn only_square_distance_points(&self, other: &Self) -> Option<Vec<Position>> {
            match self {
                pos if pos == other => Some(vec![pos.clone()]),
                Position { x, .. } if *x == other.x => {
                    let (init, end) = if self.y < other.y {
                        (self.y, other.y)
                    } else {
                        (other.y, self.y)
                    };
                    let points = (init..=end)
                        .map(|v| Position { x: *x, y: v })
                        .collect::<Vec<_>>();
                    Some(points)
                }
                Position { y, .. } if *y == other.y => {
                    let (init, end) = if self.x < other.x {
                        (self.x, other.x)
                    } else {
                        (other.x, self.x)
                    };
                    let points = (init..=end)
                        .map(|v| Position { x: v, y: *y })
                        .collect::<Vec<_>>();
                    Some(points)
                }
                Position { x, y }
                    if (*x as i64 - other.x as i64).abs() == (*y as i64 - other.y as i64).abs() =>
                {
                    let (next_x, next_y): (i32, i32) = (
                        if *x < other.x { 1 } else { -1 },
                        if *y < other.y { 1 } else { -1 },
                    );
                    let points = (0..=(*x as i32 - other.x as i32).abs())
                        .map(|i| Position {
                            x: (*x as i32 + next_x * i) as usize,
                            y: (*y as i32 + next_y * i) as usize,
                        })
                        .collect::<Vec<_>>();
                    Some(points)
                }
                _ => None,
            }
        }
    }
}

pub mod day_6 {
    use super::common_definitions::read_input;
    use std::collections::HashMap;

    pub fn run() {
        let input = read_input("./../day6/input.txt");
        let mut generation: HashMap<u16, usize> = HashMap::new();
        generation.extend((0..=8).map(|n| (n, 0)));
        let loaded_generation = load_input_generation(input, generation);
        let final_generation = run_evolution(loaded_generation, 256);
        println!(
            "Generation len: {}",
            final_generation.values().sum::<usize>()
        );
    }

    fn load_input_generation(
        input: Vec<String>,
        mut generation: HashMap<u16, usize>,
    ) -> HashMap<u16, usize> {
        input[0]
            .split(',')
            .filter_map(|s| s.parse::<u16>().ok())
            .for_each(|f| {
                let count = generation.entry(f).or_insert(0);
                *count += 1;
            });
        generation
    }

    fn run_evolution(
        mut loaded_generation: HashMap<u16, usize>,
        days: usize,
    ) -> HashMap<u16, usize> {
        for _ in 0..days {
            let new = loaded_generation[&0];
            (0..=7).for_each(|v| {
                loaded_generation.insert(v, loaded_generation[&(v + 1)]);
            });
            loaded_generation.insert(6, loaded_generation[&6] + new);
            loaded_generation.insert(8, new);
        }
        loaded_generation
    }
}

pub mod day_7 {
    use super::common_definitions::read_input;
    use std::collections::HashMap;

    pub fn run() {
        let input = read_input("./../day7/input.txt")[0]
            .split(',')
            .filter_map(|s| s.parse::<usize>().ok())
            .collect::<Vec<_>>();
        let final_best = select_best(&input);
        println!("Best Value: {}, Best Cost: {}", final_best.0, final_best.1);
    }

    fn select_best(input: &Vec<usize>) -> (usize, i32) {
        let mut count_input = HashMap::new();
        input.iter().for_each(|n| {
            let count = count_input.entry(n).or_insert(0);
            *count += 1;
        });

        fn fact(n: i32) -> i32 {
            if n == 0 || n == 1 {
                return n;
            }
            (2..=n).sum()
        }

        (**count_input.keys().min().unwrap()..**count_input.keys().max().unwrap())
            .map(|k| {
                (
                    k,
                    count_input.iter().fold(0, |acc, (&&nk, nv)| {
                        acc + nv * fact((k as i32 - nk as i32).abs())
                    }),
                )
            })
            .min_by_key(|(k, v)| *v)
            .unwrap()
    }
}

pub mod day_8 {
    use super::common_definitions::read_input;
    use std::collections::{HashMap, HashSet};
    use std::ops::{Add, Neg, Sub};

    #[derive(Hash, Clone, Eq, PartialEq)]
    pub(super) struct Segments(pub String);

    impl Iterator for Segments {
        type Item = char;
        fn next(&mut self) -> Option<Self::Item> {
            self.0.chars().next()
        }
    }

    impl Sub<Segments> for Segments {
        type Output = Self;
        fn sub(self, other: Self) -> Self::Output {
            let a = Self(
                self.0
                    .chars()
                    .collect::<HashSet<_>>()
                    .difference(&other.0.chars().collect::<HashSet<_>>())
                    .collect(),
            );
            a
        }
    }

    impl Add for Segments {
        type Output = Self;
        fn add(self, other: Self) -> Self::Output {
            Self(
                self.0
                    .chars()
                    .collect::<HashSet<_>>()
                    .union(&other.0.chars().collect())
                    .collect(),
            )
        }
    }

    impl Neg for Segments {
        type Output = Self;
        fn neg(self) -> Self::Output {
            Self(
                "abcdefg"
                    .chars()
                    .collect::<HashSet<_>>()
                    .difference(&self.0.chars().collect())
                    .collect(),
            )
        }
    }

    impl Segments {
        pub fn new(str_input: &str) -> Self {
            Segments(str_input.to_string())
        }

        fn len(&self) -> usize {
            self.0.len()
        }

        fn is_equal_to(&self, other: &Self) -> bool {
            self.0
                .chars()
                .collect::<HashSet<_>>()
                .difference(&other.0.chars().collect())
                .count()
                == 0
        }
    }

    pub(super) struct DisplayConfig {
        pub elements: HashMap<Segments, usize>,
    }

    impl DisplayConfig {
        pub fn new(mut elems: HashSet<Segments>) -> Self {
            let mut elems_dict = HashMap::new();

            let num_1 = elems.iter().find(|s| s.len() == 2).unwrap().clone();
            elems_dict.insert(elems.take(&num_1).unwrap(), 1);

            let num_4 = elems.iter().find(|s| s.len() == 4).unwrap().clone();
            elems_dict.insert(elems.take(&num_4).unwrap(), 4);

            let num_7 = elems.iter().find(|s| s.len() == 3).unwrap().clone();
            elems_dict.insert(elems.take(&num_7).unwrap(), 7);

            let num_8 = elems.iter().find(|s| s.len() == 7).unwrap().clone();
            elems_dict.insert(elems.take(&num_8).unwrap(), 8);

            let num_6 = elems
                .iter()
                .find(|e| (-num_1.clone()).is_equal_to(&((e.clone()).clone() - num_1.clone())))
                .unwrap()
                .clone();
            elems_dict.insert(elems.take(&num_6).unwrap(), 6);

            let num_9 = elems
                .iter()
                .find(|e| e.len() == 6 && ((e.clone()).clone() - num_4.clone()).len() == 2)
                .unwrap()
                .clone();
            elems_dict.insert(elems.take(&num_9).unwrap(), 9);

            let num_0 = elems.iter().find(|e| e.len() == 6).unwrap().clone();
            elems_dict.insert(elems.take(&num_0).unwrap(), 6);

            let num_5 = elems
                .iter()
                .find(|e| ((e.clone()).clone() - num_6.clone()).len() == 0)
                .unwrap()
                .clone();
            elems_dict.insert(elems.take(&num_5).unwrap(), 5);

            let num_3 = elems
                .iter()
                .find(|e| ((e.clone()).clone() - num_7.clone()).len() == 2)
                .unwrap()
                .clone();
            elems_dict.insert(elems.take(&num_3).unwrap(), 3);

            let num_2 = elems.iter().next().unwrap().clone();
            elems_dict.insert(elems.take(&num_2).unwrap(), 2);

            assert_eq!(elems.len(), 0);
            assert_eq!(elems_dict.len(), 10);
            DisplayConfig {
                elements: elems_dict,
            }
        }

        pub fn get_number(&self, secuence: &str) -> usize {
            let input_sec: HashSet<char> = secuence.chars().collect();
            let key = self
                .elements
                .keys()
                .find(|k| {
                    input_sec
                        .symmetric_difference(&k.0.chars().collect::<HashSet<char>>())
                        .count()
                        == 0
                })
                .unwrap();
            *self.elements.get(&key).unwrap()
        }
    }

    pub fn run() {
        let input = read_input("./../day8/input.txt");
        let config_num: Vec<(&str, &str)> =
            input.iter().map(|v| v.split_once(" | ").unwrap()).collect();

        let result = config_num
            .iter()
            .map(|(conf, nums)| {
                let segs = conf
                    .split(' ')
                    .map(|s| Segments::new(s))
                    .collect::<HashSet<Segments>>();
                let conf = DisplayConfig::new(segs);
                let nums_len = nums.split(" ").count();

                nums.split(' ')
                    .enumerate()
                    .map(|(pos, n)| {
                        usize::pow(10, (nums_len as i32 - pos as i32 - 1) as u32)
                            * conf.get_number(n)
                    })
                    .sum::<usize>()
            })
            .sum::<usize>();
        println!("ans: {}", result);
    }
}

pub mod day_8_2 {
    use super::common_definitions::read_input;
    pub fn run() {
        let input = read_input("./../day8/input.txt");
        let ans = input
            .into_iter()
            .map(|s| {
                let (conf, nums) = s.split_once(" | ").unwrap();
                let conf_tuple = infer_segments_tuple(conf);
                get_big_number_from_nums(nums, conf_tuple)
            })
            .sum::<i32>();

        println!("Ans: {}", ans);
    }

    fn infer_segments_tuple(conf: &str) -> Vec<(char, char)> {
        let nums = conf
            .split(' ')
            .map(|s| s.to_string())
            .collect::<Vec<String>>();
        let known_nums_segs = get_known_numbers(&nums).concat();
        let all_nums_segs = nums.concat();

        let config_segs = nums.iter().find(|num| num.len() == 7).unwrap().clone();
        get_seg_correction_tuples(&config_segs, &all_nums_segs, &known_nums_segs)
    }

    fn get_known_numbers(nums: &Vec<String>) -> Vec<String> {
        nums.into_iter()
            .map(|n| n.to_string())
            .filter(|num| [2, 3, 4, 7].contains(&num.len()))
            .collect()
    }

    fn get_seg_correction_tuples(
        config_segs: &String,
        all_segs: &String,
        known_segs: &String,
    ) -> Vec<(char, char)> {
        config_segs
            .chars()
            .map(|c| {
                let all_count = all_segs.chars().filter(|&fc| fc == c).count();
                let known_count = known_segs.chars().filter(|&fc| fc == c).count();
                (
                    c,
                    match (all_count, known_count) {
                        (8, 2) => 'a',
                        (6, 2) => 'b',
                        (8, 4) => 'c',
                        (7, 2) => 'd',
                        (4, 1) => 'e',
                        (9, 4) => 'f',
                        (7, 1) => 'g',
                        _ => {
                            println!("Error in matching arm inside segments chars");
                            'X'
                        }
                    },
                )
            })
            .collect::<Vec<_>>()
    }

    fn get_big_number_from_nums(num_str: &str, tuple_mapper: Vec<(char, char)>) -> i32 {
        num_str
            .split(' ')
            .map(|s| get_number(s, &tuple_mapper))
            .enumerate()
            .map(|(i, num)| i32::pow(10, 3 - i as u32) * num as i32)
            .sum()
    }

    fn get_number(segs: &str, tuple_mapper: &Vec<(char, char)>) -> usize {
        let mut str_vec = segs
            .chars()
            .map(|c| tuple_mapper.iter().find(|(fc, _)| c == *fc).unwrap().1)
            .collect::<Vec<_>>();
        str_vec.sort();
        match String::from_iter(&str_vec).as_str() {
            "cf" => 1,
            "acdeg" => 2,
            "acdfg" => 3,
            "bcdf" => 4,
            "abdfg" => 5,
            "abdefg" => 6,
            "acf" => 7,
            "abcdefg" => 8,
            "abcdfg" => 9,
            "abcefg" => 0,
            _ => {
                println!("Error in matching arms inside number preconfig segments");
                1000000
            }
        }
    }
}

pub mod day_9 {
    use super::common_definitions::read_input;

    #[derive(Debug)]
    struct Point {
        value: usize,
        up: Option<usize>,
        down: Option<usize>,
        left: Option<usize>,
        right: Option<usize>,
    }

    impl Point {
        fn is_lower(&self) -> bool {
            let lowr = if let Some(n) = self.up {
                self.value < n
            } else {
                true
            } && if let Some(n) = self.down {
                self.value < n
            } else {
                true
            } && if let Some(n) = self.left {
                self.value < n
            } else {
                true
            } && if let Some(n) = self.right {
                self.value < n
            } else {
                true
            };
            lowr
        }
    }

    pub fn run() {
        let input = read_input("./../day9/input.txt")
            .iter()
            .map(|string| {
                string
                    .chars()
                    .filter_map(|chr| chr.to_string().parse::<usize>().ok())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        let num_rows = input.len();
        let num_cols = input[0].len();

        let points: Vec<Point> = input
            .iter()
            .enumerate()
            .map(|(y, row_vec)| {
                row_vec
                    .iter()
                    .enumerate()
                    .map(|(x, &chr)| Point {
                        value: chr,
                        up: if y + 1 == num_rows {
                            None
                        } else {
                            Some(input[y + 1][x])
                        },
                        down: if y == 0 { None } else { Some(input[y - 1][x]) },
                        left: if x == 0 { None } else { Some(input[y][x - 1]) },
                        right: if x + 1 == num_cols {
                            None
                        } else {
                            Some(input[y][x + 1])
                        },
                    })
                    .collect::<Vec<_>>()
            })
            .flatten()
            .collect();

        assert_eq!(points.len(), num_rows * num_cols);
        let lower_points = points
            .iter()
            .filter(|&p| p.is_lower())
            .map(|p| p.value + 1)
            .collect::<Vec<_>>();

        println!("lower points: {:?}", &lower_points);
        println!(
            "sum of risk levels of all low points: {}",
            lower_points.iter().sum::<usize>()
        );
    }
}

pub mod day_9_2 {
    use super::common_definitions::read_input;
    use std::{collections::HashSet, hash::Hash};

    #[derive(Hash, PartialEq, Eq, Clone, Debug)]
    struct Position(i32, i32);

    #[derive(Hash, PartialEq, Eq, Clone, Debug)]
    struct Point {
        value: i32,
        position: Position,
        members: Vec<Option<Position>>,
    }

    impl Point {
        // fn update_neighbours(&mut self, neighbours: &[Neighbours; 4]) {
        //     self.neighbours = Box::new(*neighbours);
        // }

        fn get_depth(&self, used_values: &mut HashSet<Position>, input: &Vec<Point>) -> i32 {
            if used_values.contains(&self.position) || self.value == 9 {
                return 0;
            }

            used_values.insert(self.position.clone());

            let to_use = self
                .members
                .iter()
                .filter(|pos_opt| {
                    if let Some(pos) = pos_opt {
                        !used_values.contains(pos)
                    } else {
                        false
                    }
                })
                .collect::<HashSet<_>>();

            to_use
                .iter()
                .map(|pos| {
                    input
                        .iter()
                        .find(|p| &&Some(p.position.clone()) == pos)
                        .unwrap()
                        .get_depth(used_values, input)
                })
                .sum::<i32>()
                + 1
        }
    }

    pub fn run() {
        let input = read_input("./../day9/input.txt")
            .iter()
            .map(|string| {
                string
                    .chars()
                    .filter_map(|chr| chr.to_string().parse::<usize>().ok())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        let x_max = input[0].len();
        let y_max = input.len();

        let mut points: Vec<Point> = input
            .iter()
            .enumerate()
            .map(|(y, row)| {
                row.iter()
                    .enumerate()
                    .map(|(x, &v)| Point {
                        value: v as i32,
                        position: Position(x as i32, y as i32),
                        members: {
                            [
                                if y + 1 < y_max {
                                    Some(Position(x as i32, y as i32 + 1))
                                } else {
                                    None
                                },
                                if y as i32 - 1 >= 0 {
                                    Some(Position(x as i32, y as i32 - 1))
                                } else {
                                    None
                                },
                                if x + 1 < x_max {
                                    Some(Position(x as i32 + 1, y as i32))
                                } else {
                                    None
                                },
                                if x as i32 - 1 >= 0 {
                                    Some(Position(x as i32 - 1, y as i32))
                                } else {
                                    None
                                },
                            ]
                            .to_vec()
                        },
                    })
                    .collect::<Vec<_>>()
            })
            .flatten()
            .collect::<Vec<_>>();

        println!("Ready to run!");

        let mut used_values: HashSet<Position> = HashSet::new();
        let mut basins: Vec<i32> = points
            .iter()
            .map(|p| {
                let size = p.get_depth(&mut used_values, &points);
                // println!("size of basin for {:?}: {}\n", &p.position, &size);
                size
            })
            .filter(|&n| n != 0)
            .collect();
        basins.sort();
        basins.reverse();
        let ans = basins.iter().take(3).product::<i32>();

        println!("basins ans: {}", ans);
    }

    #[derive(Hash, PartialEq, Eq, Clone, Debug)]
    struct Pix {
        position: Pos,
        neighbours: Vec<Pos>,
    }

    impl Pix {
        fn pix_neighbours(&self, pix_array: &HashSet<Pix>) -> HashSet<Pix> {
            self.neighbours
                .iter()
                .filter_map(|pos| pos.as_pix(pix_array))
                .collect()
        }
    }

    #[derive(Hash, PartialEq, Eq, Clone, Debug)]
    struct Pos {
        x: i32,
        y: i32,
        value: i32,
    }

    impl Pos {
        fn as_pix(&self, pix_array: &HashSet<Pix>) -> Option<Pix> {
            pix_array.iter().find(|p| &p.position == self).cloned()
        }
    }

    pub fn run2() {
        let input = read_input("./../day9/input.txt")
            .iter()
            .map(|string| {
                string
                    .chars()
                    .filter_map(|chr| chr.to_string().parse::<i32>().ok())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        let x_max = input[0].len();
        let y_max = input.len();

        let points = input
            .iter()
            .enumerate()
            .map(|(y, row)| {
                row.iter()
                    .enumerate()
                    .map(|(x, &v)| Pix {
                        position: Pos {
                            x: x as i32,
                            y: y as i32,
                            value: v,
                        },
                        neighbours: {
                            [
                                if y + 1 < y_max {
                                    Some(Pos {
                                        x: x as i32,
                                        y: y as i32 + 1,
                                        value: input[y + 1][x],
                                    })
                                } else {
                                    None
                                },
                                if y as i32 - 1 >= 0 {
                                    Some(Pos {
                                        x: x as i32,
                                        y: y as i32 - 1,
                                        value: input[y - 1][x],
                                    })
                                } else {
                                    None
                                },
                                if x + 1 < x_max {
                                    Some(Pos {
                                        x: x as i32 + 1,
                                        y: y as i32,
                                        value: input[y][x + 1],
                                    })
                                } else {
                                    None
                                },
                                if x as i32 - 1 >= 0 {
                                    Some(Pos {
                                        x: x as i32 - 1,
                                        y: y as i32,
                                        value: input[y][x - 1],
                                    })
                                } else {
                                    None
                                },
                            ]
                            .into_iter()
                            .filter_map(|p| p)
                            .collect::<Vec<_>>()
                        },
                    })
                    .collect::<Vec<_>>()
            })
            .flatten()
            .collect::<Vec<_>>();

        let mut used: HashSet<Pix> = HashSet::new();
        // let points_hash = HashSet::from_iter(points.clone().into_iter());
        // println!("points: {:?}", &points);

        let vals = points
            .iter()
            .map(|px| get_depth(px, &HashSet::from_iter(points.iter().cloned()), &mut used))
            .collect::<Vec<_>>();

        let ans: i32 = vals.into_iter().filter(|&n| n != 0).rev().take(3).product();

        // println!("ans: {}", ans);
    }

    fn get_depth(pix: &Pix, points: &HashSet<Pix>, used: &mut HashSet<Pix>) -> i32 {
        // println!("{:?}", &pix.position);

        if pix.position.value == 9 || used.contains(pix) {
            used.insert(pix.clone());
            return 0;
        }

        used.insert(pix.clone());

        let pix_neighbours = pix.pix_neighbours(points);
        let av_points = pix_neighbours
            .difference(&used)
            .map(|p| p.clone())
            .collect::<HashSet<_>>();

        let ans = av_points
            .iter()
            .map(|p| get_depth(p, points, used))
            .sum::<i32>()
            + 1;

        // println!(" count: {}", &ans);
        ans

        // pix.neighbours.iter().map(|pos| {
        //     let mut av_points = points.difference(&used).map(|p| p.position.clone()).collect::<HashSet<_>>();

        //     if !av_points.contains(pos) {
        //         0
        //     } else {
        //         let px = points.iter().find(|p| &p.position == pos).unwrap();
        //         get_depth(px, points, used, count + 1)
        //     }
        // }).sum::<i32>() + 1
    }
}

pub mod day10 {
    use std::{collections::HashMap, hash::Hash};

    use super::common_definitions::read_input;

    pub fn run() {
        let mut pairs_hash: HashMap<char, char> = HashMap::new();
        pairs_hash.insert('(', ')');
        pairs_hash.insert('[', ']');
        pairs_hash.insert('<', '>');
        pairs_hash.insert('{', '}');

        let mut value_hash: HashMap<char, i32> = HashMap::new();
        value_hash.insert(')', 3);
        value_hash.insert(']', 57);
        value_hash.insert('>', 25137);
        value_hash.insert('}', 1197);

        let mut completion_score_hash: HashMap<char, i32> = HashMap::new();
        completion_score_hash.insert(')', 1);
        completion_score_hash.insert(']', 2);
        completion_score_hash.insert('>', 4);
        completion_score_hash.insert('}', 3);

        let input = read_input("./../day10/input.txt");
        let output = input
            .iter()
            .map(|string| reduce_line(string, &pairs_hash, &value_hash))
            .sum::<i32>();
        println!("answer part 1: {}", output);

        let mut output = input
            .iter()
            .filter_map(|string| get_completion_string(&string, &pairs_hash))
            .map(|string| get_score_from_completion(string, &completion_score_hash))
            .collect::<Vec<_>>();

        output.sort();
        println!("output: {:?}", &output);

        let output = output.get(output.len() / 2).unwrap();

        println!("Part 2 answer: {}", output);
    }

    fn is_open_delimiter<T: Eq + Hash>(current: T, pairs_hash: &HashMap<T, T>) -> bool {
        pairs_hash.keys().any(|k| k == &current)
    }

    fn is_valid_close<T: Eq + Hash>(last_char: T, current: T, pairs_hash: &HashMap<T, T>) -> bool {
        if pairs_hash.get(&last_char) == Some(&current) {
            return true;
        } else {
            return false;
        }
    }

    fn is_corrupted<T: Eq + Hash>(last: T, current: T, pairs_hash: &HashMap<T, T>) -> bool {
        pairs_hash
            .values()
            .filter(|v| v == &&pairs_hash[&last])
            .any(|v| v == &current)
    }

    fn reduce_line(
        line: &String,
        pairs_hash: &HashMap<char, char>,
        value_hash: &HashMap<char, i32>,
    ) -> i32 {
        let mut counter = 0;
        let mut signs = "".to_string();
        let mut corrupted = false;
        for c in line.chars() {
            if signs.len() == 0 || is_open_delimiter(c, pairs_hash) {
                signs.push(c);
                counter += 1;
            } else if is_valid_close(signs.chars().last().unwrap(), c, pairs_hash) {
                signs.pop();
                counter -= 1;
            } else {
                counter = value_hash[&c];
                corrupted = true;
                break;
            }
        }

        if corrupted == false {
            0
        } else {
            counter
        }
    }

    fn get_completion_string(string: &String, pairs_hash: &HashMap<char, char>) -> Option<String> {
        let mut strs = String::new();
        let mut is_corrupted = false;
        for ch in string.chars() {
            if strs.len() == 0 || is_open_delimiter(ch, pairs_hash) {
                strs.push(ch);
            } else if is_valid_close(strs.chars().last().unwrap(), ch, pairs_hash) {
                strs.pop();
            } else {
                is_corrupted = true;
                break;
            }
        }

        if is_corrupted {
            None
        } else if strs.len() == 0 {
            Some(strs)
        } else {
            Some(
                strs.chars()
                    .map(|c| pairs_hash[&c])
                    .rev()
                    .collect::<String>(),
            )
        }
    }

    fn get_score_from_completion(
        completion_string: String,
        completion_score_hash: &HashMap<char, i32>,
    ) -> i128 {
        println!("completion String: {:?}", &completion_string);
        completion_string
            .chars()
            .map(|ch| -> i32 { completion_score_hash[&ch] })
            .fold(0, |acc, n| acc * 5 + n as i128)
    }
}

pub mod day11 {
    use std::{iter, ops::RangeBounds};

    use super::common_definitions::read_input;

    pub fn run() {
        let input = read_input("./../day11/input.txt");

        let mut matrix = input
            .iter()
            .map(|string| {
                string
                    .chars()
                    .filter_map(|c| c.to_string().parse::<u8>().ok())
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>();

        let mut flashes = 0;
        let x_max = matrix[0].len();
        let y_max = matrix.len();
        let mut count = 0;

        while !all_is_turn_on(&matrix) {
            let (new_flashes, new_matrix) = get_next_generation(flashes, matrix, x_max, y_max);
            matrix = new_matrix;
            flashes = new_flashes;
            // println!("Final Matrix at {}:", i+1);
            // print_matrix(&matrix);
            count += 1;
        }

        print_matrix(&matrix);
        println!("Total Amount of flashes: {}", flashes);
        println!("Total Amount of iterations: {}", count);
    }

    pub fn get_next_generation(
        flashes: u64,
        matrix: Vec<Vec<u8>>,
        x_max: usize,
        y_max: usize,
    ) -> (u64, Vec<Vec<u8>>) {
        let mut new_matrix = matrix
            .iter()
            .map(|row| row.iter().map(|n| n + 1).collect::<Vec<_>>())
            .collect::<Vec<_>>();
        let mut new_flashes = 0;
        let mut positions_flashed = vec![];

        while need_to_flash(&new_matrix, &positions_flashed) {
            // println!("Need to flash!");
            // print_matrix(&new_matrix);

            let mut mat_with_flashes = new_matrix.clone();

            new_matrix.iter().enumerate().for_each(|(y, row)| {
                row.iter().enumerate().for_each(|(x, n)| {
                    if *n >= 10 && !positions_flashed.contains(&(x, y)) {
                        update_neighbours(&mut mat_with_flashes, x, y, x_max, y_max);
                        positions_flashed.push((x, y));
                    }
                })
            });
            new_matrix = mat_with_flashes;
        }

        // println!("Finished Flashing");

        new_matrix.iter_mut().for_each(|row| {
            row.iter_mut().for_each(|mut n| {
                if *n >= 10 {
                    *n = 0;
                    new_flashes += 1;
                }
            })
        });

        (flashes + new_flashes, new_matrix)
    }

    fn need_to_flash(matrix: &Vec<Vec<u8>>, flashed_positions: &Vec<(usize, usize)>) -> bool {
        matrix.iter().enumerate().any(|(y, row)| {
            row.iter()
                .enumerate()
                .any(|(x, n)| *n >= 10 && !flashed_positions.contains(&(x, y)))
        })
    }

    fn update_neighbours(mat: &mut Vec<Vec<u8>>, x: usize, y: usize, x_max: usize, y_max: usize) {
        let upper_valid = y >= 1;
        let lower_valid = y < y_max - 1;
        let left_valid = x >= 1;
        let right_valid = x < x_max - 1;

        // println!("upper valid: {}, lower valid: {}, left valid: {}, right valid: {}", upper_valid, lower_valid, left_valid, right_valid);

        mat[y][x] += 1;

        if left_valid {
            mat[y][x - 1] += 1;
        }

        if right_valid {
            mat[y][x + 1] += 1;
        }

        if upper_valid {
            mat[y - 1][x] += 1;
        }

        if lower_valid {
            mat[y + 1][x] += 1;
        }

        if left_valid && upper_valid {
            mat[y - 1][x - 1] += 1;
        }

        if right_valid && upper_valid {
            mat[y - 1][x + 1] += 1;
        }

        if left_valid && lower_valid {
            mat[y + 1][x - 1] += 1;
        }

        if right_valid && lower_valid {
            mat[y + 1][x + 1] += 1;
        }
    }

    fn print_matrix(matrix: &Vec<Vec<u8>>) {
        for row in matrix {
            println!("{:?}", row);
        }

        println!();
    }

    fn all_is_turn_on(matrix: &Vec<Vec<u8>>) -> bool {
        matrix.iter().all(|row| row.iter().all(|n| *n == 0))
    }
}

pub mod day12 {
    use std::fmt::Display;

    use super::common_definitions::read_input;
    use super::common_definitions::ChallengeStep;

    #[derive(Debug, PartialEq)]
    enum Cave<'t> {
        Root,
        Big(&'t str),
        Small(&'t str),
        Goal,
    }

    impl <'t> From<&'t str> for Cave<'t> {
        fn from(string: &'t str) -> Self {
            match string {
                "start" => Cave::Root,
                "end" => Cave::Goal,
                s if s == s.to_lowercase() => Cave::Small(s),
                s => Cave::Big(s),
            }
        }
    }

    impl<'t> Display for Cave<'t> {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                Cave::Root => write!(f, "start"),
                Cave::Goal => write!(f, ",end"),
                Cave::Small(c) | Cave::Big(c) => write!(f, ",{}", &c),
            }
        }
    }
    
    impl<'t> Cave<'t> {
        fn is_inside(&self, step: &Step) -> bool {
            if (step.0 == self) | (step.1 == self) {true} else {false}
        }

        fn pair(&self, step: &'t Step) -> Option<&'t Self> {
            let (init, end) = step;
            if self == *init {
                Some(*end)
            } else if self == *end {
                Some(*init)
            } else {None}
        }
    }

    type Step<'t> = (&'t Cave<'t>, &'t Cave<'t>);

    type Steps<'t> = Vec<Step<'t>>;

    type Caves<'t> = Vec<&'t Cave<'t>>;

    pub fn run() {
        let challenge_step = ChallengeStep::Star2;
        let count = day_12_script("./../day12/input.txt", challenge_step);
        println!("Values count: {}", count);
    }

    fn day_12_script(input_path: &str, start: ChallengeStep) -> u32 {
        let input = read_input(input_path);

        let global_steps = input.iter()
        .map(|s| s.split_once('-').unwrap())
        .map(|(f, s)| (Cave::from(f), Cave::from(s)))
        .collect::<Vec<_>>();

        let steps: Steps = global_steps.iter().map(|(init, end)| (init, end)).collect();
        
        let count = count_paths(steps, start);
        count
    }

    /// Takes root points and put them on first, with their pairs
    fn filter_and_order_next<'t>(current_cave: &'t Cave, global_steps: &'t Steps) -> Steps<'t> {
        global_steps.iter()
            .filter_map(|st| {
                if let Some(dest) = current_cave.pair(st) {
                    if dest != &Cave::Root { Some((current_cave, dest)) } else { None }
                } else { None }
            })
            .collect()
    }

    /// Calculate the next steps iteration with steps arranged
    fn next_path_iteration(current_steps: &Steps, global_steps: &Steps, smalls_used_before: Caves, cave_to_repeat_allowed: Option<&Cave>, challenge_step: &ChallengeStep, path: &String) -> u32 {

        current_steps
            .iter()
            .map(|(_, next)| {

                if smalls_used_before.contains(next) {
                    return 0
                };
                
                if next == &&Cave::Goal {
                    println!("{}{}", path, next);
                    return 1
                };

                // println!(" {}", next);
                
                let used_and_current = if let Cave::Small(_) = next {[smalls_used_before.clone(), vec![next]].concat()} else {smalls_used_before.clone()};

                let new_cave_to_repeat = match cave_to_repeat_allowed {
                    Some(cv) if &cv == next => None, // if is the current, set repeat_cave to None
                    cv @ Some(_) => cv, // is is not the current, set repeat_cave to previous
                    None => if let Cave::Small(_) = next { // if dont have cave_to_repeat, use the current
                            Some(*next)
                        } else {None},
                };

                let next_steps: Steps = filter_and_order_next(next, global_steps); // next steps are all pairs of the 'end' cave
                // println!("\nnext -> {:?}", &next_steps);

                match (challenge_step, new_cave_to_repeat) {
                    (ChallengeStep::Star1, _) => {
                        next_path_iteration(
                            &next_steps,
                            global_steps,
                            used_and_current,
                            None, 
                            &ChallengeStep::Star1, 
                            &[path.clone(), format!("{}", next)].concat()
                            )
                    },
                    _ => {
                        next_path_iteration(
                            &next_steps,
                            global_steps,
                            smalls_used_before.clone(),
                            new_cave_to_repeat, 
                            &ChallengeStep::Star1, 
                            &[path.clone(), format!("{}", next)].concat()
                            )
                        +
                        next_path_iteration(
                            &next_steps,
                            global_steps,
                            used_and_current,
                            None, 
                            &ChallengeStep::Star2, 
                            &[path.clone(), format!("{}", next)].concat()
                            )
                    }
                    // (_, None) => { // Means that you pass the repeat value so switch to normal
                    //     next_path_iteration(
                    //         next_steps,
                    //         global_steps, 
                    //         &used_and_current, 
                    //         None, 
                    //         &ChallengeStep::Star1, 
                    //         &[path.clone(), format!("{}", next)].concat()
                    //         )
                    // },
                    // (_, Some(cv)) if &cv == next => { // means that you just assign a new value to the cave. so split process
                    //     next_path_iteration(
                    //         next_steps,
                    //         global_steps, 
                    //         smalls_used_before, 
                    //         None, 
                    //         &ChallengeStep::Star1, 
                    //         &[path.clone(), format!("{}", next)].concat()
                    //         )              
                    // },
                    // (_, Some(_)) => { // means that you have already chosen one cave but youre in other value. Continue trying to find the repetition
                    //     next_path_iteration(
                    //         next_steps,
                    //         global_steps,
                    //         &used_and_current, 
                    //         new_cave_to_repeat, 
                    //         &ChallengeStep::Star1, 
                    //         &[path.clone(), format!("{}", next)].concat()
                    //         )              
                    // },
                }

            }).sum::<u32>()
    }

    fn count_paths(global_steps: Vec<Step>, challenge_step: ChallengeStep) -> u32 {
        // println!("global steps: {:?}", &global_steps);
        let path = String::from("start");
        let start_steps: Steps = filter_and_order_next(&Cave::Root, &global_steps);
        let used_caves: Caves = vec![];
        next_path_iteration(&start_steps, &global_steps, used_caves, None, &challenge_step, &path)
        // return 10
    }


    #[cfg(test)]
    mod tests {
        // use crate::advent::common_definitions::ChallengeStep;
        use super::day_12_script;
        use super::ChallengeStep;

        #[test]
        fn test_day_12_examples_1() {
            assert_eq!(day_12_script("./../day12/example.txt", ChallengeStep::Star1), 10);
        }

        #[test]
        fn test_day_12_example_2() {
            assert_eq!(day_12_script("./../day12/example2.txt", ChallengeStep::Star1), 19);
        }

        #[test]
        fn test_day_12_example_3() {
            assert_eq!(day_12_script("./../day12/example3.txt", ChallengeStep::Star1), 226);
        }

        #[test]
        fn test_day_12_examples_star2_1() {
            assert_eq!(day_12_script("./../day12/example.txt", ChallengeStep::Star2), 36);
        }

        #[test]
        fn test_day_12_example_star2_2() {
            assert_eq!(day_12_script("./../day12/example2.txt", ChallengeStep::Star2), 103);
        }

        #[test]
        fn test_day_12_example_star2_3() {
            assert_eq!(day_12_script("./../day12/example3.txt", ChallengeStep::Star2), 3509);
        }
    }


}

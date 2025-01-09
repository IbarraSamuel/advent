import advent_utils
import gleam/int
import gleam/list
import gleam/string

type Game =
  #(Int, Int, Int)

const max_game: Game = #(12, 13, 14)

fn map_str_to_game(color: String, game: #(Int, Int, Int)) -> #(Int, Int, Int) {
  let #(r, g, b) = game
  let assert Ok(#(number, color)) = color |> string.split_once(" ")
  let assert Ok(val) = number |> int.parse
  let assert Ok(#(a, _)) = color |> string.reverse |> string.pop_grapheme
  case a {
    "d" -> #(r + val, g, b)
    "n" -> #(r, g + val, b)
    "e" -> #(r, g, b + val)
    _ -> #(0, 0, 0)
  }
}

fn sum_games(a: Game, b: Game) -> Game {
  let #(x, y, z) = a
  let #(a, b, c) = b
  #(x + a, y + b, z + c)
}

fn less_than_max(game: Game) -> Bool {
  let #(a, b, c) = game
  let #(x, y, z) = max_game
  a <= x && b <= y && c <= z
}

fn calc_max(game: Game, other: Game) -> Game {
  let #(a, b, c) = game
  let #(x, y, z) = other
  #(int.max(a, x), int.max(b, y), int.max(c, z))
}

fn create_game(card: String) -> Game {
  let assert Ok(game) =
    card
    |> string.split(", ")
    |> list.map(map_str_to_game(_, #(0, 0, 0)))
    |> list.reduce(sum_games)
  game
}

pub fn part1(lines: List(String)) {
  lines
  |> list.filter_map(string.split_once(_, ": "))
  |> list.index_fold(0, fn(acc, a, idx) {
    let #(_, b) = a
    let all_good =
      b
      |> string.split("; ")
      |> list.map(create_game)
      |> list.all(less_than_max)
    let to_accum = case all_good {
      True -> idx + 1
      False -> 0
    }
    acc + to_accum
  })
  |> int.to_string
}

pub fn part2(lines: List(String)) {
  lines
  |> list.filter_map(string.split_once(_, ": "))
  |> list.fold(0, fn(acc, a) {
    let #(_, b) = a
    let assert Ok(#(a, b, c)) =
      b |> string.split("; ") |> list.map(create_game) |> list.reduce(calc_max)
    let mul = a * b * c
    acc + mul
  })
  |> int.to_string
}

pub const solution = advent_utils.Solution(part1, part2)

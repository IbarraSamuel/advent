import advent_utils
import gleam/dict
import gleam/dynamic
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn part1(input: List(String)) -> String {
  let accum = fn(acc, line) {
    line
    |> string.to_graphemes
    |> list.filter_map(int.parse)
    |> fn(l) {
      let assert Ok(frst) = l |> list.first
      let assert Ok(lst) = l |> list.last
      acc + frst * 10 + lst
    }
  }
  input |> list.fold(0, accum) |> int.to_string
}

pub fn part2(input: List(String)) -> String {
  let mapper =
    dict.new()
    |> dict.insert("1", 1)
    |> dict.insert("2", 2)
    |> dict.insert("3", 3)
    |> dict.insert("4", 4)
    |> dict.insert("5", 5)
    |> dict.insert("6", 6)
    |> dict.insert("7", 7)
    |> dict.insert("8", 8)
    |> dict.insert("9", 9)
    |> dict.insert("one", 1)
    |> dict.insert("two", 2)
    |> dict.insert("three", 3)
    |> dict.insert("four", 4)
    |> dict.insert("five", 5)
    |> dict.insert("six", 6)
    |> dict.insert("seven", 7)
    |> dict.insert("eight", 8)
    |> dict.insert("nine", 9)

  let accum = fn(acc, line) {
    line
    |> string.to_graphemes
    |> list.filter_map(int.parse)
    |> fn(l) {
      let assert Ok(frst) = l |> list.first
      let assert Ok(lst) = l |> list.last
      acc + frst * 10 + lst
    }
  }
  input |> list.fold(0, accum) |> int.to_string
}

pub const solution = advent_utils.Solution(part1, part2)

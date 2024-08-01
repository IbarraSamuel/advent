import advent_utils
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
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

fn str_index(str: String, other: String) -> Int {
  let before_other = str |> string.crop(other)
  let main_len = str |> string.length
  main_len - { before_other |> string.length }
}

fn str_rindex(str: String, other: String) -> Int {
  let rev_str = str |> string.reverse
  let rev_other = other |> string.reverse
  let before_other = rev_str |> string.crop(rev_other)
  before_other |> string.length
}

fn first_key(line: String, mapper: Dict(String, Int)) -> String {
  let assert Ok(#(str, _)) =
    mapper
    |> dict.keys
    |> list.filter(fn(v) { line |> string.contains(v) })
    |> list.map(fn(k) { #(k, line |> str_index(k)) })
    |> list.sort(fn(a, b) {
      let #(_, a) = a
      let #(_, b) = b
      a |> int.compare(b)
    })
    |> list.first
  str
}

fn last_key(line: String, mapper: Dict(String, Int)) -> String {
  let assert Ok(#(str, _)) =
    mapper
    |> dict.keys
    |> list.filter(fn(v) { line |> string.contains(v) })
    |> list.map(fn(k) { #(k, line |> str_rindex(k)) })
    |> list.sort(fn(a, b) {
      let #(_, a) = a
      let #(_, b) = b
      a |> int.compare(b)
    })
    |> list.last
  str
}

fn line_value(line: String, mapper: Dict(String, Int)) -> Int {
  let firstk = line |> first_key(mapper)
  let lastk = line |> last_key(mapper)
  let assert Ok(f) = mapper |> dict.get(firstk)
  let assert Ok(l) = mapper |> dict.get(lastk)
  f * 10 + l
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

  let accum = fn(acc: Int, line) -> Int {
    line
    |> line_value(mapper)
    |> int.add(acc)
  }
  input |> list.fold(0, accum) |> int.to_string
}

pub const solution = advent_utils.Solution(part1, part2)

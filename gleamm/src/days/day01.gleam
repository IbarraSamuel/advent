import advent_utils
import gleam/bool
import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/order
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
      acc + frst * 10 + lst |> io.debug
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

  let line_value = fn(line: String, mapper: Dict(String, Int)) -> Int {
    let assert #(option.Some(fk), _, option.Some(lk), _) =
      mapper
      |> dict.fold(#(option.None, -1, option.None, -1), fn(acc, k, _) {
        let #(first_k, first, last_k, last) = acc
        let min =
          line
          |> string.to_graphemes
          |> list.index_fold(first, fn(acc, it, idx) {
            case it == k {
              True -> idx
              False -> acc
            }
          })
        let max =
          line
          |> string.to_graphemes
          |> list.reverse
          |> list.index_fold(first, fn(acc, it, idx) {
            case it == k {
              True -> idx
              False -> acc
            }
          })
          |> int.negate
          |> int.add(line |> string.length |> int.subtract(1))
        let #(first_k, first) = case
          { min != -1 }
          |> bool.and(min < first)
          |> bool.or(first == -1)
        {
          True -> #(option.Some(k), min)
          False -> #(first_k, min)
        }
        let #(last_k, last) = case
          { max != -1 }
          |> bool.and(max > last)
          |> bool.or(last == -1)
        {
          True -> #(option.Some(k), max)
          False -> #(last_k, max)
        }

        #(first_k, first, last_k, last)
      })

    let assert Ok(f) = mapper |> dict.get(fk)
    let assert Ok(l) = mapper |> dict.get(lk)
    f * 10 + l
  }

  let accum = fn(acc: Int, line) -> Int {
    line
    |> line_value(mapper)
    |> int.add(acc)
  }
  input |> list.fold(0, accum) |> int.to_string
}

pub const solution = advent_utils.Solution(part1, part2)

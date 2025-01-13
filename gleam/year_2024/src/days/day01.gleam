import advent_utils
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

fn part1(data) {
  let lines =
    data |> string.split("\n") |> list.filter_map(string.split_once(_, " "))
  let l1 =
    lines
    |> list.filter_map(fn(tp) { tp |> pair.first |> int.parse })
    |> list.sort(int.compare)

  lines
  |> list.map(pair.second)
  |> list.map(string.trim_start)
  |> list.filter_map(int.parse)
  |> list.sort(int.compare)
  |> list.map2(l1, int.subtract)
  |> list.map(int.absolute_value)
  |> int.sum
}

fn part2(data) {
  let lines =
    data |> string.split("\n") |> list.filter_map(string.split_once(_, " "))

  lines
  |> list.map(pair.first)
  |> list.map(fn(a) {
    lines
    |> list.map(pair.second)
    |> list.map(string.trim_start)
    |> list.count(where: fn(s) { s == a })
    |> int.multiply(a |> int.parse |> result.unwrap(0))
  })
  |> int.sum
}

pub const solution = advent_utils.Solution(part1, part2)

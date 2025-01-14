import advent_utils
import gleam/int
import gleam/list
import gleam/string

/// this is the doc.
/// ```gleam
/// part_1(data)
/// ```
/// Note: Filter rows with zero values.
fn part_1(data) {
  data
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.map(list.map(_, string.trim_start))
  |> list.map(list.filter_map(_, int.parse))
  |> list.map(list.window_by_2)
  |> list.map(list.map(_, fn(a) { a.0 - a.1 }))
  |> list.filter(fn(l) {
    { l |> list.length > 0 }
    && list.all(l, fn(a) { int.absolute_value(a) <= 3 })
    && { list.all(l, fn(i) { i < 0 }) || list.all(l, fn(i) { i > 0 }) }
  })
  |> list.length
}

fn part_2(data) {
  let nums =
    data
    |> string.split("\n")
    |> list.map(string.split(_, " "))
    |> list.map(list.map(_, string.trim_start))
    |> list.map(list.filter_map(_, int.parse))

  let diffs =
    nums
    |> list.map(list.window_by_2)
    |> list.map(list.map(_, fn(a) { a.0 - a.1 }))

  let invalid =
    diffs
    |> list.map2(nums, fn(difs, nms) { #(difs, nms) })
    |> list.filter_map(fn(l) {
      case
        {
          { l.0 |> list.length > 0 }
          && list.all(l.0, fn(a) { int.absolute_value(a) <= 3 })
          && {
            list.all(l.0, fn(i) { i < 0 }) || list.all(l.0, fn(i) { i > 0 })
          }
        }
      {
        True -> Ok(l.1)
        False -> Error(Nil)
      }
    })
  -1
  // TODO
}

pub const solution = advent_utils.Solution(part_1, part_2)

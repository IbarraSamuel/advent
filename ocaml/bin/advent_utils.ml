let read_file path =
  let chan = open_in path in
  let rec append_lines acc =
    try
      let line = input_line chan in
        append_lines (line :: acc)
    with End_of_file ->
      close_in chan;
      List.rev acc
    in
    append_lines []

type adventSolution = {
  part_1: string list -> int;
  part_2: string list -> int;
}

let run path solution =
  let lines = read_file path in
    lines |> solution.part_1 |> string_of_int |> String.cat "\tPart 1 => " |> print_string;
    lines |> solution.part_2 |> string_of_int |> String.cat "\tPart 2 => " |> print_string


from __future__ import annotations

import pathlib
from dataclasses import dataclass

# from enum import Enum
from functools import reduce


@dataclass(slots=True)
class Folder:
    content: list[Folder | File]
    name: str
    parent: Folder | None


@dataclass(frozen=True, slots=True)
class File:
    name: str
    size: int


@dataclass(frozen=True, slots=True)
class MoveIn:
    into: Folder


@dataclass(frozen=True, slots=True)
class MoveOut:
    to: Folder


@dataclass(frozen=True, slots=True)
class Display:
    content: Folder


Prompt = MoveIn | MoveOut | Display | Folder | File


def map_input(prompt: str, cwd: Folder | None, parent: Folder | None) -> Prompt:
    val: Prompt
    match tuple(prompt.split(" ")):
        case ("$", "cd", ".."):
            # if cwd and cwd.parent:
            #     cwd.parent.content += [cwd] if cwd else []
            val = (
                MoveOut(to=parent)
                if parent
                else Folder(
                    content=[],
                    name="Bad Folder",
                    parent=None,
                )
            )
        case ("$", "cd", dir):
            folder = Folder(name=dir, content=[], parent=cwd)
            val = MoveIn(into=folder)
            if cwd:
                cwd.content += [folder]
        case ("$", "ls"):
            val = (
                Display(content=cwd)
                if cwd
                else Folder(content=[], name="Bad Folder", parent=None)
            )
        case ("dir", name):
            val = Folder(content=[], name=name, parent=parent)
            if cwd:
                cwd.content += [val]
        case (number, name) if number.isdigit():
            val = File(name=name, size=int(number))
            if cwd:
                cwd.content += [val]
        case _:
            msg = f"No pattern covered {tuple(prompt.split(" "))}"
            raise ValueError(msg)
    return val


def next_iteration(
    acc: tuple[list[Prompt], Folder | None, Folder | None], n: str
) -> tuple[list[Prompt], Folder | None, Folder | None]:
    lst, cwd, p = acc
    out = map_input(n, cwd, p)
    new_list = [*lst, out]

    # PREV ITER
    new_cwd = (
        out.into if isinstance(out, MoveIn) else p if isinstance(out, MoveOut) else cwd
    )
    new_p = (
        cwd
        if isinstance(out, MoveIn)
        else (p.parent if p else None)
        if isinstance(out, MoveOut)
        else p
    )

    # NEXT ITER

    return new_list, new_cwd, new_p


def calculate_size(prompt: Prompt) -> int:
    return (
        prompt.size
        if isinstance(prompt, File)
        else sum(calculate_size(p) for p in prompt.content)
        if isinstance(prompt, Folder)
        else 0
    )


def calculate_result(input: list[str]) -> None:
    initial: tuple[list[Prompt], Folder | None, Folder | None] = ([], None, None)
    mapped = reduce(
        next_iteration,
        input,
        initial,
    )
    sizes = [calculate_size(f) for f in mapped[0] if isinstance(f, Folder)]
    [s for s in sizes if s <= 100000]


def main() -> None:
    with pathlib.Path("../rust/inputs/day7.txt").open(encoding="utf-8") as f:
        prod = f.readlines()

#     test = """$ cd /
# $ ls
# dir a
# 14848514 b.txt
# 8504156 c.dat
# dir d
# $ cd a
# $ ls
# dir e
# 29116 f
# 2557 g
# 62596 h.lst
# $ cd e
# $ ls
# 584 i
# $ cd ..
# $ cd ..
# $ cd d
# $ ls
# 4060174 j
# 8033020 d.log
# 5626152 d.ext
# 7214296 k"""
    calculate_result(prod)


if __name__ == "__main__":
    main()

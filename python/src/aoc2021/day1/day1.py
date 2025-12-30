import pathlib


def count_increases(measurements: list[int]) -> tuple[int, int]:
    acc = (-1, 0)
    for n in measurements:
        f = acc[0] + 1 if n > acc[1] else acc[0]
        acc = f, n

    return acc


def count_with_noise(measurements: list[int]) -> tuple[int, int]:
    groups = [[i + j for j in range(3)] for i in range(len(measurements) - 2)]
    values = [sum(measurements[i] for i in g) for g in groups]
    return count_increases(values)


def main() -> None:
    file = pathlib.Path(__file__).parent / "example.txt"
    with pathlib.Path(file).open(encoding="utf-8") as f:
        input_values = f.readlines()
        [int(m.strip()) for m in input_values if m.strip().isnumeric()]


if __name__ == "__main__":
    main()

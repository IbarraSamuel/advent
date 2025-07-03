from functools import reduce
import pathlib

def count_increases(measurements: list[int]):
    count, _ = reduce(lambda acc, n: (acc[0]+1 if n > acc[1] else acc[0], n), measurements, (-1,0))
    return count

def count_with_noise(measurements: list[int]):
    groups = [[i+j for j in range(3)] for i in range(measurements.__len__()-2)]
    values = [sum([measurements[i] for i in g]) for g in groups]
    ans = count_increases(values)
    return ans

def main():
    file = pathlib.Path(__file__).parent / "example.txt"
    with open(file, "rt") as f:
        input_values = f.readlines()
        measurements = [int(m.strip()) for m in input_values if m.strip().isnumeric()]
    print(count_with_noise(measurements))

if __name__ == "__main__":
    main()
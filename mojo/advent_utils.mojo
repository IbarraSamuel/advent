from collections.optional import Optional


fn read_input[path: StringLiteral]() -> Optional[List[String]]:
    try:
        with open(path, "r") as f:
            return Optional(f.read().split(delimiter="\n"))
    except:
        return None


trait AdventResultType(Stringable, Copyable):
    ...


trait AdventSolution:
    @staticmethod
    fn day_1[T: AdventResultType](input: List[String]) -> T:
        ...

    @staticmethod
    fn day_2[T: AdventResultType](input: List[String]) -> T:
        ...


fn run[S: AdventSolution, path: StringLiteral, T: AdventResultType = Int]():
    var input = read_input[path=path]()
    if not input:
        print("No file found with path:", path)

    var result_1 = S.day_1[T](input.value())
    print("\tPart 1:", result_1)
    var result_2 = S.day_2[T](input.value())
    print("\tPart 2:", result_2)
    return

fn read_input(path: StringLiteral) raises -> ListLiteral[String]:
    with open(path, "r") as f:
        return f.read()
        

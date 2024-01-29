from builtin.string import atol

fn read_input(path: StringLiteral) raises -> DynamicVector[String]:
    var file: String
    with open(path, "r") as f:
        return f.read().split(delimiter="\n")
    
        

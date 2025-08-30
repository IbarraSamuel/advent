import sys

def read_input() -> list[str]:
    lst = sys.argv
    return lst

    sep_lst = [v.split() for v in lst]

    name = "   samuel ibarra  "
    print("'"+ name.strip()+ "'")

read_input()
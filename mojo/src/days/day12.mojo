from advent_utils import AdventSolution
from algorithm import parallelize


fn sig_and_pattern(
    line: String,
) -> (String, String):
    space_idx = line.find(" ")
    signature = line[:space_idx].strip(".")
    r_groups = line[space_idx + 1 :]

    pat = String()
    g_idx = 0

    while g_idx < len(r_groups):
        if r_groups[g_idx] == ",":
            pat.write(".")
            g_idx += 1
            continue

        n_idx = r_groups.find(",", g_idx)
        if n_idx == -1:
            n_idx = r_groups.byte_length()

        try:
            n = int(r_groups[g_idx:n_idx])
        except:
            pass

        g_idx = n_idx
        pat.write(String("#") * n)
    return signature, pat


fn calc_path_val(sig: String, pat: String) -> Int:
    print(sig, pat, end="\t")

    if sig == pat:
        print("Exactly the same")
        return 1

    if len(pat) > len(sig):
        print("not enought options on signature to match the pattern required.")
        return 0

    i = 0
    a = 0

    while sig[i] == pat[i]:
        i += 1
        a += 1

        if i == len(sig):
            print("Signature finished ok!")
            return 1

        if a == len(pat):
            print("Pattern finished.", "good?", "#" not in sig[i:])
            return 0 if "#" in sig[i:] else 1

    print("(a:", a, ", i:", i, ")", sep="", end="")

    # while i > 0 and sig[i] == "." and sig[i - 1] == ".":
    #     # while i > 0 and sig[i] == ".":  # and sig[i - 1] == ".":
    # i += 1

    if sig[i] != "?":
        print(
            (
                "Not valid since the signature specifies something different"
                " than what is next on the pattern. sig:"
            ),
            sig[i],
            "pat:",
            pat[a],
        )
        return 0

    if pat[a] == ".":
        a += 1

    print()

    return calc_path_val(sig[i + 1 :].lstrip("."), pat[a:]) + calc_path_val(
        "#" + sig[i + 1 :].lstrip("."), pat[a:]
    )


fn calc_line(line: String) -> Int32:
    print()
    print(line)
    sig, pat = sig_and_pattern(line)
    res = calc_path_val(sig, pat)
    print(res)
    return res


fn calc_line_2(line: String) -> Int32:
    sig, pat = sig_and_pattern(line)
    sig = "?".join(List(sig, sig, sig, sig, sig))
    return calc_path_val(sig, pat)


struct Solution(AdventSolution):
    alias dtype = DType.int32

    @staticmethod
    fn part_1(lines: List[String]) -> Scalar[Self.dtype]:
        r = SIMD[DType.int32, 1024](0)

        # @parameter
        # fn calc(idx: Int):
        for idx in range(lines.size):
            r[idx] = calc_line(lines.unsafe_get(idx))

        # parallelize[calc](lines.size)
        return r.reduce_add()

    @staticmethod
    fn part_2(lines: List[String]) -> Scalar[Self.dtype]:
        r = SIMD[DType.int32, 1024](0)

        # @parameter
        # fn calc(idx: Int):
        for idx in range(lines.size):
            r[idx] = calc_line_2(lines.unsafe_get(idx))

        # parallelize[calc](lines.size)
        return r.reduce_add()

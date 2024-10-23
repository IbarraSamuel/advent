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
    print(sig, pat, end=" -- ")

    if len(pat) > len(sig):
        print("not enought options on signature to match the pattern required.")
        return 0

    if sig == pat:
        print("Exactly the same")
        return 1

    # Iterate over the equals. When there is a divergence, stop.
    # Consider those lines on signature where you find multiple dots.
    i = 0
    a = 0

    while sig[i] == ".":
        i += 1

        if i == len(sig):
            print("Bad because there is still pattern missing")
            return 0

    while sig[i] == pat[a]:
        i += 1
        a += 1

        if i == len(sig):
            print("Signature finished ok!")
            return 1

        if a == len(pat):
            print("Pattern finished.", "good?", "#" not in sig[i:])
            return 0 if "#" in sig[i:] else 1
        while sig[i : i + 1] == ".." and i < len(sig) - 1:
            i += 1

    print("(i:", i, "), (a:", a, ")")

    if sig[i] == "#":
        # print(
        #     (
        #         " !! Not valid since the signature specifies something"
        #         " different than what is next on the pattern. sig:"
        #     ),
        #     sig[i],
        #     "pat:",
        #     pat[a],
        # )
        return 0

    print(
        String(" ") * i + "^" + String(" ") * (len(sig) - i - 1),
        String(" ") * a + "^" + String(" ") * (len(pat) - a - 1),
    )

    dot_path = calc_path_val("." + sig[i + 1 :], pat[a:])
    hash_path = calc_path_val("#" + sig[i + 1 :], pat[a:])
    return dot_path + hash_path


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
    pat = ",".join(List(pat, pat, pat, pat, pat))
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

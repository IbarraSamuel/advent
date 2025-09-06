from advent_utils import ListSolution


struct Solution(ListSolution):
    alias dtype = DType.uint32

    @staticmethod
    fn part_1[o: Origin](lines: List[StringSlice[o]]) -> UInt32:
        # get `seeds: a b c d e`
        var seeds_str = lines[0]
        var seeds_list = seeds_str[seeds_str.find(": ") + 2 :].split()

        var seeds_nums = atol_uint(seeds_list)

        var maps = List[MapRange]()
        for line in lines[2:]:
            if line == "":
                continue

            # These lines are not useful
            if "map" in line:
                map_numbers(maps, seeds_nums)
                maps.clear()
                continue

            var map_range: MapRange = atol_uint(line.split())
            maps.append(map_range^)

        map_numbers(maps, seeds_nums)

        var m: Int = Int.MAX
        for n in seeds_nums:
            m = min(m, n)

        return m

    @staticmethod
    fn part_2[o: Origin](lines: List[StringSlice[o]]) -> UInt32:
        # get `seeds: a b c d e`
        var seeds_str = lines[0]
        var seeds_list = seeds_str[seeds_str.find(": ") + 2 :].split()

        var seeds_nums = calc_num_ranges(atol_uint(seeds_list))

        var maps = List[MapRange]()
        for line in lines[2:]:
            if line == "":
                continue

            # These lines are not useful
            if "map" in line:
                seeds_nums = map_ranges(maps, seeds_nums)
                maps.clear()
                continue

            var map_range: MapRange = atol_uint(line.split())
            maps.append(map_range^)

        seeds_nums = map_ranges(maps, seeds_nums)

        var m: Int = Int.MAX
        for n in seeds_nums:
            m = min(m, n.start)

        return m


alias MapRangeTp = Tuple[Int, Int, Int]


struct MapRange(Copyable, Movable):
    var src_start: Int
    var dest_start: Int
    var length: Int

    fn __init__(out self, range: MapRangeTp):
        self.dest_start, self.src_start, self.length = range

    @implicit
    fn __init__(out self, var range: List[Int]):
        self.dest_start, self.src_start, self.length = (
            range[0],
            range[1],
            range[2],
        )


@fieldwise_init
struct NumRange(Copyable, Movable):
    var start: Int
    var end: Int


fn calc_num_ranges(ranges: List[Int]) -> List[NumRange]:
    var numranges = List[NumRange]()
    for i in range(0, len(ranges), 2):
        numranges.append(NumRange(ranges[i], ranges[i] + ranges[i + 1]))
    return numranges


fn map_number(range: MapRange, n: Int) -> Tuple[Int, Bool]:
    if range.src_start <= n < range.src_start + range.length:
        return range.dest_start + (n - range.src_start), True
    else:
        return n, False


fn map_numbers(ranges: List[MapRange], mut numbers: List[Int]):
    for ref num in numbers:
        for map in ranges:
            num, mapped = map_number(map, num)

            if mapped:
                break


fn calc_ranges(
    map: MapRange, var num: NumRange
) -> Tuple[List[NumRange], List[Bool]]:
    """Returns the list of new ranges, and a mask to tell if those were mapped or not.
    """
    var a = map.src_start
    var b = map.src_start + map.length
    var x = num.start
    var y = num.end

    if y < a or b < x:
        # No overlaps. Just give back what you have.
        return List(num^), List(False)

    var delta = map.dest_start - map.src_start

    if x < a and b < y:
        # The mapper range is all inside the num range. You need now 3 ranges.
        return List(
            NumRange(x, a), NumRange(a + delta, b + delta), NumRange(b, y)
        ), List(False, True, False)

    if a <= x < b:
        # The lower part of the range is part of map range.
        if y < b:
            # The num range is fully inside the map range. We need 3 ranges.
            return List(NumRange(x + delta, y + delta)), List(True)
        else:
            # The num range is partially part of map range (The beginign part). We Need 3 ranges.
            return List(
                NumRange(x + delta, b + delta),
                NumRange(b, y),
            ), List(True, False)
    else:
        # The only option is that we have the end between map start and end. We need to create 3 ranges.
        return List(
            NumRange(x, a),
            NumRange(a + delta, y + delta),
        ), List(False, True)


fn map_ranges(
    ranges: List[MapRange], var numbers: List[NumRange]
) -> List[NumRange]:
    """We should produce a new list of ranges out of the ranges we receive.
    For each range, first we will produce a new set of ranges.
    if the range is not mapped, needs to be there still for the next mappers.
    New ranges should be passed also on new mappers.

    Once you finish with all mappers, if there is still something not mapped, move it with the mapped ranges.
    return the final list once you iterate trough all the ranges provided.

    """
    var used_ranges = List[Pointer[NumRange, ImmutableAnyOrigin]]()

    while len(numbers) > 0:
        var num = numbers.pop(0)

        for map in ranges:
            new_numbers, mask = calc_ranges(map, num^)

            if len(mask) == 3:  # 3 Produced
                ref num = new_numbers[0]
                used_ranges.append(
                    Pointer[origin=ImmutableAnyOrigin](to=new_numbers[1])
                )
                numbers.insert(0, new_numbers[2])
                continue
            # This one is not going to help if we append it again.
            if len(mask) == 1 and mask[0] == True:
                used_ranges.append(new_numbers[0])
                break  # Hey, all is mapped, go to next range please.
            if len(mask) == 1 and mask[0] == False:
                continue  # keep using num it for next maps (similar to assingn value to num.)

            for i in range(len(new_numbers)):
                # if the range is already mapped, add to used and continue with the other one.
                if mask[i]:
                    used_ranges.append(new_numbers[i])  # Add to used

                else:
                    # replace the current range `num` with the not mapped range.
                    num = new_numbers[i]
        # we finalize mapping num and we are still here. Let's continue with other maps. This will not move
        else:
            used_ranges.append(num)
    return used_ranges


fn atol_uint(c: StringSlice) -> Int:
    try:
        return atol(c)
    except:
        print("Invalid conversion for", c)
        return 0


fn atol_uint[o: Origin](var l: List[StringSlice[o]]) -> List[Int]:
    var uint_l = List[Int](capacity=len(l))
    for i in range(len(l)):
        uint_l.append(atol_uint(l[i]))

    return uint_l

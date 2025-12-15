from builtin.variadics import Variadic
from compile.reflection import get_type_name
from builtin.rebind import trait_downcast
from testing.suite import (
    __call_location,
    _SourceLocation,
    TestReport,
    TestResult,
    TestSuiteReport,
)
from time import perf_counter_ns


@fieldwise_init
@explicit_destroy("run() or abandon() the TestSuite")
struct TestSuite[*ts: Movable](Movable):
    var tests: Tuple[*Self.ts]
    var location: _SourceLocation

    fn __init__(
        out self: TestSuite[], location: Optional[_SourceLocation] = None
    ):
        self.tests = {}
        self.location = location.or_else(__call_location())

    fn test(
        deinit self, var other: Tuple
    ) -> TestSuite[*Variadic.concat[Self.ts, other.element_types]]:
        return {self.tests.concat(other^), self.location}

    fn abandon(deinit self):
        pass

    fn run(deinit self) raises:
        comptime size = Variadic.size(Self.ts)
        var reports = List[TestReport](capacity=size)

        @parameter
        for i in range(size):
            comptime full_nm = get_type_name[Self.ts[i]]()
            var name = full_nm[full_nm.find("().") + 3 : full_nm.find(", {}")]
            var error: Optional[Error] = None
            ref test = self.tests[i]
            ref test_fn = trait_downcast[fn () raises unified](test)
            var start = perf_counter_ns()
            try:
                test_fn()
            except e:
                error = {e^}
            var duration = perf_counter_ns() - start
            var result = TestResult.PASS if not error else TestResult.FAIL
            var report = TestReport(
                name=name,
                duration_ns=duration,
                result=result,
                error=error.or_else({}),
            )
            reports.append(report^)

        var report = TestSuiteReport(reports=reports^, location=self.location)

        if report.failures > 0:
            raise Error(report)

        print(report)


fn main() raises:
    var ts = TestSuite()

    fn fa() raises unified {}:
        raise "Something went wrong"

    var ts1 = ts^.test((fa,))

    fn fb() raises unified {}:
        print("fb")

    var ts2 = ts1^.test((fb,))

    fn fc() raises unified {}:
        print("fc")

    var ts3 = ts2^.test((fc,))

    ts3^.run()

    # @parameter
    # for i in range(Variadic.size(all_tuples.ts)):
    #     ref f = all_tuples.inner[i]
    #     ref ff = trait_downcast[fn () raises unified](f)
    #     try:
    #         ff()
    #     except:
    #         print("failed")

    # all_tuples^.abandon()

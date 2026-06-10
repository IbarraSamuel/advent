from std.reflection import (
    get_function_name,
    call_location,
    SourceLocation,
)
from std.builtin.rebind import trait_downcast, downcast
from std.testing.suite import (
    TestReport,
    TestResult,
    TestSuiteReport,
)
from std.time import perf_counter_ns


@fieldwise_init
@explicit_destroy("run() or abandon() the TestSuite")
struct UnifiedTestSuite[*ts: Movable](Movable):
    var tests: Tuple[*Self.ts]
    var location: SourceLocation

    @always_inline
    def __init__(
        out self: UnifiedTestSuite[], location: Optional[SourceLocation] = None
    ):
        self.tests = {}
        self.location = location.or_else(call_location())

    def test[
        func: def() raises
    ](deinit self, var f: func) -> UnifiedTestSuite[
        *TypeList._concat[
            Self.ts.values, TypeList.of[Trait=Movable, func].values
        ]()
    ]:
        return {self.tests^.concat((f^,)), self.location}

    @always_inline("nodebug")
    def abandon(deinit self):
        pass

    def run(deinit self) raises:
        comptime size = Self.ts.size
        var reports = List[TestReport](capacity=size)

        comptime for i in range(size):
            comptime full_nm = reflect[Self.ts[i]].name()
            var name = full_nm[
                byte = full_nm.find("().") + 3 : full_nm.find(", {}")
            ]
            var error: Optional[Error] = None
            ref test = self.tests[i]
            ref test_fn = trait_downcast[def() raises](test)
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
                error=error^.or_else({}),
            )
            reports.append(report^)

        var report = TestSuiteReport(reports=reports^, location=self.location)

        if report.failures > 0:
            raise Error(report^)

        print(report)


@fieldwise_init
@explicit_destroy("run() or abandon() the TestSuite")
struct TestSuite(Movable):
    var tests: List[Tuple[StaticString, def() raises thin]]
    var location: SourceLocation

    @always_inline
    def __init__(
        out self: TestSuite[], location: Optional[SourceLocation] = None
    ):
        self.tests = {}
        self.location = location.or_else(call_location())

    def test[
        func: def() raises thin
    ](mut self, name: Optional[StaticString] = None):
        self.tests.append((name.or_else(get_function_name[func]()), func))

    def abandon(deinit self):
        pass

    def run(deinit self) raises:
        var size = len(self.tests)
        var reports = List[TestReport](capacity=size)

        for name, test in self.tests:
            var error: Optional[Error] = None
            var start = perf_counter_ns()
            try:
                test()
            except e:
                error = {e^}
            var duration = perf_counter_ns() - start
            var result = TestResult.PASS if not error else TestResult.FAIL
            var report = TestReport(
                name=name,
                duration_ns=duration,
                result=result,
                error=error^.or_else({}),
            )
            reports.append(report^)

        var report = TestSuiteReport(reports=reports^, location=self.location)

        if report.failures > 0:
            raise Error(report^)

        print(report)

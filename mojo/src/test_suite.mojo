from std.reflection import (
    get_function_name,
    call_location,
    SourceLocation,
)

from std.testing.suite import TestReport, TestResult, TestSuiteReport
from std.time import perf_counter_ns


@fieldwise_init
struct UnifiedTestSuite(Deinitable where False, Movable):
    var tests: List[Tuple[def() thin raises, StaticString]]
    var location: SourceLocation

    @always_inline
    def __init__(out self, location: Optional[SourceLocation] = None):
        self.tests = []
        self.location = location.or_else(call_location())

    def add_test(mut self, func: def() thin raises, name: StaticString):
        self.tests.append((func, name))

    @always_inline("nodebug")
    def abandon(deinit self):
        pass

    def run(deinit self) raises:
        var reports = List[TestReport](capacity=len(self.tests))

        for test, name in self.tests:
            # comptime assert conforms_to(test, def() raises)
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


@fieldwise_init
struct TestSuite(Deinitable where False, Movable):
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

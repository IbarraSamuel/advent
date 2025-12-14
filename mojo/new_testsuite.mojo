from utils import Variant
from testing.suite import (
    _SourceLocation,
    Set,
    argv,
    __call_location,
    get_function_name,
    _type_is_eq,
    TestSuiteReport,
    TestReport,
    perf_counter_ns,
)
from builtin import Variadic


fn main() raises:
    fn unified_test() unified {read}:
        print("unified")

    fn unified_second_test() unified {read}:
        print("unified")

    var cli_args = List[StaticString]()
    TestSuite(cli_args=cli_args^)
        .test(unified_test^, "normal_test")
        .test(unified_second_test^, "unified_second_test")
        .run()


@explicit_destroy("TestSuite must be destroyed via `run()`")
struct TestSuite[*fn_types: fn () raises unified](Movable):
    """A suite of tests to run.

    You can automatically collect and register test functions starting with
    `test_` by calling the `discover_tests` static method, and then running the
    entire suite by calling the `run` method.

    Example:

    ```mojo
    from testing import assert_equal, TestSuite

    def test_something():
        assert_equal(1 + 1, 2)

    def test_some_other_thing():
        assert_equal(2 + 2, 4)

    def main():
        TestSuite.discover_tests[__functions_in_module()]().run()
    ```

    Alternatively, you can manually register tests by calling the `test` method.

    ```mojo
    from testing import assert_equal, TestSuite

    def some_test():
        assert_equal(1 + 1, 2)

    def main():
        var suite = TestSuite()
        suite.test[some_test]()
        suite^.run()
    ```
    """

    var tests: Tuple[*Variadic.types[T=Movable, *Self.fn_types]]
    var test_names: List[StaticString]
    """The list of tests registered in this suite."""

    var location: _SourceLocation
    """The source location where the test suite was created."""

    var skip_list: Set[String]
    """The list of tests to skip in this suite."""

    var allow_list: Optional[Set[String]]
    """The list of tests to allow in this suite."""

    var cli_args: List[StaticString]
    """The raw command line arguments passed to the test suite."""

    @always_inline
    fn __init__(
        out self: TestSuite[],
        location: Optional[_SourceLocation] = None,
        var cli_args: Optional[List[StaticString]] = None,
    ):
        """Create a new test suite.

        Args:
            location: The location of the test suite (defaults to
                `__call_location`).
            cli_args: The command line arguments to pass to the test suite
                (defaults to `sys.argv()`).
        """
        self.tests = {}
        self.test_names = {}
        self.location = location.or_else(__call_location())
        self.skip_list = {}
        self.allow_list = None  # None means no allow list specified.
        self.cli_args = cli_args.or_else(List[StaticString](argv()))

    fn test[f: fn () raises unified](
        deinit self,
        var func: f,
        out o: TestSuite[
            *Variadic.concat[T=fn() raises unified, Self.fn_types, Variadic.types[f]]
        ][],
        name: StaticString,
    ):
        """Registers a test to be run."""
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(o))

        var new_tests = self.tests.concat[f]((func^,))
        o.tests = new_tests^
        o.test_names = self.test_names^
        o.location = self.location
        o.skip_list = self.skip_list^
        o.allow_list = self.allow_list^
        o.cli_args = self.cli_args^

    fn skip(mut self, name: StaticString):
        """Registers a test to be skipped.

        If attempting to skip a test that is not registered in the suite (either
        explicitly or via automatic discovery), an error will be raised when the
        suite is run.
        """
        # comptime skipped_name = get_function_name[f]()
        self.skip_list.add(name)

    fn _parse_filter_lists(mut self) raises:
        # TODO: We need a proper argument parsing library to do this right.
        ref args = self.cli_args
        var num_args = len(args)
        if num_args <= 1:
            return

        if args[1] == "--only":
            self.allow_list = Set[String]()
        elif args[1] == "--skip-all":
            if num_args > 2:
                raise Error("'--skip-all' does not take any arguments")
            # --skip-all implies an empty allow list.
            self.allow_list = Set[String]()
            return
        elif args[1] != "--skip":
            raise Error(
                "invalid argument: ",
                args[1],
                " (expected '--only' or '--skip')",
            )

        if num_args == 2:
            raise Error("expected test name(s) after '--only' or '--skip'")

        var discovered_tests = Set[String]()
        for test_nm in self.test_names:
            discovered_tests.add(test_nm)

        for idx in range(2, num_args):
            var arg = args[idx]
            if arg not in discovered_tests:
                raise Error(
                    "explicitly ",
                    "allowed" if self.allow_list else "skipped",
                    " test not found in suite: ",
                    arg,
                )
            if self.allow_list:
                self.allow_list[].add(arg)
            else:
                self.skip_list.add(arg)

    fn _should_skip(self, test_nm: StaticString) -> Bool:
        if test_nm in self.skip_list:
            return True
        if not self.allow_list:
            return False
        # SAFETY: We know that `self.allow_list` is not `None` here.
        return test_nm not in self.allow_list.unsafe_value()

    fn _validate_skip_list(self) raises:
        # TODO: _Test doesn't conform to Equatable, so we can't use
        # `in` here. Also, we might wanna do this in O(1) time.
        for test_name in self.skip_list:
            var found = False
            for test_nm in self.test_names:
                if test_nm == test_name:
                    found = True
                    break
            if not found:
                raise Error(
                    (
                        "trying to skip a test that is not registered in the"
                        " suite: "
                    ),
                    test_name,
                )

    fn generate_report(
        mut self, skip_all: Bool = False
    ) raises -> TestSuiteReport:
        """Runs the test suite and generates a report.

        Args:
            skip_all: Only collect tests, but don't execute them (defaults to
                `False`).

        Raises:
            If an error occurs during test collection.

        Returns:
            A report containing the results of all tests.
        """
        self._validate_skip_list()

        # We call `_parse_filter_lists` even if `skip_all` is true to make sure
        # CLI arguments are parsed and checked. We should probably refactor this
        # when we have a proper argument parsing library.
        self._parse_filter_lists()
        if skip_all:
            self.allow_list = Set[String]()

        var reports = List[TestReport](capacity=len(self.tests))

        @parameter
        for test_idx in range(Variadic.size(Self.fn_types)):
            var test_nm = self.test_names[test_idx]
            if self._should_skip(test_nm):
                reports.append(TestReport.skipped(name=test_nm))
                continue

            var error: Optional[Error] = None
            var start = perf_counter_ns()
            try:
                self.tests[test_idx]()
            except e:
                error = {e^}
            var duration = perf_counter_ns() - start

            if error:
                reports.append(
                    TestReport.failed(
                        name=test_nm, duration_ns=duration, error=error.take()
                    )
                )
            else:
                reports.append(
                    TestReport.passed(name=test_nm, duration_ns=duration)
                )

        return TestSuiteReport(reports=reports^, location=self.location)

    fn run(deinit self, *, quiet: Bool = False, skip_all: Bool = False) raises:
        """Runs the test suite and prints the results to the console.

        Args:
            quiet: Suppresses printing the report when the suite does not fail
                (defaults to `False`).
            skip_all: Only collect tests, but don't execute them (defaults to
                `False`).

        Raises:
            If a test in the test suite fails or if an error occurs during test
            collection.
        """
        var report = self.generate_report(skip_all=skip_all)

        if report.failures > 0:
            raise Error(report)
        if not quiet:
            print(report)

    fn abandon(deinit self):
        """Destroy a test suite without running any tests."""
        pass

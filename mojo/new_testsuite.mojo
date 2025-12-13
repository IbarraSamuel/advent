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


struct _Test[fn_type: fn () raises unified](Copyable, Movable):
    """A single test to run."""

    var test_fn: Pointer[Self.fn_type, MutAnyOrigin]
    var name: StaticString

    fn __init__(out self, mut f: Self.fn_type, name: StaticString):
        self.test_fn = Pointer[origin=MutAnyOrigin](to=f)
        self.name = name


fn main() raises:
    fn unified_test() unified {}:
        print("unified")

    fn unified_second_test() unified {}:
        print("unified")

    fn normal_test() raises:
        pass

    var ts = TestSuite(cli_args=List[StaticString]())
    ts.test(unified_test, "unified_test")
    ts.test(unified_second_test, "unified_second")
    ts^.run()


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

    var tests: Tuple[*Self.fn_types]
    comptime test_names = Variadic.splat[
        StaticString, Variadic.size(Self.fn_types)
    ]
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
        out self,
        *,
        test: Some[fn () raises unified],
        location: Optional[_SourceLocation] = None,
        var cli_args: Optional[List[StaticString]] = None,
    ):
        """Create a new test suite.

        Args:
            test: The test to start building the testsuite.
            location: The location of the test suite (defaults to
                `__call_location`).
            cli_args: The command line arguments to pass to the test suite
                (defaults to `sys.argv()`).
        """
        self.tests = List[_Test[Self.fn_type]]()
        self.location = location.or_else(__call_location())
        self.skip_list = {}
        self.allow_list = None  # None means no allow list specified.
        self.cli_args = cli_args.or_else(List[StaticString](argv()))

    # fn _register_tests[test_funcs: Tuple, /](mut self) raises:
    #     """Internal function to prevent all registrations from being inlined."""

    #     @parameter
    #     for idx in range(len(test_funcs)):
    #         comptime test_func = test_funcs[idx]

    #         @parameter
    #         if get_function_name[test_func]().startswith("test_"):

    #             @parameter
    #             if _type_is_eq[type_of(test_func), _Test.fn_type]():
    #                 self.test[test_func]()
    #             else:
    #                 raise Error(
    #                     "test function '",
    #                     get_function_name[test_func](),
    #                     "' has nonconforming signature",
    #                 )

    # @always_inline
    # @staticmethod
    # fn discover_tests[
    #     test_funcs: Tuple, /
    # ](
    #     *,
    #     location: Optional[_SourceLocation] = None,
    #     var cli_args: Optional[List[StaticString]] = None,
    # ) raises -> Self:
    #     """Discover tests from the given list of functions, and register them.

    #     Parameters:
    #         test_funcs: The pack of functions to discover tests from. In most
    #             cases, callers should pass `__functions_in_module()`.

    #     Args:
    #         location: The location of the test suite (defaults to
    #             `__call_location`).
    #         cli_args: The command line arguments to pass to the test suite
    #             (defaults to `sys.argv()`).

    #     Raises:
    #         If test discovery fails (e.g. because of a nonconforming test
    #         function signature).

    #     Returns:
    #         A new TestSuite with all discovered tests registered.
    #     """

    #     var suite = Self(
    #         location=location.or_else(__call_location()), cli_args=cli_args^
    #     )
    #     try:
    #         suite._register_tests[test_funcs]()
    #     except e:
    #         suite^.abandon()
    #         raise e
    #     return suite^

    fn test(mut self, mut func: Self.fn_type, name: StaticString):
        """Registers a test to be run."""
        # get_function_name[type_of(f)]
        self.tests.append(_Test(func, name))

    fn skip[f: _Test.fn_type](mut self, name: StaticString):
        """Registers a test to be skipped.

        If attempting to skip a test that is not registered in the suite (either
        explicitly or via automatic discovery), an error will be raised when the
        suite is run.

        Parameters:
            f: The function to skip.
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
        for test in self.tests:
            discovered_tests.add(test.name)

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

    fn _should_skip(self, test: _Test) -> Bool:
        if test.name in self.skip_list:
            return True
        if not self.allow_list:
            return False
        # SAFETY: We know that `self.allow_list` is not `None` here.
        return test.name not in self.allow_list.unsafe_value()

    fn _validate_skip_list(self) raises:
        # TODO: _Test doesn't conform to Equatable, so we can't use
        # `in` here. Also, we might wanna do this in O(1) time.
        for test_name in self.skip_list:
            var found = False
            for test in self.tests:
                if test.name == test_name:
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
        for test in self.tests:
            if self._should_skip(test):
                reports.append(TestReport.skipped(name=test.name))
                continue

            var error: Optional[Error] = None
            var start = perf_counter_ns()
            try:
                test.test_fn[]()
            except e:
                error = {e^}
            var duration = perf_counter_ns() - start

            if error:
                reports.append(
                    TestReport.failed(
                        name=test.name, duration_ns=duration, error=error.take()
                    )
                )
            else:
                reports.append(
                    TestReport.passed(name=test.name, duration_ns=duration)
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

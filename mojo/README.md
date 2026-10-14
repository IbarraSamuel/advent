# Mojo Advent Of Code

This folder uses uv, but it uses mojo-compiler as a dependency.
Also includes `mojo` if you want to work on Visual Studio Code (It needs mojo-lsp-server included in `mojo` package).

Run the Advent of Code sample tests with:

```sh
pixi run advent -m test
```

To limit the tests to a year, day, or part, add `-y`, `-d`, or `-p`:

```sh
pixi run advent -m test -y 2023 -d 5 -p 2
```

The test runner uses the configured cases in `advent_config.toml`; each part is
checked against its own test cases. A failed year suite is reported, and the
command exits unsuccessfully if any selected suite fails.

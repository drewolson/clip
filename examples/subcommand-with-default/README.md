# subcommand-with-default

```
$ gleam run -- --help
  Compiling cli
   Compiled in 0.23s
    Running cli.main
subcommand

  Run a subcommand

Usage:

  subcommand <COMMAND> [OPTIONS]

Commands:

  foo
  bar

Options:

  (--d D)       D
  [--help,-h]   Print this help
```

```
$ gleam run -- foo --a first --b 1
   Compiled in 0.01s
    Running cli.main
Foo("first", 1)
```

```
$ gleam run -- bar --c
   Compiled in 0.01s
    Running cli.main
Bar(True)
```

```
$ gleam run -- --d 1.23
   Compiled in 0.01s
    Running cli.main
TopLevel(1.23)
```

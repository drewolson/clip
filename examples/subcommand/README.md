# subcommand

```
$ gleam run -- --help
   Compiled in 0.01s
    Running cli.main
subcommand -- Run a subcommand

Usage:

  subcommand <COMMAND> [OPTIONS]

Commands:

  foo
  bar
  baz

Options:

  [--help,-h]   Print this help
```

# TODO this doesn't work
```
$ gleam run -- foo --help
   Compiled in 0.01s
    Running cli.main
subcommand foo -- Run foo

Usage:

  subcommand foo [OPTIONS]

Options:

  (--a A)       A
  (--b B)       B
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
$ gleam run -- baz --d 1.23
   Compiled in 0.01s
    Running cli.main
Baz(1.23)
```

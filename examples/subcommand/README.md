# subcommand

```
$ gleam run -- --help
   Compiled in 0.00s
    Running cli.main
subcommand -- Run a subcommand

Usage:

  subcommand <COMMAND> [OPTIONS]

Commands:

  foo
  bar
  baz
  qux

Options:

  [--help,-h]   Print this help
```

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

```
$ gleam run -- qux
   Compiled in 0.00s
    Running cli.main
Qux
```

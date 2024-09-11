# custom-opt-types

```
$ gleam run -- --help
  Compiling cli
   Compiled in 0.22s
    Running cli.main
custom-opt-types -- Options with custom types

Usage:

  custom-opt-types [OPTIONS]

Options:

  (--first FIRST)       First
  (--second SECOND)     Second
  (--third THIRD)       Third
  (--fourth FOURTH)     Fourth
  [--help,-h]           Print this help
```

```
$ gleam run -- --first 1 --second 2.0 --third hello --fourth foo
   Compiled in 0.01s
    Running cli.main
Args(1, 2.0, "HELLO", Foo)
```

```
$ gleam run -- --first bad --second 2.0 --third hello --fourth foo
   Compiled in 0.01s
    Running cli.main
Non-integer value provided for first
```

```
$ gleam run -- --first 1 --second 2.0 --third hello --fourth blah
  Compiling cli
   Compiled in 0.23s
    Running cli.main
Invalid value for fourth: blah
```

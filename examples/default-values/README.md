# default-values

```
$ gleam run -- --help
   Compiled in 0.01s
    Running cli.main
default-values

  Provide default values

Usage:

  default-values [OPTIONS] SECOND

Arguments:

  SECOND                Second (default: Error(Nil))

Options:

  [--first FIRST]       First (default: "default value")
  [--help,-h]           Print this help
```

```
$ gleam run --
   Compiled in 0.01s
    Running cli.main
Args("default value", Error(Nil))
```

```
$ gleam run -- --first first_value second_value
   Compiled in 0.01s
    Running cli.main
Args("first_value", Ok("second_value"))
```

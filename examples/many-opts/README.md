# many-opts

```
$ gleam run -- --help
   Compiled in 0.01s
    Running cli.main
many-opts -- Provide many options

Usage:

  many-opts [OPTIONS] NEXT REST...

Arguments:

  NEXT                  Next
  REST...               Rest (zero or more)

Options:

  (--named NAMED)       Named
  [--flag]              Flag
  [--help,-h]           Print this help
```

```
$ gleam run -- --named named_val --flag next a b c
   Compiled in 0.01s
    Running cli.main
Args("named_val", True, "next", ["a", "b", "c"])
```

```
$ gleam run -- --named named_val next
   Compiled in 0.01s
    Running cli.main
Args("named_val", False, "next", [])
```

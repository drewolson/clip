# simple

```
$ gleam run -- --help
   Compiled in 0.00s
    Running cli.main
person -- Create a person

Usage:

  person [OPTIONS]

Options:

  (--name NAME) Your name
  (--age AGE)   Your age
  [--help,-h]   Print this help
```

```
$ gleam run -- --name Drew --age 42
   Compiled in 0.00s
    Running cli.main
Person("Drew", 42)
```

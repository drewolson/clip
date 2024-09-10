# simple

```
$ gleam run -- --help
   Compiled in 0.00s
    Running simple.main
person -- create a person

Usage:

  person [OPTIONS]

Options:

  (--name NAME)
  (--age AGE)
  [--help,-h]   Print this help
```

```
$ gleam run -- --name "Drew" --age 42
   Compiled in 0.00s
    Running simple.main
Person("Drew", 42)
```

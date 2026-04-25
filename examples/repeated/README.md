# repeated

```
$ gleam run -- --help
   Compiled in 0.01s
    Running cli.main
person

  Create a person

Usage:

  person [OPTIONS]

Options:

  (--names NAMES)       Your names (separated with commas)
  (--age AGE)           Your age
  [--help,-h]           Print this help
```
```
$ gleam run -- --names "Drew, Andrew" --age 43
   Compiled in 0.01s
    Running cli.main
Person(["Drew", "Andrew"], 43)
```

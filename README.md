# clip - A CLI Option Parser for Gleam

[![Package Version](https://img.shields.io/hexpm/v/clip)](https://hex.pm/packages/clip)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/clip/)

```gleam
import argv
import clip
import clip/opt
import gleam/io
import gleam/string

type Person {
  Person(name: String, age: Int)
}

fn command() {
  clip.command(fn(name) { fn(age) { Person(name, age) } })
  |> clip.opt(opt.new("name"))
  |> clip.opt(opt.new("age") |> opt.int)
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("person", "create a person")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}
```

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

Take a look at the
[examples](https://github.com/drewolson/clip/tree/main/examples) for more information.

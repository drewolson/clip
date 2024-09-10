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

```sh
$ gleam run -- --help
person -- create a person

Usage:

  person [OPTIONS]

Options:

  (--name NAME)
  (--age AGE)
  [--help,-h]   Print this help
```

```sh
$ gleam run -- --name "Drew" --age 42
Person("Drew", 42)
```

Further documentation can be found at <https://hexdocs.pm/clip>.

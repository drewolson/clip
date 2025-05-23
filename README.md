# clip - A CLI option parser for Gleam

[![Package Version](https://img.shields.io/hexpm/v/clip)](https://hex.pm/packages/clip)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/clip/)

`clip` is a library for parsing command line interface options.

## Simple Example

```gleam
import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import gleam/io
import gleam/string

type Person {
  Person(name: String, age: Int)
}

fn name_opt() -> Opt(String) {
  opt.new("name") |> opt.help("Your name")
}

fn age_opt() -> Opt(Int) {
  opt.new("age") |> opt.int |> opt.help("Your age")
}

fn command() -> Command(Person) {
  clip.command({
    use name <- clip.parameter
    use age <- clip.parameter

    Person(name, age)
  })
  |> clip.opt(name_opt())
  |> clip.opt(age_opt())
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("person", "Create a person"))
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
    Running cli.main
person

  Create a person

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

## Using `clip`

`clip` is an "applicative style" options parser. To use `clip`, follow these
steps:

1. First, invoke `clip.command` providing a function to be called with your
   parsed options. This function can be built using the
   [parameter syntax](https://hexdocs.pm/clip/clip.html#parameter).
   Alternatively, you can directly provide a curried function, meaning a two argument
   function looks like `fn(a) { fn(b) { do_stuff(a, b) } }`.
2. Next, use the `|>` operator along with `clip.opt`, `clip.flag`, and
   `clip.arg` to parse command line arguments and provide them as parameters to
   the function given to `clip.command`.
3. Optionally use `clip.help` and `clip/help` to generate help text for your
   command. The user can view this help text via the `--help,-h` flag.
4. Finally, run your parser with `clip.run`, giving it the command you have
   built and the list arguments to parse. I recommend using the `argv` library
   to access these arguments from both erlang and javascript.

## Types of Options

`clip` provides three types of options:

1. An `Option` is a named option with a value, like `--name "Drew"`. You create
   `Option`s with the `clip/opt` module and add them to your command with the
   `clip.opt` function.
2. A `Flag` is a named option without a value, like `--verbose`. If provided, it
   produces `True`, if not provided it produces `False`. You create `Flag`s with
   the `clip/flag` module and add them to your command with the `clip.flag`
   function.
3. An `Argument` is a positional value passed to your command. You create
   `Argument`s with the `clip/arg` module and add them to your command with the
   `clip.arg`, `clip.arg_many`, and `clip.arg_many1` functions.

Take a look at the
[examples](https://github.com/drewolson/clip/tree/main/examples) for more information.

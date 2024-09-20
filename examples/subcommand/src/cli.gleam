import argv
import clip
import clip/flag
import clip/opt
import gleam/io
import gleam/string

type Args {
  Foo(a: String, b: Int)
  Bar(c: Bool)
  Baz(d: Float)
  Qux
}

fn foo_command() {
  clip.command(fn(a) { fn(b) { Foo(a, b) } })
  |> clip.opt(opt.new("a") |> opt.help("A"))
  |> clip.opt(opt.new("b") |> opt.help("B") |> opt.int)
  |> clip.add_help("subcommand foo", "Run foo")
}

fn bar_command() {
  clip.command(fn(c) { Bar(c) })
  |> clip.flag(flag.new("c") |> flag.help("C"))
  |> clip.add_help("subcommand bar", "Run bar")
}

fn baz_command() {
  clip.command(fn(d) { Baz(d) })
  |> clip.opt(opt.new("d") |> opt.help("D") |> opt.float)
  |> clip.add_help("subcommand baz", "Run baz")
}

fn qux_command() {
  clip.return(Qux)
  |> clip.add_help("subcommand qux", "Run qux")
}

fn command() {
  clip.subcommands([
    #("foo", foo_command()),
    #("bar", bar_command()),
    #("baz", baz_command()),
    #("qux", qux_command()),
  ])
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("subcommand", "Run a subcommand")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

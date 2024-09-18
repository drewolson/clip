import argv
import clip
import clip/flag
import clip/opt
import gleam/io
import gleam/string

type Args {
  Foo(a: String, b: Int)
  Bar(c: Bool)
  TopLevel(d: Float)
}

fn foo_command() {
  use a <- clip.opt(opt.new("a") |> opt.help("A"))
  use b <- clip.opt(opt.new("b") |> opt.help("B") |> opt.int)
  clip.pure(Foo(a:, b:))
  |> clip.add_help("subcommand foo", "Run foo")
}

fn bar_command() {
  use c <- clip.flag(flag.new("c") |> flag.help("C"))
  clip.pure(Bar(c:))
  |> clip.add_help("subcommand bar", "Run bar")
}

fn baz_command() {
  use d <- clip.opt(opt.new("d") |> opt.help("D") |> opt.float)
  clip.pure(TopLevel(d:))
  |> clip.add_help("top-level", "Run top-level")
}

fn command() {
  clip.subcommands_with_default(
    [#("foo", foo_command()), #("bar", bar_command())],
    baz_command(),
  )
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

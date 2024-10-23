import argv
import clip
import clip/flag
import clip/help
import clip/opt
import gleam/io
import gleam/string

type Args {
  Foo(a: String, b: Int)
  Bar(c: Bool)
  TopLevel(d: Float)
}

fn foo_command() {
  clip.command(fn(a) { fn(b) { Foo(a, b) } })
  |> clip.opt(opt.new("a") |> opt.help("A"))
  |> clip.opt(opt.new("b") |> opt.help("B") |> opt.int)
  |> clip.help(help.simple("subcommand foo", "Run foo"))
}

fn bar_command() {
  clip.command(fn(c) { Bar(c) })
  |> clip.flag(flag.new("c") |> flag.help("C"))
  |> clip.help(help.simple("subcommand bar", "Run bar"))
}

fn baz_command() {
  clip.command(fn(d) { TopLevel(d) })
  |> clip.opt(opt.new("d") |> opt.help("D") |> opt.float)
  |> clip.help(help.simple("top-level", "Run top-level"))
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
    |> clip.help(help.simple("subcommand", "Run a subcommand"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

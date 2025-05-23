import argv
import clip.{type Command}
import clip/flag
import clip/help
import clip/opt
import gleam/io
import gleam/string

type Args {
  Foo(a: String, b: Int)
  Bar(c: Bool)
  Baz(d: Float)
  Qux
}

fn foo_command() -> Command(Args) {
  clip.command({
    use a <- clip.parameter
    use b <- clip.parameter

    Foo(a, b)
  })
  |> clip.opt(opt.new("a") |> opt.help("A"))
  |> clip.opt(opt.new("b") |> opt.help("B") |> opt.int)
  |> clip.help(help.simple("subcommand foo", "Run foo"))
}

fn bar_command() -> Command(Args) {
  clip.command(fn(c) { Bar(c) })
  |> clip.flag(flag.new("c") |> flag.help("C"))
  |> clip.help(help.simple("subcommand bar", "Run bar"))
}

fn baz_command() -> Command(Args) {
  clip.command(fn(d) { Baz(d) })
  |> clip.opt(opt.new("d") |> opt.help("D") |> opt.float)
  |> clip.help(help.simple("subcommand baz", "Run baz"))
}

fn qux_command() -> Command(Args) {
  clip.return(Qux)
  |> clip.help(help.simple("subcommand qux", "Run qux"))
}

fn command() -> Command(Args) {
  clip.subcommands([
    #("foo", foo_command()),
    #("bar", bar_command()),
    #("baz", baz_command()),
    #("qux", qux_command()),
  ])
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("subcommand", "Run a subcommand"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

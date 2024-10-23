import argv
import clip
import clip/arg
import clip/help
import clip/opt
import gleam/io
import gleam/string

type Args {
  Args(first: String, second: Result(String, Nil))
}

fn command() {
  clip.command(fn(first) { fn(second) { Args(first, second) } })
  |> clip.opt(
    opt.new("first")
    |> opt.help("First")
    |> opt.default("default value"),
  )
  |> clip.arg(
    arg.new("second")
    |> arg.help("Second")
    |> arg.optional,
  )
}

pub fn main() {
  let result =
    command()
    |> clip.help(help.simple("default-values", "Provide default values"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

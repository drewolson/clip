import argv
import clip.{type Command}
import clip/arg
import clip/help
import clip/opt
import gleam/io
import gleam/string

type Args {
  Args(first: String, second: Result(String, Nil))
}

fn command() -> Command(Args) {
  clip.command({
    use first <- clip.parameter
    use second <- clip.parameter

    Args(first, second)
  })
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

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("default-values", "Provide default values"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

import argv
import clip
import clip/arg
import clip/opt
import gleam/io
import gleam/string

type Args {
  Args(first: String, second: Result(String, Nil))
}

fn command() {
  use first <- clip.opt(
    opt.new("first")
    |> opt.help("First")
    |> opt.default("default value"),
  )
  use second <- clip.arg(
    arg.new("second")
    |> arg.help("Second")
    |> arg.optional,
  )
  clip.pure(Args(first:, second:))
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("default-values", "Provide default values")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

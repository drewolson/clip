import argv
import clip
import clip/arg
import clip/flag
import clip/opt
import gleam/io
import gleam/string

type Args {
  Args(named: String, flag: Bool, next: String, rest: List(String))
}

fn command() {
  use named <- clip.opt(opt.new("named") |> opt.help("Named"))
  use flag <- clip.flag(flag.new("flag") |> flag.help("Flag"))
  use next <- clip.arg(arg.new("next") |> arg.help("Next"))
  use rest <- clip.arg_many(arg.new("rest") |> arg.help("Rest"))
  clip.pure(Args(named:, flag:, next:, rest:))
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("many-opts", "Provide many options")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

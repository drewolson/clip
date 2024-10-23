import argv
import clip
import clip/arg
import clip/flag
import clip/help
import clip/opt
import gleam/io
import gleam/string

type Args {
  Args(named: String, flag: Bool, next: String, rest: List(String))
}

fn command() {
  clip.command(fn(named) {
    fn(flag) { fn(next) { fn(rest) { Args(named, flag, next, rest) } } }
  })
  |> clip.opt(opt.new("named") |> opt.help("Named"))
  |> clip.flag(flag.new("flag") |> flag.help("Flag"))
  |> clip.arg(arg.new("next") |> arg.help("Next"))
  |> clip.arg_many(arg.new("rest") |> arg.help("Rest"))
}

pub fn main() {
  let result =
    command()
    |> clip.help(help.simple("many-opts", "Provide many options"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

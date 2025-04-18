import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import gleam/io
import gleam/string

type Custom {
  Foo
  Bar
}

type Args {
  Args(first: Int, second: Float, third: String, fourth: Custom)
}

fn first_opt() -> Opt(Int) {
  opt.new("first")
  |> opt.help("First")
  |> opt.int
}

fn second_opt() -> Opt(Float) {
  opt.new("second")
  |> opt.help("Second")
  |> opt.float
}

fn third_opt() -> Opt(String) {
  opt.new("third")
  |> opt.help("Third")
  |> opt.map(fn(v) { string.uppercase(v) })
}

fn fourth_opt() -> Opt(Custom) {
  opt.new("fourth")
  |> opt.help("Fourth")
  |> opt.try_map(fn(v) {
    case v {
      "foo" -> Ok(Foo)
      "bar" -> Ok(Bar)
      other -> Error("Invalid value for fourth: " <> other)
    }
  })
}

fn command() -> Command(Args) {
  clip.command({
    use first <- clip.parameter
    use second <- clip.parameter
    use third <- clip.parameter
    use fourth <- clip.parameter

    Args(first, second, third, fourth)
  })
  |> clip.opt(first_opt())
  |> clip.opt(second_opt())
  |> clip.opt(third_opt())
  |> clip.opt(fourth_opt())
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("custom-opt-types", "Options with custom types"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

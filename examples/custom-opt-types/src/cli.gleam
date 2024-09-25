import argv
import clip
import clip/opt
import gleam/io
import gleam/string

type Custom {
  Foo
  Bar
}

type Args {
  Args(first: Int, second: Float, third: String, fourth: Custom)
}

fn first_opt() {
  opt.new("first")
  |> opt.help("First")
  |> opt.int
}

fn second_opt() {
  opt.new("second")
  |> opt.help("Second")
  |> opt.float
}

fn third_opt() {
  opt.new("third")
  |> opt.help("Third")
  |> opt.map(fn(v) { string.uppercase(v) })
}

fn fourth_opt() {
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

fn command() {
  clip.command(fn(first) {
    fn(second) {
      fn(third) { fn(fourth) { Args(first, second, third, fourth) } }
    }
  })
  |> clip.opt(first_opt())
  |> clip.opt(second_opt())
  |> clip.opt(third_opt())
  |> clip.opt(fourth_opt())
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("custom-opt-types", "Options with custom types")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(args) -> args |> string.inspect |> io.println
  }
}

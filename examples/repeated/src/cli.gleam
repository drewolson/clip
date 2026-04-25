import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import gleam/io
import gleam/list
import gleam/string

type Person {
  Person(names: List(String), age: Int)
}

fn repeated(opt: Opt(String)) -> Opt(List(String)) {
  opt.map(opt, fn(s) { s |> string.split(on: ",") |> list.map(string.trim) })
}

fn names_opt() -> Opt(List(String)) {
  opt.new("names")
  |> opt.help("Your names (separated with commas)")
  |> repeated()
}

fn age_opt() -> Opt(Int) {
  opt.new("age") |> opt.int |> opt.help("Your age")
}

fn command() -> Command(Person) {
  clip.command({
    use names <- clip.parameter
    use age <- clip.parameter

    Person(names, age)
  })
  |> clip.opt(names_opt())
  |> clip.opt(age_opt())
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("person", "Create a person"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

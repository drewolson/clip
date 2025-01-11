import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import gleam/io
import gleam/string

type Person {
  Person(name: String, age: Int)
}

fn name_opt() -> Opt(String) {
  opt.new("name") |> opt.help("Your name")
}

fn age_opt() -> Opt(Int) {
  opt.new("age") |> opt.int |> opt.help("Your age")
}

fn command() -> Command(Person) {
  clip.command({
    use name <- clip.parameter
    use age <- clip.parameter

    Person(name, age)
  })
  |> clip.opt(name_opt())
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

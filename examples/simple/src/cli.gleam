import argv
import clip
import clip/opt
import gleam/io
import gleam/string

type Person {
  Person(name: String, age: Int)
}

fn command() {
  use name <- clip.opt(opt.new("name") |> opt.help("Your name"))
  use age <- clip.opt(opt.new("age") |> opt.int |> opt.help("Your age"))
  clip.pure(Person(name:, age:))
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("person", "Create a person")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

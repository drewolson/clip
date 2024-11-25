import argv
import clip
import clip/help
import clip/opt
import gleam/io
import gleam/string

type Person {
  Person(name: String, age: Int)
}

fn command() {
  clip.command({
    use name <- clip.parameter
    use age <- clip.parameter

    Person(name, age)
  })
  |> clip.opt(opt.new("name") |> opt.help("Your name"))
  |> clip.opt(opt.new("age") |> opt.int |> opt.help("Your age"))
}

pub fn main() {
  let result =
    command()
    |> clip.help(help.simple("person", "Create a person"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

import argv
import clip
import clip/opt
import gleam/io
import gleam/string

type Person {
  Person(name: String, age: Int)
}

fn command() {
  clip.command({
    use name <- clip.param
    use age <- clip.param

    Person(name, age)
  })
  |> clip.opt(opt.new("name") |> opt.help("Your name"))
  |> clip.opt(opt.new("age") |> opt.int |> opt.help("Your age"))
}

pub fn main() {
  let result =
    command()
    |> clip.add_help("param-syntax", "Create a person")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> person |> string.inspect |> io.println
  }
}

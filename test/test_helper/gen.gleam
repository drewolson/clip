import gleam/string
import qcheck.{type Generator}

pub fn clip_string() -> Generator(String) {
  qcheck.non_empty_string()
  |> qcheck.map(string.replace(_, each: "-", with: "a"))
}

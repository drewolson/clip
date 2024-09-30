import exception
import gleam/string
import qcheck.{type Generator}

pub fn clip_string() -> Generator(String) {
  qcheck.string_non_empty()
  |> qcheck.map(string.replace(_, each: "-", with: "a"))
}

pub fn given(generator: Generator(a), f: fn(a) -> Nil) -> Nil {
  qcheck.run_result(qcheck.default_config(), generator, fn(a) {
    exception.rescue(fn() { f(a) })
  })
}

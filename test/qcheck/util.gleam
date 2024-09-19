import exception
import gleam/string
import qcheck.{type Config, type Generator}

pub fn clip_string() -> Generator(String) {
  qcheck.string_non_empty()
  |> qcheck.map(fn(s) { string.replace(s, each: "-", with: "a") })
}

fn config() -> Config {
  qcheck.default_config()
  |> qcheck.with_test_count(1000)
}

pub fn given(generator: Generator(a), f: fn(a) -> Nil) -> Nil {
  qcheck.run_result(config(), generator, fn(a) {
    exception.rescue(fn() { f(a) })
  })
}

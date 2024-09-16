import exception
import qcheck.{type Config, type Generator}

fn config() -> Config {
  qcheck.default_config()
  |> qcheck.with_test_count(1000)
}

pub fn given(generator: Generator(a), f: fn(a) -> Nil) -> Nil {
  qcheck.run_result(config(), generator, fn(a) {
    exception.rescue(fn() { f(a) })
  })
}

import exception
import qcheck/generator.{type Generator}
import qcheck/qtest
import qcheck/qtest/config.{type Config}

fn config() -> Config {
  config.default()
  |> config.with_test_count(1000)
}

pub fn given(generator: Generator(a), f: fn(a) -> Nil) -> Nil {
  qtest.run_result(config(), generator, fn(a) {
    exception.rescue(fn() { f(a) })
  })
}

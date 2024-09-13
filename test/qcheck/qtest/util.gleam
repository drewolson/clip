import qcheck/generator.{type Generator}
import qcheck/qtest
import qcheck/qtest/config.{type Config}

fn config() -> Config {
  config.default()
  |> config.with_test_count(1000)
}

pub fn given(generator: Generator(a), f: fn(a) -> Bool) -> Nil {
  qtest.run(config(), generator, f)
}

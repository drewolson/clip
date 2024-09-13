import clip
import clip/opt
import gleam/float
import gleam/int
import gleam/string
import qcheck/generator
import qcheck/qtest

pub fn opt_test() {
  use #(name, value) <- qtest.given(generator.tuple2(
    generator.string_non_empty(),
    generator.string_non_empty(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name))

  let a = clip.run(command, ["--" <> name, value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(value), Error("missing required arg: --" <> name))
}

pub fn try_map_test() {
  use #(name, value) <- qtest.given(generator.tuple2(
    generator.string_non_empty(),
    generator.small_positive_or_zero_int(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(
      opt.new(name)
      |> opt.try_map(fn(s) {
        case int.parse(s) {
          Ok(n) -> Ok(n)
          Error(Nil) -> Error("Bad int")
        }
      }),
    )
    |> clip.run(["--" <> name, int.to_string(value)])

  result == Ok(value)
}

pub fn map_test() {
  use #(name, value) <- qtest.given(generator.tuple2(
    generator.string_non_empty(),
    generator.string_non_empty(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(
      opt.new(name)
      |> opt.map(string.uppercase),
    )
    |> clip.run(["--" <> name, value])

  result == Ok(string.uppercase(value))
}

pub fn optional_test() {
  use #(name, value) <- qtest.given(generator.tuple2(
    generator.string_non_empty(),
    generator.string_non_empty(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.optional)

  let a = clip.run(command, ["--" <> name, value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(Ok(value)), Ok(Error(Nil)))
}

pub fn default_test() {
  use #(name, value, default) <- qtest.given(generator.tuple3(
    generator.string_non_empty(),
    generator.string_non_empty(),
    generator.string_non_empty(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.default(default))

  let a = clip.run(command, ["--" <> name, value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(value), Ok(default))
}

pub fn int_test() {
  use #(name, value) <- qtest.given(generator.tuple2(
    generator.string_non_empty(),
    generator.small_positive_or_zero_int(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.int)
    |> clip.run(["--" <> name, int.to_string(value)])

  result == Ok(value)
}

pub fn float_test() {
  use #(name, value) <- qtest.given(generator.tuple2(
    generator.string_non_empty(),
    generator.float(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.float)
    |> clip.run(["--" <> name, float.to_string(value)])

  result == Ok(value)
}

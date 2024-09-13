import clip
import clip/opt
import gleam/float
import gleam/int
import gleam/string
import qcheck/generator
import qcheck/qtest

pub fn opt_test() {
  let gen =
    generator.return(fn(a) { fn(b) { #(a, b) } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.string_non_empty())

  use #(name, value) <- qtest.given(gen)

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name))

  let a = clip.run(command, ["--" <> name, value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(value), Error("missing required arg: --" <> name))
}

pub fn try_map_test() {
  let gen =
    generator.return(fn(a) { fn(b) { #(a, b) } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.small_positive_or_zero_int())

  use #(name, value) <- qtest.given(gen)

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
  let gen =
    generator.return(fn(a) { fn(b) { #(a, b) } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.string_non_empty())

  use #(name, value) <- qtest.given(gen)

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
  let gen =
    generator.return(fn(a) { fn(b) { #(a, b) } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.string_non_empty())

  use #(name, value) <- qtest.given(gen)

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.optional)

  let a = clip.run(command, ["--" <> name, value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(Ok(value)), Ok(Error(Nil)))
}

pub fn default_test() {
  let gen =
    generator.return(fn(a) { fn(b) { fn(c) { #(a, b, c) } } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.string_non_empty())

  use #(name, value, default) <- qtest.given(gen)

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.default(default))

  let a = clip.run(command, ["--" <> name, value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(value), Ok(default))
}

pub fn int_test() {
  let gen =
    generator.return(fn(a) { fn(b) { #(a, b) } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.small_positive_or_zero_int())

  use #(name, value) <- qtest.given(gen)

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.int)
    |> clip.run(["--" <> name, int.to_string(value)])

  result == Ok(value)
}

pub fn float_test() {
  let gen =
    generator.return(fn(a) { fn(b) { #(a, b) } })
    |> generator.apply(generator.string_non_empty())
    |> generator.apply(generator.float())

  use #(name, value) <- qtest.given(gen)

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.float)
    |> clip.run(["--" <> name, float.to_string(value)])

  result == Ok(value)
}

import clip
import clip/arg
import gleam/float
import gleam/int
import gleam/string
import qcheck/generator
import qcheck/qtest/util.{given}

pub fn arg_test() {
  use value <- given(generator.string())

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg"))

  let a = clip.run(command, [value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(value), Error("missing required arg: arg"))
}

pub fn try_map_test() {
  use i <- given(generator.small_positive_or_zero_int())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(
      arg.new("arg")
      |> arg.try_map(fn(s) {
        case int.parse(s) {
          Ok(n) -> Ok(n)
          Error(Nil) -> Error("Bad int")
        }
      }),
    )
    |> clip.run([int.to_string(i)])

  result == Ok(i)
}

pub fn map_test() {
  use value <- given(generator.string())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.map(string.uppercase))
    |> clip.run([value])

  result == Ok(string.uppercase(value))
}

pub fn optional_test() {
  use value <- given(generator.string())

  let a =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.optional)
    |> clip.run([value])

  let b =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.optional)
    |> clip.run([])

  #(a, b) == #(Ok(Ok(value)), Ok(Error(Nil)))
}

pub fn default_test() {
  use #(value, default) <- given(generator.tuple2(
    generator.string_non_empty(),
    generator.string_non_empty(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.default(default))

  let a = clip.run(command, [value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(value), Ok(default))
}

pub fn int_test() {
  use i <- given(generator.small_positive_or_zero_int())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.int)
    |> clip.run([int.to_string(i)])

  result == Ok(i)
}

pub fn float_test() {
  use i <- given(generator.float())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.float)
    |> clip.run([float.to_string(i)])

  result == Ok(i)
}

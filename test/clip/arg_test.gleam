import clip
import clip/arg
import gleam/float
import gleam/int
import gleam/string
import qcheck
import test_helper/qcheck_util

pub fn arg_test() {
  use value <- qcheck.given(qcheck_util.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg"))

  assert clip.run(command, [value]) == Ok(value)

  assert clip.run(command, []) == Error("missing required arg: arg")
}

pub fn try_map_test() {
  use i <- qcheck.given(qcheck.small_non_negative_int())

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

  assert result == Ok(i)
}

pub fn map_test() {
  use value <- qcheck.given(qcheck_util.clip_string())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.map(string.uppercase))
    |> clip.run([value])

  assert result == Ok(string.uppercase(value))
}

pub fn optional_test() {
  use value <- qcheck.given(qcheck_util.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.optional)

  assert clip.run(command, [value]) == Ok(Ok(value))

  assert clip.run(command, []) == Ok(Error(Nil))
}

pub fn default_test() {
  use #(value, default) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.default(default))

  assert clip.run(command, [value]) == Ok(value)

  assert clip.run(command, []) == Ok(default)
}

pub fn int_test() {
  use i <- qcheck.given(qcheck.small_non_negative_int())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.int)
    |> clip.run([int.to_string(i)])

  assert result == Ok(i)
}

pub fn float_test() {
  use i <- qcheck.given(qcheck.float())

  let result =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.float)
    |> clip.run([float.to_string(i)])

  assert result == Ok(i)
}

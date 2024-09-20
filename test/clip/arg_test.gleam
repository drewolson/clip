import clip
import clip/arg
import gleam/float
import gleam/int
import gleam/string
import gleeunit/should
import qcheck
import test_helper/qcheck_util

pub fn arg_test() {
  use value <- qcheck_util.given(qcheck_util.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg"))

  clip.run(command, [value])
  |> should.equal(Ok(value))

  clip.run(command, [])
  |> should.equal(Error("missing required arg: arg"))
}

pub fn try_map_test() {
  use i <- qcheck_util.given(qcheck.small_positive_or_zero_int())

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
  |> should.equal(Ok(i))
}

pub fn map_test() {
  use value <- qcheck_util.given(qcheck_util.clip_string())

  clip.command(fn(a) { a })
  |> clip.arg(arg.new("arg") |> arg.map(string.uppercase))
  |> clip.run([value])
  |> should.equal(Ok(string.uppercase(value)))
}

pub fn optional_test() {
  use value <- qcheck_util.given(qcheck_util.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.optional)

  clip.run(command, [value])
  |> should.equal(Ok(Ok(value)))

  clip.run(command, [])
  |> should.equal(Ok(Error(Nil)))
}

pub fn default_test() {
  use #(value, default) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.arg(arg.new("arg") |> arg.default(default))

  clip.run(command, [value])
  |> should.equal(Ok(value))

  clip.run(command, [])
  |> should.equal(Ok(default))
}

pub fn int_test() {
  use i <- qcheck_util.given(qcheck.small_positive_or_zero_int())

  clip.command(fn(a) { a })
  |> clip.arg(arg.new("arg") |> arg.int)
  |> clip.run([int.to_string(i)])
  |> should.equal(Ok(i))
}

pub fn float_test() {
  use i <- qcheck_util.given(qcheck.float())

  clip.command(fn(a) { a })
  |> clip.arg(arg.new("arg") |> arg.float)
  |> clip.run([float.to_string(i)])
  |> should.equal(Ok(i))
}

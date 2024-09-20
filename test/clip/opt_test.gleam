import clip
import clip/opt
import gleam/float
import gleam/int
import gleam/string
import gleeunit/should
import qcheck
import test_helper/qcheck_util

pub fn opt_test() {
  use #(name, value) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name))

  clip.run(command, ["--" <> name, value])
  |> should.equal(Ok(value))

  clip.run(command, [])
  |> should.equal(Error("missing required arg: --" <> name))
}

pub fn try_map_test() {
  use #(name, value) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.small_positive_or_zero_int(),
  ))

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
  |> should.equal(Ok(value))
}

pub fn map_test() {
  use #(name, value) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  clip.command(fn(a) { a })
  |> clip.opt(
    opt.new(name)
    |> opt.map(string.uppercase),
  )
  |> clip.run(["--" <> name, value])
  |> should.equal(Ok(string.uppercase(value)))
}

pub fn optional_test() {
  use #(name, value) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.optional)

  clip.run(command, ["--" <> name, value])
  |> should.equal(Ok(Ok(value)))

  clip.run(command, [])
  |> should.equal(Ok(Error(Nil)))
}

pub fn default_test() {
  use #(name, value, default) <- qcheck_util.given(qcheck.tuple3(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.default(default))

  clip.run(command, ["--" <> name, value])
  |> should.equal(Ok(value))

  clip.run(command, [])
  |> should.equal(Ok(default))
}

pub fn int_test() {
  use #(name, value) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.small_positive_or_zero_int(),
  ))

  clip.command(fn(a) { a })
  |> clip.opt(opt.new(name) |> opt.int)
  |> clip.run(["--" <> name, int.to_string(value)])
  |> should.equal(Ok(value))
}

pub fn float_test() {
  use #(name, value) <- qcheck_util.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.float(),
  ))

  clip.command(fn(a) { a })
  |> clip.opt(opt.new(name) |> opt.float)
  |> clip.run(["--" <> name, float.to_string(value)])
  |> should.equal(Ok(value))
}

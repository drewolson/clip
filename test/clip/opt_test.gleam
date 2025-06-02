import clip
import clip/opt
import gleam/float
import gleam/int
import gleam/string
import qcheck
import test_helper/qcheck_util

pub fn opt_test() {
  use #(name, value) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name))

  assert clip.run(command, ["--" <> name, value]) == Ok(value)

  assert clip.run(command, []) == Error("missing required arg: --" <> name)
}

pub fn try_map_test() {
  use #(name, value) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.small_non_negative_int(),
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

  assert result == Ok(value)
}

pub fn map_test() {
  use #(name, value) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(
      opt.new(name)
      |> opt.map(string.uppercase),
    )
    |> clip.run(["--" <> name, value])

  assert result == Ok(string.uppercase(value))
}

pub fn optional_test() {
  use #(name, value) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.optional)

  assert clip.run(command, ["--" <> name, value]) == Ok(Ok(value))

  assert clip.run(command, []) == Ok(Error(Nil))
}

pub fn default_test() {
  use #(name, value, default) <- qcheck.given(qcheck.tuple3(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let command =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.default(default))

  assert clip.run(command, ["--" <> name, value]) == Ok(value)

  assert clip.run(command, []) == Ok(default)
}

pub fn int_test() {
  use #(name, value) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.small_non_negative_int(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.int)
    |> clip.run(["--" <> name, int.to_string(value)])

  assert result == Ok(value)
}

pub fn float_test() {
  use #(name, value) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.float(),
  ))

  let result =
    clip.command(fn(a) { a })
    |> clip.opt(opt.new(name) |> opt.float)
    |> clip.run(["--" <> name, float.to_string(value)])

  assert result == Ok(value)
}

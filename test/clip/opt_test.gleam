import clip
import clip/opt
import gleam/float
import gleam/int
import gleam/string
import gleeunit/should
import qcheck
import qcheck/util.{given}

pub fn opt_test() {
  use #(name, value) <- given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.string_non_empty(),
  ))

  let command = clip.opt(opt.new(name), clip.pure)

  clip.run(command, ["--" <> name, value])
  |> should.equal(Ok(value))

  clip.run(command, [])
  |> should.equal(Error("missing required arg: --" <> name))
}

pub fn try_map_test() {
  use #(name, value) <- given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.small_positive_or_zero_int(),
  ))

  clip.opt(
    opt.new(name)
      |> opt.try_map(fn(s) {
        case int.parse(s) {
          Ok(n) -> Ok(n)
          Error(Nil) -> Error("Bad int")
        }
      }),
    clip.pure,
  )
  |> clip.run(["--" <> name, int.to_string(value)])
  |> should.equal(Ok(value))
}

pub fn map_test() {
  use #(name, value) <- given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.string_non_empty(),
  ))

  clip.opt(
    opt.new(name)
      |> opt.map(string.uppercase),
    clip.pure,
  )
  |> clip.run(["--" <> name, value])
  |> should.equal(Ok(string.uppercase(value)))
}

pub fn optional_test() {
  use #(name, value) <- given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.string_non_empty(),
  ))

  let command = clip.opt(opt.new(name) |> opt.optional, clip.pure)

  clip.run(command, ["--" <> name, value])
  |> should.equal(Ok(Ok(value)))

  clip.run(command, [])
  |> should.equal(Ok(Error(Nil)))
}

pub fn default_test() {
  use #(name, value, default) <- given(qcheck.tuple3(
    qcheck.string_non_empty(),
    qcheck.string_non_empty(),
    qcheck.string_non_empty(),
  ))

  let command = clip.opt(opt.new(name) |> opt.default(default), clip.pure)

  clip.run(command, ["--" <> name, value])
  |> should.equal(Ok(value))

  clip.run(command, [])
  |> should.equal(Ok(default))
}

pub fn int_test() {
  use #(name, value) <- given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.small_positive_or_zero_int(),
  ))

  clip.opt(opt.new(name) |> opt.int, clip.pure)
  |> clip.run(["--" <> name, int.to_string(value)])
  |> should.equal(Ok(value))
}

pub fn float_test() {
  use #(name, value) <- given(qcheck.tuple2(
    qcheck.string_non_empty(),
    qcheck.float(),
  ))

  clip.opt(opt.new(name) |> opt.float, clip.pure)
  |> clip.run(["--" <> name, float.to_string(value)])
  |> should.equal(Ok(value))
}

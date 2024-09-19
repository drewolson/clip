import clip
import clip/flag
import gleeunit/should
import qcheck/util.{clip_string, given}

pub fn flag_test() {
  use value <- given(clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new(value))

  clip.run(command, ["--" <> value])
  |> should.equal(Ok(True))

  clip.run(command, [])
  |> should.equal(Ok(False))
}

pub fn short_test() {
  use value <- given(clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new("flag") |> flag.short(value))

  clip.run(command, ["-" <> value])
  |> should.equal(Ok(True))

  clip.run(command, [])
  |> should.equal(Ok(False))
}

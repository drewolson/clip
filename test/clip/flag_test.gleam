import clip
import clip/flag
import qcheck
import test_helper/gen

pub fn flag_test() {
  use value <- qcheck.given(gen.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new(value))

  assert clip.run(command, ["--" <> value]) == Ok(True)

  assert clip.run(command, []) == Ok(False)
}

pub fn short_test() {
  use value <- qcheck.given(gen.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new("flag") |> flag.short(value))

  assert clip.run(command, ["-" <> value]) == Ok(True)

  assert clip.run(command, []) == Ok(False)
}

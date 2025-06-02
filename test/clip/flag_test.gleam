import clip
import clip/flag
import qcheck
import test_helper/qcheck_util

pub fn flag_test() {
  use value <- qcheck.given(qcheck_util.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new(value))

  assert clip.run(command, ["--" <> value]) == Ok(True)

  assert clip.run(command, []) == Ok(False)
}

pub fn short_test() {
  use value <- qcheck.given(qcheck_util.clip_string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new("flag") |> flag.short(value))

  assert clip.run(command, ["-" <> value]) == Ok(True)

  assert clip.run(command, []) == Ok(False)
}

import clip
import clip/flag
import qcheck/generator
import qcheck/qtest

pub fn flag_test() {
  use value <- qtest.given(generator.string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new(value))

  let a = clip.run(command, ["--" <> value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(True), Ok(False))
}

pub fn short_test() {
  use value <- qtest.given(generator.string())

  let command =
    clip.command(fn(a) { a })
    |> clip.flag(flag.new("flag") |> flag.short(value))

  let a = clip.run(command, ["-" <> value])
  let b = clip.run(command, [])

  #(a, b) == #(Ok(True), Ok(False))
}

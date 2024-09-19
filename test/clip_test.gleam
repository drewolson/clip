import clip
import clip/arg
import clip/flag
import clip/opt
import gleam/list
import gleeunit
import gleeunit/should
import qcheck
import qcheck/util.{clip_string, given}

pub fn main() {
  gleeunit.main()
}

pub fn complex_command_test() {
  let result =
    clip.command(fn(a) { fn(b) { fn(c) { fn(d) { #(a, b, c, d) } } } })
    |> clip.opt(opt.new("a"))
    |> clip.flag(flag.new("b"))
    |> clip.arg(arg.new("c"))
    |> clip.arg_many(arg.new("d"))
    |> clip.run(["--a", "a", "--b", "c", "d", "e", "f"])

  result
  |> should.equal(Ok(#("a", True, "c", ["d", "e", "f"])))
}

pub fn opt_and_flag_order_does_not_matter_test() {
  let argv =
    [["--a", "a"], ["--b"], ["c", "d", "e", "f"]] |> list.shuffle |> list.concat

  let result =
    clip.command(fn(a) { fn(b) { fn(c) { fn(d) { #(a, b, c, d) } } } })
    |> clip.opt(opt.new("a"))
    |> clip.flag(flag.new("b"))
    |> clip.arg(arg.new("c"))
    |> clip.arg_many(arg.new("d"))
    |> clip.run(argv)

  result
  |> should.equal(Ok(#("a", True, "c", ["d", "e", "f"])))
}

pub fn arg_many_accepts_all_after_double_dash_test() {
  use #(first, rest) <- given(qcheck.tuple2(
    clip_string(),
    qcheck.list_generic(qcheck.string_non_empty(), 2, 5),
  ))

  let result =
    clip.command(fn(a) { fn(b) { #(a, b) } })
    |> clip.opt(opt.new("a"))
    |> clip.arg_many(arg.new("b"))
    |> clip.run(["--a", first, "--", ..rest])

  result
  |> should.equal(Ok(#(first, rest)))
}

pub fn subcommands_test() {
  let command =
    clip.subcommands([
      #("a", clip.command(fn(a) { a }) |> clip.opt(opt.new("a"))),
      #("b", clip.command(fn(a) { a }) |> clip.opt(opt.new("b"))),
      #("c", clip.command(fn(a) { a }) |> clip.opt(opt.new("c"))),
    ])

  command
  |> clip.run(["a", "--a", "first"])
  |> should.equal(Ok("first"))

  command
  |> clip.run(["b", "--b", "second"])
  |> should.equal(Ok("second"))

  command
  |> clip.run(["c", "--c", "third"])
  |> should.equal(Ok("third"))
}

pub fn subcommands_with_default_test() {
  let command =
    clip.subcommands_with_default(
      [
        #("a", clip.command(fn(a) { a }) |> clip.opt(opt.new("a"))),
        #("b", clip.command(fn(a) { a }) |> clip.opt(opt.new("b"))),
      ],
      clip.command(fn(a) { a }) |> clip.opt(opt.new("c")),
    )

  command
  |> clip.run(["a", "--a", "first"])
  |> should.equal(Ok("first"))

  command
  |> clip.run(["b", "--b", "second"])
  |> should.equal(Ok("second"))

  command
  |> clip.run(["--c", "third"])
  |> should.equal(Ok("third"))
}

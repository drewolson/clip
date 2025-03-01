import clip
import clip/arg
import clip/flag
import clip/opt
import gleam/list
import gleeunit
import gleeunit/should
import qcheck
import test_helper/qcheck_util

pub fn main() {
  gleeunit.main()
}

pub fn complex_command_test() {
  use #(a, c, d, e, f) <- qcheck.given(qcheck.tuple5(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let result =
    clip.command({
      use a <- clip.parameter
      use b <- clip.parameter
      use c <- clip.parameter
      use d <- clip.parameter
      #(a, b, c, d)
    })
    |> clip.opt(opt.new("a"))
    |> clip.flag(flag.new("b"))
    |> clip.arg(arg.new("c"))
    |> clip.arg_many(arg.new("d"))
    |> clip.run(["--a", a, "--b", c, d, e, f])

  result
  |> should.equal(Ok(#(a, True, c, [d, e, f])))
}

pub fn opt_and_flag_order_does_not_matter_test() {
  use #(a, c, d, e, f) <- qcheck.given(qcheck.tuple5(
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
    qcheck_util.clip_string(),
  ))

  let argv =
    [["--a", a], ["--b"], [c, d, e, f]]
    |> list.shuffle
    |> list.flatten

  let result =
    clip.command(fn(a) { fn(b) { fn(c) { fn(d) { #(a, b, c, d) } } } })
    |> clip.opt(opt.new("a"))
    |> clip.flag(flag.new("b"))
    |> clip.arg(arg.new("c"))
    |> clip.arg_many(arg.new("d"))
    |> clip.run(argv)

  result
  |> should.equal(Ok(#(a, True, c, [d, e, f])))
}

pub fn arg_many_accepts_all_after_double_dash_test() {
  use #(first, rest) <- qcheck.given(qcheck.tuple2(
    qcheck_util.clip_string(),
    qcheck.generic_list(qcheck.non_empty_string(), qcheck.bounded_int(2, 5)),
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
  use val <- qcheck.given(qcheck_util.clip_string())

  let command =
    clip.subcommands([
      #("a", clip.command(fn(a) { a }) |> clip.opt(opt.new("a"))),
      #("b", clip.command(fn(a) { a }) |> clip.opt(opt.new("b"))),
      #("c", clip.command(fn(a) { a }) |> clip.opt(opt.new("c"))),
    ])

  command
  |> clip.run(["a", "--a", val])
  |> should.equal(Ok(val))

  command
  |> clip.run(["b", "--b", val])
  |> should.equal(Ok(val))

  command
  |> clip.run(["c", "--c", val])
  |> should.equal(Ok(val))
}

pub fn subcommands_with_default_test() {
  use val <- qcheck.given(qcheck_util.clip_string())

  let command =
    clip.subcommands_with_default(
      [
        #("a", clip.command(fn(a) { a }) |> clip.opt(opt.new("a"))),
        #("b", clip.command(fn(a) { a }) |> clip.opt(opt.new("b"))),
      ],
      clip.command(fn(a) { a }) |> clip.opt(opt.new("c")),
    )

  command
  |> clip.run(["a", "--a", val])
  |> should.equal(Ok(val))

  command
  |> clip.run(["b", "--b", val])
  |> should.equal(Ok(val))

  command
  |> clip.run(["--c", val])
  |> should.equal(Ok(val))
}

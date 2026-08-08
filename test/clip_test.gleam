import clip
import clip/arg
import clip/flag
import clip/opt
import gleam/list
import gleeunit
import qcheck
import test_helper/gen

pub fn main() {
  gleeunit.main()
}

pub fn complex_command_test() {
  use #(a, c, d, e, f) <- qcheck.given(qcheck.tuple5(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
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

  assert result == Ok(#(a, True, c, [d, e, f]))
}

pub fn complex_parse_test() {
  use #(a, c, d, e, f) <- qcheck.given(qcheck.tuple5(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
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
    |> clip.parse(["--a", a, "--b", c, d, e, f])

  assert result == Ok(#(#(a, True, c, [d, e, f]), []))
}

pub fn parse_with_unparsed_arguments_test() {
  use #(a, b, c) <- qcheck.given(qcheck.tuple3(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command({
      use a <- clip.parameter
      use b <- clip.parameter

      #(a, b)
    })
    |> clip.opt(opt.new("a"))
    |> clip.opt(opt.new("b"))
    |> clip.parse(["--a", a, "--b", b, "--c", c])

  assert result == Ok(#(#(a, b), ["--c", c]))
}

pub fn opt_and_flag_order_does_not_matter_test() {
  use #(a, c, d, e, f) <- qcheck.given(qcheck.tuple5(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
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

  assert result == Ok(#(a, True, c, [d, e, f]))
}

pub fn arg_many_accepts_all_after_double_dash_test() {
  use #(first, rest) <- qcheck.given(qcheck.tuple2(
    gen.clip_string(),
    qcheck.generic_list(qcheck.non_empty_string(), qcheck.bounded_int(2, 5)),
  ))

  let result =
    clip.command(fn(a) { fn(b) { #(a, b) } })
    |> clip.opt(opt.new("a"))
    |> clip.arg_many(arg.new("b"))
    |> clip.run(["--a", first, "--", ..rest])

  assert result == Ok(#(first, rest))
}

pub fn opt_declared_after_arg_does_not_capture_positional_value_test() {
  use #(name, named, positional) <- qcheck.given(qcheck.tuple3(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command2()
    |> clip.arg(arg.new("positional"))
    |> clip.opt(opt.new(name))
    |> clip.run(["--" <> name, named, positional])

  assert result == Ok(#(positional, named))
}

pub fn short_opt_declared_after_arg_does_not_capture_positional_value_test() {
  use #(short, named, positional) <- qcheck.given(qcheck.tuple3(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command2()
    |> clip.arg(arg.new("positional"))
    |> clip.opt(opt.new("name") |> opt.short(short))
    |> clip.run(["-" <> short, named, positional])

  assert result == Ok(#(positional, named))
}

pub fn flag_declared_after_arg_does_not_capture_positional_value_test() {
  use #(name, positional) <- qcheck.given(qcheck.tuple2(
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command2()
    |> clip.arg(arg.new("positional"))
    |> clip.flag(flag.new(name))
    |> clip.run(["--" <> name, positional])

  assert result == Ok(#(positional, True))
}

pub fn opt_declared_after_arg_many_does_not_capture_positional_values_test() {
  use #(name, named, positional) <- qcheck.given(qcheck.tuple3(
    gen.clip_string(),
    gen.clip_string(),
    qcheck.generic_list(gen.clip_string(), qcheck.bounded_int(1, 5)),
  ))

  let result =
    clip.command2()
    |> clip.arg_many(arg.new("positional"))
    |> clip.opt(opt.new(name))
    |> clip.run(["--" <> name, named, ..positional])

  assert result == Ok(#(positional, named))
}

pub fn named_args_are_positional_after_double_dash_test() {
  use #(named, positional) <- qcheck.given(qcheck.tuple2(
    gen.clip_string(),
    gen.clip_string(),
  ))

  let args = ["--name", named, "--flag", positional]
  let result =
    clip.command3()
    |> clip.opt(opt.new("name") |> opt.default("default"))
    |> clip.flag(flag.new("flag"))
    |> clip.arg_many(arg.new("rest"))
    |> clip.run(["--", ..args])

  assert result == Ok(#("default", False, args))
}

pub fn parse_does_not_leave_double_dash_test() {
  use positional <- qcheck.given(gen.clip_string())

  let result =
    clip.command1()
    |> clip.arg(arg.new("positional"))
    |> clip.parse(["--", "-" <> positional])

  assert result == Ok(#("-" <> positional, []))
}

pub fn unknown_named_arg_is_left_unparsed_test() {
  use #(name, positional) <- qcheck.given(qcheck.tuple2(
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command1()
    |> clip.arg(arg.new("positional"))
    |> clip.parse(["--" <> name, positional])

  assert result == Ok(#(positional, ["--" <> name]))
}

pub fn command1_test() {
  use a <- qcheck.given(gen.clip_string())

  let result =
    clip.command1()
    |> clip.opt(opt.new("a"))
    |> clip.run(["--a", a])

  assert result == Ok(a)
}

pub fn command2_test() {
  use #(a, b) <- qcheck.given(qcheck.tuple2(
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command2()
    |> clip.opt(opt.new("a"))
    |> clip.opt(opt.new("b"))
    |> clip.run(["--a", a, "--b", b])

  assert result == Ok(#(a, b))
}

pub fn command3_test() {
  use #(a, b, c) <- qcheck.given(qcheck.tuple3(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command3()
    |> clip.opt(opt.new("a"))
    |> clip.opt(opt.new("b"))
    |> clip.opt(opt.new("c"))
    |> clip.run(["--a", a, "--b", b, "--c", c])

  assert result == Ok(#(a, b, c))
}

pub fn command4_test() {
  use #(a, b, c, d) <- qcheck.given(qcheck.tuple4(
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
    gen.clip_string(),
  ))

  let result =
    clip.command4()
    |> clip.opt(opt.new("a"))
    |> clip.opt(opt.new("b"))
    |> clip.opt(opt.new("c"))
    |> clip.opt(opt.new("d"))
    |> clip.run(["--a", a, "--b", b, "--c", c, "--d", d])

  assert result == Ok(#(a, b, c, d))
}

pub fn subcommands_test() {
  use val <- qcheck.given(gen.clip_string())

  let command =
    clip.subcommands([
      #("a", clip.command(fn(a) { a }) |> clip.opt(opt.new("a"))),
      #("b", clip.command(fn(a) { a }) |> clip.opt(opt.new("b"))),
      #("c", clip.command(fn(a) { a }) |> clip.opt(opt.new("c"))),
    ])

  assert clip.run(command, ["a", "--a", val]) == Ok(val)

  assert clip.run(command, ["b", "--b", val]) == Ok(val)

  assert clip.run(command, ["c", "--c", val]) == Ok(val)
}

pub fn subcommands_with_default_test() {
  use val <- qcheck.given(gen.clip_string())

  let command =
    clip.subcommands_with_default(
      [
        #("a", clip.command(fn(a) { a }) |> clip.opt(opt.new("a"))),
        #("b", clip.command(fn(a) { a }) |> clip.opt(opt.new("b"))),
      ],
      clip.command(fn(a) { a }) |> clip.opt(opt.new("c")),
    )

  assert clip.run(command, ["a", "--a", val]) == Ok(val)

  assert clip.run(command, ["b", "--b", val]) == Ok(val)

  assert clip.run(command, ["--c", val]) == Ok(val)
}

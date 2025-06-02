import clip
import clip/arg
import clip/flag
import clip/help
import clip/opt

pub fn complex_command_help_test() {
  let expected =
    "complex

  complex command

Usage:

  complex [OPTIONS] C [D...] E...

Arguments:

  C          \t
  [D...]     \tZero or more
  E...       \tOne or more

Options:

  (--a A)    \t
  [--b]      \t
  [--help,-h]\tPrint this help"

  let result =
    clip.command(fn(a) {
      fn(b) { fn(c) { fn(d) { fn(e) { #(a, b, c, d, e) } } } }
    })
    |> clip.opt(opt.new("a"))
    |> clip.flag(flag.new("b"))
    |> clip.arg(arg.new("c"))
    |> clip.arg_many(arg.new("d"))
    |> clip.arg_many1(arg.new("e"))
    |> clip.help(help.simple("complex", "complex command"))
    |> clip.run(["--help"])

  assert result == Error(expected)
}

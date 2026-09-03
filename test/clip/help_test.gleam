import birdie
import clip
import clip/arg
import clip/flag
import clip/help
import clip/opt
import gleam/string

pub fn complex_command_help_test() {
  let assert Error(help) =
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

  birdie.snap(help, title: "complex_command_help_test")
}

pub fn help_anywhere_in_args_test() {
  let command =
    clip.command2()
    |> clip.opt(opt.new("name"))
    |> clip.arg(arg.new("pos"))
    |> clip.help(help.simple("test_cmd", "Test description"))

  let assert Error(help1) = clip.run(command, ["--name", "val", "--help"])
  let assert Error(help2) = clip.run(command, ["--name", "val", "-h"])
  let assert Error(help3) = clip.run(command, ["pos_val", "--help"])
  let assert Error(help4) = clip.run(command, ["--help"])

  assert help1 == help4
  assert help2 == help4
  assert help3 == help4
}

pub fn help_subcommand_test() {
  let sub =
    clip.command1()
    |> clip.opt(opt.new("foo"))
    |> clip.help(help.simple("sub", "Subcommand description"))

  let parent =
    clip.subcommands([#("sub", sub)])
    |> clip.help(help.simple("parent", "Parent description"))

  let assert Error(parent_help) = clip.run(parent, ["--help"])
  assert string.contains(parent_help, "Parent description")

  let assert Error(sub_help1) = clip.run(parent, ["sub", "--help"])
  assert string.contains(sub_help1, "Subcommand description")

  let assert Error(sub_help2) =
    clip.run(parent, ["sub", "--foo", "bar", "--help"])
  assert string.contains(sub_help2, "Subcommand description")
}

pub fn help_after_double_dash_is_positional_test() {
  let command =
    clip.command1()
    |> clip.arg(arg.new("pos"))
    |> clip.help(help.simple("test_cmd", "Test description"))

  assert clip.run(command, ["--", "--help"]) == Ok("--help")
  assert clip.run(command, ["--", "-h"]) == Ok("-h")
}

pub fn optional_help_rendering_test() {
  let command =
    clip.command2()
    |> clip.opt(opt.new("name") |> opt.help("Your name") |> opt.optional)
    |> clip.arg(arg.new("file") |> arg.help("Target file") |> arg.optional)
    |> clip.help(help.simple("opt_test", "Optional args description"))

  let assert Error(help) = clip.run(command, ["--help"])

  assert !string.contains(help, "Error(Nil)")
  assert string.contains(help, "[FILE]")
  assert string.contains(help, "[--name NAME]")
}

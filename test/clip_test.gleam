import clip
import clip/arg
import clip/flag
import clip/opt
import gleam/list
import gleeunit
import gleeunit/should

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

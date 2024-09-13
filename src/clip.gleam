//// Functions for building `Command`s.

import clip/arg.{type Arg}
import clip/flag.{type Flag}
import clip/internal/aliases.{type Args, type ArgsFn, type FnResult}
import clip/internal/arg_info.{type ArgInfo, ArgInfo, FlagInfo}
import clip/opt.{type Opt}
import gleam/list
import gleam/option.{Some}
import gleam/result

pub opaque type Command(a) {
  Command(info: ArgInfo, f: ArgsFn(a))
}

/// The `pure` function takes a value `a` and produces a `Command` that, when /
/// run, produces `a`. You shouldn't call this function directly, but rather use
/// `clip.command`.
///
/// ```gleam
///  clip.pure(1) |> clip.run(["whatever"]) |> string.inspect
///
///  // Ok(1)
/// ```
pub fn pure(val: a) -> Command(a) {
  Command(info: arg_info.empty(), f: fn(args) { Ok(#(val, args)) })
}

/// Don't call this function directly. Rather, call `cli.opt`, `clip.flag`, or
/// `clip.arg`.
pub fn apply(mf: Command(fn(a) -> b), ma: Command(a)) -> Command(b) {
  Command(info: arg_info.merge(mf.info, ma.info), f: fn(args) {
    use #(f, args1) <- result.try(mf.f(args))
    use #(a, args2) <- result.try(ma.f(args1))
    Ok(#(f(a), args2))
  })
}

/// The `command` function is use to start building a parser. You provided a
/// curried function and then provide arguments to be supplied to that function.
///
/// ```gleam
/// clip.command(fn(a) { fn(b) { #(a, b) } })
/// |> clip.opt(opt.new("first"))
/// |> clip.opt(opt.new("second"))
/// |> clip.run(["--first", "foo", "--second", "bar"])
/// |> string.inspect
///
/// // Ok(#("foo", "bar"))
/// ```
pub fn command(f: fn(a) -> b) -> Command(fn(a) -> b) {
  pure(f)
}

/// Creates a `Command` that always produces `Error(message)` when run.
pub fn fail(message: String) -> Command(a) {
  Command(info: arg_info.empty(), f: fn(_args) { Error(message) })
}

/// Parse an option built using the `clip/opt` module and provide it to a
/// `Command` function build using `clip.command()`
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.opt(opt.new("first"))
/// |> clip.run(["--first", "foo"])
/// |> string.inspect
///
/// // Ok("foo")
/// ```
pub fn opt(command: Command(fn(a) -> b), opt: Opt(a)) -> Command(b) {
  apply(command, Command(info: opt.to_arg_info(opt), f: opt.run(opt, _)))
}

/// Parse the next positional argument built using the `clip/arg` module and
/// provide it to a `Command` function build using `clip.command()`
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.arg(arg.new("foo"))
/// |> clip.run(["foo"])
/// |> string.inspect
///
/// // Ok("foo")
/// ```
pub fn arg(command: Command(fn(a) -> b), arg: Arg(a)) -> Command(b) {
  apply(command, Command(info: arg.to_arg_info(arg), f: arg.run(arg, _)))
}

/// Parse the next zero or more positional arguments built using the `clip/arg`
/// module and provide them as a `List` to a `Command` function build using
/// `clip.command()`. `arg_many` is greedy, parsing as many options as possible
/// until parsing fails. If zero values are parsed successfuly, an empty
/// `List` is provided.
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.arg_many(arg.new("foo"))
/// |> clip.run(["foo", "bar", "baz"])
/// |> string.inspect
///
/// // Ok(["foo", "bar", "baz"])
/// ```
pub fn arg_many(command: Command(fn(List(a)) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info_many(arg), f: arg.run_many(arg, _)),
  )
}

/// Parse the next one or more positional arguments built using the `clip/arg`
/// module and provide them as a `List` to a `Command` function build using
/// `clip.command()`. `arg_many` is greedy, parsing as many options as possible
/// until parsing fails. Parsing fails if zero values are parsed successfully.
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.arg_many1(arg.new("foo"))
/// |> clip.run(["foo", "bar", "baz"])
/// |> string.inspect
///
/// // Ok(["foo", "bar", "baz"])
/// ```
pub fn arg_many1(command: Command(fn(List(a)) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info_many1(arg), f: arg.run_many1(arg, _)),
  )
}

/// Parse a flag built using the `clip/flag` module and provide it to a
/// `Command` function build using `clip.command()`
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.flag(flag.new("foo"))
/// |> clip.run(["--foo"])
/// |> string.inspect
///
/// // Ok(True)
/// ```
pub fn flag(command: Command(fn(Bool) -> b), flag: Flag) -> Command(b) {
  apply(command, Command(info: flag.to_arg_info(flag), f: flag.run(flag, _)))
}

fn run_subcommands(
  subcommands: List(#(String, Command(a))),
  default: Command(a),
  args: Args,
) -> FnResult(a) {
  case subcommands, args {
    [#(name, command), ..], [head, ..rest] if name == head -> command.f(rest)
    [_, ..rest], _ -> run_subcommands(rest, default, args)
    [], _ -> default.f(args)
  }
}

/// Build a command with subcommands and a default top-level command if no
/// subcommand matches. This is an advanced use case, see the examples directory
/// for more help.
pub fn subcommands_with_default(
  subcommands: List(#(String, Command(a))),
  default: Command(a),
) -> Command(a) {
  let sub_names = list.map(subcommands, fn(p) { p.0 })
  let sub_arg_info = ArgInfo(..default.info, subcommands: sub_names)
  apply(
    pure(fn(a) { a }),
    Command(info: sub_arg_info, f: run_subcommands(subcommands, default, _)),
  )
}

/// Build a command with subcommands. This is an advanced use case, see the
/// examples directory for more help.
pub fn subcommands(subcommands: List(#(String, Command(a)))) -> Command(a) {
  subcommands_with_default(subcommands, fail("No subcommand provided"))
}

/// Add the help (`-h`, `--help`) flags to your program to display usage help
/// to the user. The provided `name` and `description` will be used to generate
/// the help text.
pub fn add_help(
  command: Command(a),
  name: String,
  description: String,
) -> Command(a) {
  let help_info =
    ArgInfo(
      ..arg_info.empty(),
      flags: [
        FlagInfo(name: "help", short: Some("h"), help: Some("Print this help")),
      ],
    )
  Command(
    ..command,
    f: fn(args) {
      case args {
        ["-h", ..] | ["--help", ..] ->
          Error(arg_info.help_text(
            arg_info.merge(command.info, help_info),
            name,
            description,
          ))
        other -> command.f(other)
      }
    },
  )
}

/// Run a command. Running a `Command(a)` will return either `Ok(a)` or an
/// `Error(String)`. The `Error` value is intended to be printed to the user.
pub fn run(command: Command(a), args: List(String)) -> Result(a, String) {
  case command.f(args) {
    Ok(#(a, _)) -> Ok(a)
    Error(e) -> Error(e)
  }
}

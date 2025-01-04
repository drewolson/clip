//// Functions for building and running `Command`s.

import clip/arg.{type Arg}
import clip/arg_info.{type ArgInfo, ArgInfo, FlagInfo}
import clip/flag.{type Flag}
import clip/help.{type Help}
import clip/internal/aliases.{type Args, type ArgsFn, type FnResult}
import clip/opt.{type Opt}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

pub opaque type Command(a) {
  Command(info: ArgInfo, help: Option(Help), f: ArgsFn(a))
}

/// The `return` function takes a value `val` and produces a `Command` that, when
/// run, produces `val`. You should only call this function directly when your
/// command doesn't require any arguments. Otherwise, use `clip.command`.
///
/// ```gleam
/// clip.return(1) |> clip.run(["whatever"])
///
/// // Ok(1)
/// ```
///
/// See the [subcommand example](https://github.com/drewolson/clip/tree/main/examples/subcommand)
/// for idiomatic usage of `return`.
pub fn return(val: a) -> Command(a) {
  Command(info: arg_info.empty(), help: None, f: fn(args) { Ok(#(val, args)) })
}

/// The `parameter` function provides an alternative syntax for building curried
/// functions. The following two code blocks are equivalent:
///
/// ```gleam
/// fn(a) {
///   fn(b) {
///     thing(a, b)
///   }
/// }
/// ```
///
/// ```gleam
/// {
///   use a <- clip.parameter
///   use b <- clip.parameter
///
///   thing(a, b)
/// }
/// ```
///
/// You can use either style when calling `clip.command`. See the
/// [parameter syntax example](https://github.com/drewolson/clip/tree/main/examples/parameter-syntax)
/// for more details.
pub fn parameter(f: fn(a) -> b) -> fn(a) -> b {
  f
}

/// Don't call this function directly. Rather, call `cli.opt`, `clip.flag`,
/// `clip.arg`, `clip.arg_many`, or `clip.arg_many1`.
pub fn apply(mf: Command(fn(a) -> b), ma: Command(a)) -> Command(b) {
  Command(
    info: arg_info.merge(mf.info, ma.info),
    help: option.or(mf.help, ma.help),
    f: fn(args) {
      use #(f, args1) <- result.try(mf.f(args))
      use #(a, args2) <- result.try(ma.f(args1))
      Ok(#(f(a), args2))
    },
  )
}

/// The `command` function is use to start building a parser. You provide a
/// curried function and then provide arguments to be supplied to that function.
///
/// ```gleam
/// clip.command({
///   use a <- clip.parameter
///   use b <- clip.parameter
///
///   #(a, b)
/// })
/// |> clip.opt(opt.new("first"))
/// |> clip.opt(opt.new("second"))
/// |> clip.run(["--first", "foo", "--second", "bar"])
///
/// // Ok(#("foo", "bar"))
/// ```
pub fn command(f: fn(a) -> b) -> Command(fn(a) -> b) {
  return(f)
}

/// Creates a `Command` that always produces `Error(message)` when run.
pub fn fail(message: String) -> Command(a) {
  Command(info: arg_info.empty(), help: None, f: fn(_args) { Error(message) })
}

/// Parse an option built using the `clip/opt` module and provide it to a
/// `Command` function build using `clip.command()`
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.opt(opt.new("first"))
/// |> clip.run(["--first", "foo"])
///
/// // Ok("foo")
/// ```
pub fn opt(command: Command(fn(a) -> b), opt: Opt(a)) -> Command(b) {
  apply(
    command,
    Command(info: opt.to_arg_info(opt), help: None, f: opt.run(opt, _)),
  )
}

/// Parse the next positional argument built using the `clip/arg` module and
/// provide it to a `Command` function build using `clip.command()`
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.arg(arg.new("foo"))
/// |> clip.run(["foo"])
///
/// // Ok("foo")
/// ```
///
/// `arg` will not attempt to parse options starting with `-` unless the
/// special `--` value has been previously passed or the option is a negative
/// integer or float.
pub fn arg(command: Command(fn(a) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info(arg), help: None, f: arg.run(arg, _)),
  )
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
///
/// // Ok(["foo", "bar", "baz"])
/// ```
///
/// `arg_many` will not attempt to parse options starting with `-` unless the
/// special `--` value has been previously passed or the option is a negative
/// integer or float.
pub fn arg_many(command: Command(fn(List(a)) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info_many(arg), help: None, f: arg.run_many(arg, _)),
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
///
/// // Ok(["foo", "bar", "baz"])
/// ```
///
/// `arg_many1` will not attempt to parse options starting with `-` unless the
/// special `--` value has been previously passed or the option is a negative
/// integer or float.
pub fn arg_many1(command: Command(fn(List(a)) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info_many1(arg), help: None, f: arg.run_many1(
      arg,
      _,
    )),
  )
}

/// Parse a flag built using the `clip/flag` module and provide it to a
/// `Command` function build using `clip.command()`
///
/// ```gleam
/// clip.command(fn(a) { a })
/// |> clip.flag(flag.new("foo"))
/// |> clip.run(["--foo"])
///
/// // Ok(True)
/// ```
pub fn flag(command: Command(fn(Bool) -> b), flag: Flag) -> Command(b) {
  apply(
    command,
    Command(info: flag.to_arg_info(flag), help: None, f: flag.run(flag, _)),
  )
}

fn run_subcommands(
  subcommands: List(#(String, Command(a))),
  default: Command(a),
  args: Args,
) -> FnResult(a) {
  case subcommands, args {
    [#(name, command), ..], [head, ..rest] if name == head ->
      run_aux(command, rest)
    [_, ..rest], _ -> run_subcommands(rest, default, args)
    [], _ -> run_aux(default, args)
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
    return(fn(a) { a }),
    Command(info: sub_arg_info, help: None, f: run_subcommands(
      subcommands,
      default,
      _,
    )),
  )
}

/// Build a command with subcommands. This is an advanced use case, see the
/// examples directory for more help.
pub fn subcommands(subcommands: List(#(String, Command(a)))) -> Command(a) {
  subcommands_with_default(subcommands, fail("No subcommand provided"))
}

/// Add the help (`-h`, `--help`) flags to your program to display usage help
/// to the user. See the `clip/help` module for producing simple and custom help
/// text.
pub fn help(command: Command(a), help: Help) -> Command(a) {
  Command(..command, help: Some(help))
}

fn wrap_help(command: Command(a), help: Help) -> ArgsFn(a) {
  let help_info =
    ArgInfo(..arg_info.empty(), flags: [
      FlagInfo(name: "help", short: Some("h"), help: Some("Print this help")),
    ])

  fn(args) {
    case args {
      ["-h", ..] | ["--help", ..] ->
        Error(help.run(help, arg_info.merge(command.info, help_info)))
      other -> command.f(other)
    }
  }
}

fn run_aux(command: Command(a), args: List(String)) -> FnResult(a) {
  let f = case command.help {
    None -> command.f
    Some(help) -> wrap_help(command, help)
  }

  f(args)
}

/// Run a command. Running a `Command(a)` will return either `Ok(a)` or an
/// `Error(String)`. The `Error` value is intended to be printed to the user.
pub fn run(command: Command(a), args: List(String)) -> Result(a, String) {
  case run_aux(command, args) {
    Ok(#(a, _)) -> Ok(a)
    Error(e) -> Error(e)
  }
}

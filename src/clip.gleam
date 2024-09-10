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

pub fn pure(val: a) -> Command(a) {
  Command(info: arg_info.empty(), f: fn(args) { Ok(#(val, args)) })
}

pub fn apply(mf: Command(fn(a) -> b), ma: Command(a)) -> Command(b) {
  Command(info: arg_info.merge(mf.info, ma.info), f: fn(args) {
    use #(f, args1) <- result.try(mf.f(args))
    use #(a, args2) <- result.try(ma.f(args1))
    Ok(#(f(a), args2))
  })
}

pub fn command(f: fn(a) -> b) -> Command(fn(a) -> b) {
  pure(f)
}

pub fn fail(message: String) -> Command(a) {
  Command(info: arg_info.empty(), f: fn(_args) { Error(message) })
}

pub fn opt(command: Command(fn(a) -> b), opt: Opt(a)) -> Command(b) {
  apply(command, Command(info: opt.to_arg_info(opt), f: opt.run(opt, _)))
}

pub fn arg(command: Command(fn(a) -> b), arg: Arg(a)) -> Command(b) {
  apply(command, Command(info: arg.to_arg_info(arg), f: arg.run(arg, _)))
}

pub fn arg_many(command: Command(fn(List(a)) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info_many(arg), f: arg.run_many(arg, _)),
  )
}

pub fn arg_many1(command: Command(fn(List(a)) -> b), arg: Arg(a)) -> Command(b) {
  apply(
    command,
    Command(info: arg.to_arg_info_many1(arg), f: arg.run_many1(arg, _)),
  )
}

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

pub fn subcommands(subcommands: List(#(String, Command(a)))) -> Command(a) {
  subcommands_with_default(subcommands, fail("No subcommand provided"))
}

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

pub fn run(command: Command(a), args: List(String)) -> Result(a, String) {
  case command.f(args) {
    Ok(#(a, _)) -> Ok(a)
    Error(e) -> Error(e)
  }
}

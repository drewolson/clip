import clip/internal/aliases.{type Args, type FnResult}
import clip/internal/arg_info.{type ArgInfo, ArgInfo, FlagInfo}
import gleam/option.{type Option, None, Some}
import gleam/result

pub opaque type Flag {
  Flag(name: String, help: Option(String), short: Option(String))
}

pub fn to_arg_info(flag: Flag) -> ArgInfo {
  ArgInfo(
    ..arg_info.empty(),
    flags: [FlagInfo(name: flag.name, short: flag.short, help: flag.help)],
  )
}

pub fn help(flag: Flag, help: String) -> Flag {
  Flag(..flag, help: Some(help))
}

pub fn new(name: String) -> Flag {
  Flag(name:, help: None, short: None)
}

pub fn short(flag: Flag, short: String) -> Flag {
  Flag(..flag, short: Some(short))
}

pub fn run(flag: Flag, args: Args) -> FnResult(Bool) {
  let long_name = "--" <> flag.name
  let short_name = option.map(flag.short, fn(s) { "-" <> s })
  case args {
    [] -> Ok(#(False, []))
    [head, ..rest] if long_name == head || short_name == Some(head) -> {
      Ok(#(True, rest))
    }
    [head, ..rest] ->
      run(flag, rest)
      |> result.map(fn(v) { #(v.0, [head, ..v.1]) })
  }
}

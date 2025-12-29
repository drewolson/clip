//// Functions for building `Flag`s. A `Flag` is a named option with no
//// associated value, such as `--debug`. A `Flag` produces `True` when present
//// and `False` when not present.

import clip/arg_info.{type ArgInfo, ArgInfo, FlagInfo}
import gleam/option.{type Option, None, Some}
import gleam/result

pub opaque type Flag {
  Flag(name: String, help: Option(String), short: Option(String))
}

@internal
pub fn to_arg_info(flag: Flag) -> ArgInfo {
  ArgInfo(..arg_info.empty(), flags: [
    FlagInfo(name: flag.name, short: flag.short, help: flag.help),
  ])
}

/// Add help text to a `Flag`.
pub fn help(flag: Flag, help: String) -> Flag {
  Flag(..flag, help: Some(help))
}

/// Create a new `Flag` with the provided name. `Flag`s always produce a `Bool`
/// -- `True` if present and `False` if not present.
pub fn new(name: String) -> Flag {
  Flag(name:, help: None, short: None)
}

/// Add a short name for the given `Flag`. Short names are provided at the
/// command line with a single `-` as a prefix.
///
/// ```gleam
///   clip.command(fn(a) { a })
///   |> clip.flag(flag.new("debug") |> flag.short("d"))
///   |> clip.run(["-d"])
///
/// // Ok(True)
/// ```
pub fn short(flag: Flag, short: String) -> Flag {
  Flag(..flag, short: Some(short))
}

@internal
pub fn run(
  flag: Flag,
  args: List(String),
) -> Result(#(Bool, List(String)), String) {
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

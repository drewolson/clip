//// Functions for building `Opt`s. An `Opt` is a named option with a
//// value, such as `--name "Drew"`

import clip/arg_info.{type ArgInfo, ArgInfo, NamedInfo}
import clip/internal/aliases.{type Args, type FnResult}
import gleam/float
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub opaque type Opt(a) {
  Opt(
    name: String,
    default: Option(a),
    help: Option(String),
    try_map: fn(String) -> Result(a, String),
    short: Option(String),
  )
}

/// Used internally, not intended for direct usage.
pub fn to_arg_info(opt: Opt(a)) -> ArgInfo {
  case opt {
    Opt(name:, short:, default:, help:, try_map: _) ->
      ArgInfo(
        ..arg_info.empty(),
        named: [
          NamedInfo(
            name:,
            short:,
            default: default |> option.map(string.inspect),
            help:,
          ),
        ],
      )
  }
}

/// Modify the value produced by an `Opt` in a way that may fail.
///
/// ```gleam
/// opt.new("age")
/// |> opt.try_map(fn(age_str) {
///   case int.parse(age_str) {
///     Ok(age) -> Ok(age)
///     Error(Nil) -> Error("Unable to parse integer")
///   }
/// })
/// ```
///
/// Note: `try_map` can change the type of an `Opt` and therefore clears any
/// previously set default value.
pub fn try_map(opt: Opt(a), f: fn(a) -> Result(b, String)) -> Opt(b) {
  case opt {
    Opt(name:, short:, default: _, help:, try_map:) ->
      Opt(name:, short:, default: None, help:, try_map: fn(arg) {
        use a <- result.try(try_map(arg))
        f(a)
      })
  }
}

/// Modify the value produced by an `Opt` in a way that cannot fail.
///
/// ```gleam
/// opt.new("name")
/// |> opt.map(fn(name) { string.uppercase(name) })
/// ```
///
/// Note: `map` can change the type of an `Opt` and therefore clears any
/// previously set default value.
pub fn map(opt: Opt(a), f: fn(a) -> b) -> Opt(b) {
  try_map(opt, fn(a) { Ok(f(a)) })
}

/// Provide a default value for an `Opt` when it is not provided by the user.
pub fn default(opt: Opt(a), default: a) -> Opt(a) {
  case opt {
    Opt(name:, short:, default: _, help:, try_map:) ->
      Opt(name:, short:, default: Some(default), help:, try_map:)
  }
}

/// Transform an `Opt(a)` to an `Opt(Result(a, Nil)`, making it optional.
pub fn optional(opt: Opt(a)) -> Opt(Result(a, Nil)) {
  opt |> map(Ok) |> default(Error(Nil))
}

/// Add help text to an `Opt`.
pub fn help(opt: Opt(a), help: String) -> Opt(a) {
  case opt {
    Opt(name:, short:, default:, help: _, try_map:) ->
      Opt(name:, short:, default:, help: Some(help), try_map:)
  }
}

/// Create a new `Opt` with the provided name. New `Opt`s always initially
/// produce a `String`, which is the unmodified value given by the user on the
/// command line.
pub fn new(name: String) -> Opt(String) {
  Opt(name:, short: None, default: None, help: None, try_map: Ok)
}

/// Add a short name for the given `Opt`. Short names are provided at the
/// command line with a single `-` as a prefix.
///
/// ```gleam
///   clip.command(fn(a) { a })
///   |> clip.opt(opt.new("name") |> opt.short("n"))
///   |> clip.run(["-n", "Drew"])
///
/// // Ok("Drew")
/// ```
pub fn short(opt: Opt(String), short_name: String) -> Opt(String) {
  case opt {
    Opt(name:, short: _, default:, help:, try_map:) ->
      Opt(name:, short: Some(short_name), default:, help:, try_map:)
  }
}

/// Modify an `Opt(String)` to produce an `Int`.
///
/// ```gleam
/// opt.new("age")
/// |> opt.int
/// ```
///
/// Note: `int` changes the type of an `Opt` and therefore clears any
/// previously set default value.
pub fn int(opt: Opt(String)) -> Opt(Int) {
  opt
  |> try_map(fn(val) {
    int.parse(val)
    |> result.map_error(fn(_) { "Non-integer value provided for " <> opt.name })
  })
}

/// Modify an `Opt(String)` to produce a `Float`.
///
/// ```gleam
/// opt.new("height")
/// |> opt.float
/// ```
///
/// Note: `float` changes the type of an `Opt` and therefore clears any
/// previously set default value.
pub fn float(opt: Opt(String)) -> Opt(Float) {
  opt
  |> try_map(fn(val) {
    float.parse(val)
    |> result.map_error(fn(_) { "Non-float value provided for " <> opt.name })
  })
}

/// Run an `Opt(a)` against a list of arguments. Used internally by `clip`, not
/// intended for direct usage.
pub fn run(opt: Opt(a), args: Args) -> FnResult(a) {
  let long_name = "--" <> opt.name
  let short_name = option.map(opt.short, fn(s) { "-" <> s })
  let names = short_name |> option.map(fn(s) { [s] }) |> option.unwrap([])
  let names = [long_name, ..names] |> string.join(", ")
  case args, opt.default {
    [key, val, ..rest], _ if key == long_name || Some(key) == short_name -> {
      use a <- result.try(opt.try_map(val))
      Ok(#(a, rest))
    }
    [head, ..rest], _ ->
      run(opt, rest)
      |> result.map(fn(v) { #(v.0, [head, ..v.1]) })
    [], Some(v) -> Ok(#(v, []))
    [], None -> Error("missing required arg: " <> names)
  }
}

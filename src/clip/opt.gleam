import clip/internal/aliases.{type Args, type FnResult}
import clip/internal/arg_info.{type ArgInfo, ArgInfo, NamedInfo}
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

pub fn try_map(opt: Opt(a), f: fn(a) -> Result(b, String)) -> Opt(b) {
  case opt {
    Opt(name:, short:, default: _, help:, try_map:) ->
      Opt(name:, short:, default: None, help:, try_map: fn(arg) {
        use a <- result.try(try_map(arg))
        f(a)
      })
  }
}

pub fn map(opt: Opt(a), f: fn(a) -> b) -> Opt(b) {
  try_map(opt, fn(a) { Ok(f(a)) })
}

pub fn default(opt: Opt(a), default: a) -> Opt(a) {
  case opt {
    Opt(name:, short:, default: _, help:, try_map:) ->
      Opt(name:, short:, default: Some(default), help:, try_map:)
  }
}

pub fn optional(opt: Opt(a)) -> Opt(Result(a, Nil)) {
  opt |> map(Ok) |> default(Error(Nil))
}

pub fn help(opt: Opt(a), help: String) -> Opt(a) {
  case opt {
    Opt(name:, short:, default:, help: _, try_map:) ->
      Opt(name:, short:, default:, help: Some(help), try_map:)
  }
}

pub fn new(name: String) -> Opt(String) {
  Opt(name:, short: None, default: None, help: None, try_map: Ok)
}

pub fn short(opt: Opt(String), short_name: String) -> Opt(String) {
  case opt {
    Opt(name:, short: _, default:, help:, try_map:) ->
      Opt(name:, short: Some(short_name), default:, help:, try_map:)
  }
}

pub fn int(opt: Opt(String)) -> Opt(Int) {
  opt
  |> try_map(fn(val) {
    int.parse(val)
    |> result.map_error(fn(_) { "Non-integer value provided for " <> opt.name })
  })
}

pub fn float(opt: Opt(String)) -> Opt(Float) {
  opt
  |> try_map(fn(val) {
    float.parse(val)
    |> result.map_error(fn(_) { "Non-float value provided for " <> opt.name })
  })
}

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

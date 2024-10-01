import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type Repeat {
  NoRepeat
  ManyRepeat
  Many1Repeat
}

pub type NamedInfo {
  NamedInfo(
    name: String,
    short: Option(String),
    default: Option(String),
    help: Option(String),
  )
}

pub type PositionalInfo {
  PositionalInfo(
    name: String,
    default: Option(String),
    help: Option(String),
    repeat: Repeat,
  )
}

pub type FlagInfo {
  FlagInfo(name: String, short: Option(String), help: Option(String))
}

pub type ArgInfo {
  ArgInfo(
    named: List(NamedInfo),
    positional: List(PositionalInfo),
    flags: List(FlagInfo),
    subcommands: List(String),
  )
}

/// Create an empty `ArgInfo` value.
pub fn empty() -> ArgInfo {
  ArgInfo(named: [], positional: [], flags: [], subcommands: [])
}

/// Merge two `ArgInfo` values.
pub fn merge(a: ArgInfo, b: ArgInfo) -> ArgInfo {
  ArgInfo(
    named: list.append(a.named, b.named),
    positional: list.append(a.positional, b.positional),
    flags: list.append(a.flags, b.flags),
    subcommands: list.append(a.subcommands, b.subcommands),
  )
}

fn named_str(n_info: NamedInfo) -> String {
  let long_name = "--" <> n_info.name
  let short_name = option.map(n_info.short, fn(s) { "-" <> s })
  let names = short_name |> option.map(fn(s) { [s] }) |> option.unwrap([])
  let names_list = [long_name, ..names]
  let #(start, end) = case n_info.default {
    Some(_) -> #("[", "]")
    None -> #("(", ")")
  }
  start
  <> { string.join(names_list, ",") }
  <> " "
  <> string.uppercase(n_info.name)
  <> end
}

fn flag_str(f_info: FlagInfo) -> String {
  let long_name = "--" <> f_info.name
  let short_name = option.map(f_info.short, fn(s) { "-" <> s })
  let names = short_name |> option.map(fn(s) { [s] }) |> option.unwrap([])
  let names_list = [long_name, ..names]
  "[" <> { string.join(names_list, ",") } <> "]"
}

fn pos_str(p_info: PositionalInfo) -> String {
  let name = string.uppercase(p_info.name)
  let name = case p_info.repeat {
    NoRepeat -> name
    ManyRepeat -> "[" <> name <> "...]"
    Many1Repeat -> name <> "..."
  }
  name
}

/// Generate user-facing help text from given info, a CLI name, a CLI description.
pub fn help_text(info: ArgInfo, name: String, description: String) -> String {
  let sub_usage = case info.subcommands {
    [] -> []
    _ -> ["<COMMAND>"]
  }
  let opt_usage = case info.named, info.flags {
    [], [] -> []
    _, _ -> ["[OPTIONS]"]
  }
  let named_args =
    info.named
    |> list.map(named_str)

  let flag_args =
    info.flags
    |> list.map(flag_str)

  let pos_args =
    info.positional
    |> list.map(pos_str)

  let max_size =
    named_args
    |> list.append(flag_args)
    |> list.append(pos_args)
    |> list.map(string.length)
    |> list.fold(0, int.max)

  let usage =
    string.join(
      [name]
        |> list.append(sub_usage)
        |> list.append(opt_usage)
        |> list.append(pos_args),
      " ",
    )

  let sub_desc =
    info.subcommands
    |> list.map(fn(sub) { "  " <> sub })
    |> string.join("\n")

  let pos_desc =
    info.positional
    |> list.map(fn(p_info) {
      let name =
        p_info
        |> pos_str
        |> string.pad_right(max_size, " ")

      let help_text = case p_info.repeat, p_info.default {
        ManyRepeat, _ ->
          p_info.help
          |> option.map(fn(h) { h <> " (zero or more)" })
          |> option.unwrap("Zero or more")
        Many1Repeat, _ ->
          p_info.help
          |> option.map(fn(h) { h <> " (one or more)" })
          |> option.unwrap("One or more")
        NoRepeat, None -> p_info.help |> option.unwrap("")
        NoRepeat, Some(v) ->
          p_info.help
          |> option.map(fn(h) { h <> " (default: " <> v <> ")" })
          |> option.unwrap("Default: " <> v)
      }

      name <> "\t" <> help_text
    })
    |> list.map(fn(l) { "  " <> l })
    |> string.join("\n")

  let named_desc =
    info.named
    |> list.map(fn(n_info) {
      let names =
        n_info
        |> named_str
        |> string.pad_right(max_size, " ")

      case n_info.default {
        None -> names <> "\t" <> n_info.help |> option.unwrap("")
        Some(v) ->
          names
          <> "\t"
          <> n_info.help
          |> option.map(fn(h) { h <> " (default: " <> v <> ")" })
          |> option.unwrap("Default: " <> v)
      }
    })
    |> list.map(fn(l) { "  " <> l })
    |> string.join("\n")

  let flag_desc =
    info.flags
    |> list.map(fn(f_info) {
      f_info
      |> flag_str
      |> string.pad_right(max_size, " ")
      <> "\t"
      <> f_info.help
      |> option.unwrap("")
    })
    |> list.map(fn(l) { "  " <> l })
    |> string.join("\n")

  let opt_desc =
    [named_desc, flag_desc]
    |> list.filter(fn(desc) { desc != "" })
    |> string.join("\n")

  let sub_lines = case string.is_empty(sub_desc) {
    True -> []
    False -> ["Commands:", sub_desc]
  }

  let pos_lines = case string.is_empty(pos_desc) {
    True -> []
    False -> ["Arguments:", pos_desc]
  }

  let opt_lines = case string.is_empty(opt_desc) {
    True -> []
    False -> ["Options:", opt_desc]
  }

  string.join(
    [name <> " -- " <> description, "Usage:\n\n  " <> usage]
      |> list.append(sub_lines)
      |> list.append(pos_lines)
      |> list.append(opt_lines),
    "\n\n",
  )
}

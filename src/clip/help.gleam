//// Functions for building `Help` flags.

import clip/arg_info.{type ArgInfo}

pub opaque type Help {
  Help(f: fn(ArgInfo) -> String)
}

/// Produce a `String` from a `Help` and an `ArgInfo`. Used internally by
/// `clip`, not intended for direct usage.
pub fn run(help: Help, arg_info: ArgInfo) -> String {
  help.f(arg_info)
}

/// Generate custom help text by providing a function that transforms
/// `ArgInfo` into a `String`.
pub fn custom(f: fn(ArgInfo) -> String) -> Help {
  Help(f)
}

/// Generate help text from a name and description.
pub fn simple(name: String, description: String) -> Help {
  Help(f: arg_info.help_text(_, name, description))
}

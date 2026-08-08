# 1.2.1

* Ensure positional arguments do not consume values belonging to named options,
  regardless of the order in which parsers are added to a command.
* Stop parsing named options and flags after the `--` delimiter.
* Ensure `clip.parse` does not leave a consumed `--` delimiter in the unparsed
  argument list.

# 1.2.0

* Add `clip.parse` to allow accessing unparsed arguments.

# 1.1.1

* Ensure `clip.arg_many` and `clip.arg_many1` do not leave `--` in argument
  list.

# 1.1.0

* Add `clip.command1`, `clip.command2`, `clip.command3`, and `clip.command4`.

# 1.0.0

* First stable release.

# 0.6.2

* Update `gleam_stdlib` dependency.

# 0.6.1

* Modify `help.simple` generated text.

# 0.6.0

* Introduce `clip/help` module for building help text.

# 0.5.0

* Rename `clip.param` to `clip.parameter`.
* Introduce `clip.add_custom_help`.

# 0.4.1

* Idiomatic help text for `arg_many()` (thanks [@seschwar](https://github.com/seschwar)).

# 0.4.0

* Add `clip.param` to provide an alternative syntax for building curried
  functions.

# 0.3.0

* Rename `clip.pure` to `clip.return` for consistency with the gleam ecosystem.
* Add `javascript` example.

# 0.2.0

* Correctly handle the `--` value for `arg_many` and `arg_many1`.

# 0.1.0

* Initial Release

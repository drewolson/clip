pub type FnResult(a) =
  Result(#(a, List(String)), String)

pub type Args =
  List(String)

pub type ArgsFn(a) =
  fn(Args) -> FnResult(a)

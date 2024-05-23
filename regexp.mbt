struct RegExp {
  pattern : String
  matcher : @lib.Matcher
}

pub fn compile(pattern : String) -> Result[RegExp, String] {
  Ok({ pattern, matcher: @lib.Matcher::new(pattern)? })
}

fn pattern(self : RegExp) -> String {
  self.pattern
}

fn matches(self : RegExp, input : String) -> Result[Bool, String] {
  self.matcher.matches(input)
}

fn replace_all(self : RegExp, src : String, repl : String) -> String {
  ""
}

fn split(self : RegExp, s : String) -> Array[String] {
  []
}

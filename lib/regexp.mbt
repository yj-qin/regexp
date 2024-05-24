struct RegExp {
  pattern : String
  matcher : Matcher
}

pub fn RegExp::new(pattern : String) -> Result[RegExp, String] {
  let ast = Parser::new(pattern).parse()?
  let nfa = Nfa::new(ast)
  Ok({ pattern, matcher: Matcher::new(nfa, ast)? })
}

pub fn pattern(self : RegExp) -> String {
  self.pattern
}

pub fn matches(self : RegExp, input : String) -> Result[MatchResult, String] {
  self.matcher.matches(input)
}

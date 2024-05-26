struct RegExp {
  pattern : String
  // matcher : Matcher
}

pub fn RegExp::new(pattern : String) -> Result[RegExp, String] {
  // let ast = Parser::new(pattern).parse()?
  // let nfa = Nfa::new(ast)
  Ok({ pattern, })
}

pub fn pattern(self : RegExp) -> String {
  self.pattern
}
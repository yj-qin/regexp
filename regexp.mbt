struct RegExp {
  pattern : String
  prog : Program
}

fn RegExp::new(pattern : String) -> Result[RegExp, String] {
  let ast = Parser::new(pattern).parse()?
  let prog = Emitter::new(ast).emit()
  Ok({ pattern, prog })
}

pub fn compile(pattern : String) -> Result[RegExp, String] {
  RegExp::new(pattern)
}

pub fn pattern(self : RegExp) -> String {
  self.pattern
}

pub fn matches(
  self : RegExp,
  text : String,
  ~start : Int = 0,
  ~end : Int = text.length()
) -> Match {
  Interpreter::new(self.prog).scan(text, start, end)
}

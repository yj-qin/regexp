pub fn compile(pattern : String) -> Result[@lib.RegExp, String] {
  @lib.RegExp::new(pattern)
}

enum RegexpTree {
  NoMatch
  EmptyMatch
  Literal(~runes : Array[Char])
  CharClass
  AnyChar
  BeginOfLine
  EndOfLine
  BeginOfText
  EndOfText
  ZeroOrMore
  OneOrMore
  ZeroOrOne
  Repeat(~min : Int, ~max : Int)
  Concat(~subs : Array[RegexpTree])
  Alternate(~subs : Array[RegexpTree])
}

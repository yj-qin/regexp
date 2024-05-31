fn test_parse(s : String) -> Result[Ast, String] {
  Parser::new(s).parse()
}

// #region single
test "should parse single char" {
  inspect(
    test_parse("a"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Single a
      #|)
    ,
  )?
}
// #endregion

// #region concat
test "should parse concat" {
  inspect(
    test_parse("abc"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Concatenate
      #|    Single a
      #|    Single b
      #|    Single c
      #|)
    ,
  )?
}
// #endregion

// #region alt
test "should parse alt" {
  inspect(
    test_parse("a|b|c"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Alternate
      #|    Single a
      #|    Single b
      #|    Single c
      #|)
    ,
  )?
}
// #endregion

// #region repeat
test "should parse star" {
  inspect(
    test_parse("a*"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop Greedy {0,} a
      #|)
    ,
  )?
}

test "should parse plus" {
  inspect(
    test_parse("a+"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop Greedy {1,} a
      #|)
    ,
  )?
}

test "should parse quest" {
  inspect(
    test_parse("a?"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop Greedy {0,1} a
      #|)
    ,
  )?
}

test "should parse exact loop" {
  inspect(
    test_parse("a{2}"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop Greedy {2} a
      #|)
    ,
  )?
}

test "should parse loop [min, max]" {
  inspect(
    test_parse("a{1,2}"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop Greedy {1,2} a
      #|)
    ,
  )?
}

test "should parse loop [min, infinity]" {
  inspect(
    test_parse("a{0,}"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop Greedy {0,} a
      #|)
    ,
  )?
}

test "should parse non-greedy" {
  inspect(
    test_parse("a*?"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop NonGreedy {0,} a
      #|)
    ,
  )?
  inspect(
    test_parse("a+?"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop NonGreedy {1,} a
      #|)
    ,
  )?
  inspect(
    test_parse("a??"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop NonGreedy {0,1} a
      #|)
    ,
  )?
  inspect(
    test_parse("a{0,2}?"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  SingleLoop NonGreedy {0,2} a
      #|)
    ,
  )?
}

test "throws on invalid loop" {
  inspect(test_parse("a{,1}"), content="Err(invalid loop)")?
  inspect(test_parse("a{0,1"), content="Err(invalid loop)")?
  inspect(test_parse("a{}"), content="Err(invalid loop)")?
}
// #endregion

// #region class
test "should parse class" {
  inspect(
    test_parse("[abc]"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Class [abc]
      #|)
    ,
  )?
}

test "should parse range class" {
  inspect(
    test_parse("[a-z]"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Class [a-z]
      #|)
    ,
  )?
  inspect(
    test_parse("[a-zA-Z]"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Class [a-zA-Z]
      #|)
    ,
  )?
  inspect(
    test_parse("[0-9]"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Class [0-9]
      #|)
    ,
  )?
}

test "should parse negated class" {
  inspect(
    test_parse("[^abc]"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Class [^abc]
      #|)
    ,
  )?
}

test "throws on unclosed class" {
  inspect(test_parse("[abc"), content="Err(class missing end bracket)")?
}
// #endregion

// #region group
test "should parse group" {
  inspect(
    test_parse("(a)"),
    content=
      #|Ok(
      #|Number of captures: 2
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Capture 1
      #|    Single a
      #|)
    ,
  )?
  inspect(
    test_parse("(a)(b)"),
    content=
      #|Ok(
      #|Number of captures: 3
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Concatenate
      #|    Capture 1
      #|      Single a
      #|    Capture 2
      #|      Single b
      #|)
    ,
  )?
}

test "should parse nested group" {
  inspect(
    test_parse("((a)bc)"),
    content=
      #|Ok(
      #|Number of captures: 3
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Capture 1
      #|    Concatenate
      #|      Capture 2
      #|        Single a
      #|      Single b
      #|      Single c
      #|)
    ,
  )?
}

test "should parse nested group concat" {
  inspect(
    test_parse("((a)(b))"),
    content=
      #|Ok(
      #|Number of captures: 4
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Capture 1
      #|    Concatenate
      #|      Capture 2
      #|        Single a
      #|      Capture 3
      #|        Single b
      #|)
    ,
  )?
}

test "should parse nested group alt" {
  inspect(
    test_parse("((a)|bc)"),
    content=
      #|Ok(
      #|Number of captures: 3
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Capture 1
      #|    Alternate
      #|      Capture 2
      #|        Single a
      #|      Concatenate
      #|        Single b
      #|        Single c
      #|)
    ,
  )?
  inspect(
    test_parse("((a)|(b))"),
    content=
      #|Ok(
      #|Number of captures: 4
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Capture 1
      #|    Alternate
      #|      Capture 2
      #|        Single a
      #|      Capture 3
      #|        Single b
      #|)
    ,
  )?
}

test "should parse non-capturing group" {
  inspect(
    test_parse("(?:a)"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Group
      #|    Single a
      #|)
    ,
  )?
}

test "should parse named group" {
  inspect(
    test_parse("(?<group1>a)"),
    content=
      #|Ok(
      #|Number of captures: 2
      #|Capture name mapping: Map::[("group1", 1)]
      #|Ast:
      #|Capture 0
      #|  Capture 1
      #|    Single a
      #|)
    ,
  )?
}

test "throws on unclosed group" {
  inspect(test_parse("(abc"), content="Err(group missing end paren)")?
}

test "throws on empty group" {
  inspect(test_parse("()"), content="Err(empty group)")?
}

test "throws on empty group name" {
  inspect(test_parse("(?<>abc)"), content="Err(empty group name)")?
}
// #endregion

// #region escape
test "should parse escape" {
  inspect(
    test_parse("\\*"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Single *
      #|)
    ,
  )?
  inspect(
    test_parse("\\+"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Single +
      #|)
    ,
  )?
  inspect(
    test_parse("\\?"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Single ?
      #|)
    ,
  )?
  inspect(
    test_parse("\\a"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Single a
      #|)
    ,
  )?
}
// #endregion

// #region common
test "should parse common regexp" {
  inspect(
    test_parse("^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$"),
    content=
      #|Ok(
      #|Number of captures: 3
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Concatenate
      #|    BeginOfLine
      #|    Capture 1
      #|      ClassLoop Greedy {1,} [a-zA-Z0-9._%+-]
      #|    Single @
      #|    Capture 2
      #|      Concatenate
      #|        ClassLoop Greedy {1,} [a-zA-Z0-9.-]
      #|        Single .
      #|        ClassLoop Greedy {2,} [a-zA-Z]
      #|    EndOfLine
      #|)
    ,
  )?
}
// #endregion
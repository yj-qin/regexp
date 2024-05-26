fn test_parse(s : String) -> Result[Ast, String] {
  Parser::new(s).parse()
}

// #region single
test "should parse single char" {
  inspect(
    test_parse("a"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Single a
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
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Concatenate
      #|  Single a
      #|  Single b
      #|  Single c
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
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Alternate
      #|  Single a
      #|  Single b
      #|  Single c
      #|)
    ,
  )?
}
// #endregion

// #region repeat
test "should parse star" {
  inspect(test_parse("a*"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoop {0,} a
    #|)
  )?
}

test "should parse plus" {
  inspect(test_parse("a+"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoop {1,} a
    #|)
  )?
}

test "should parse quest" {
  inspect(test_parse("a?"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoop {0,1} a
    #|)
  )?
}

test "should parse exact loop" {
  inspect(test_parse("a{2}"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoop {2} a
    #|)
  )?
}

test "should parse loop [min, max]" {
  inspect(test_parse("a{1,2}"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoop {1,2} a
    #|)
  )?
}

test "should parse loop [min, infinity]" {
  inspect(test_parse("a{0,}"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoop {0,} a
    #|)
  )?
}

test "should parse non-greedy" {
  inspect(test_parse("a*?"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoopNG {0,} a
    #|)
  )?
  inspect(test_parse("a+?"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoopNG {1,} a
    #|)
  )?
  inspect(test_parse("a??"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoopNG {0,1} a
    #|)
  )?
  inspect(test_parse("a{0,2}?"), content=
    #|Ok(
    #|Number of captures: 0
    #|Capture name mapping: Map::[]
    #|Ast:
    #|SingleLoopNG {0,2} a
    #|)
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
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Class [97, 97, 98, 98, 99, 99]
      #|)
    ,
  )?
}

test "should parse range class" {
  inspect(
    test_parse("[a-z]"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Class [97, 122]
      #|)
    ,
  )?
  inspect(
    test_parse("[a-zA-Z]"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Class [97, 122, 65, 90]
      #|)
    ,
  )?
  inspect(
    test_parse("[0-9]"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Class [48, 57]
      #|)
    ,
  )?
}

test "should parse negated class" {
  inspect(
    test_parse("[^abc]"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Class Neg [97, 97, 98, 98, 99, 99]
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
      #|Number of captures: 1
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Single a
      #|)
    ,
  )?
  inspect(
    test_parse("(a)(b)"),
    content=
      #|Ok(
      #|Number of captures: 2
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Concatenate
      #|  Capture 0
      #|    Single a
      #|  Capture 1
      #|    Single b
      #|)
    ,
  )?
}

test "should parse nested group" {
  inspect(
    test_parse("((a)bc)"),
    content=
      #|Ok(
      #|Number of captures: 2
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Capture 0
      #|  Concatenate
      #|    Capture 1
      #|      Single a
      #|    Single b
      #|    Single c
      #|)
    ,
  )?
}

test "should parse nested group concat" {
  inspect(
    test_parse("((a)(b))"),
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

test "should parse nested group alt" {
  inspect(test_parse("((a)|bc)"), content=
    #|Ok(
    #|Number of captures: 2
    #|Capture name mapping: Map::[]
    #|Ast:
    #|Capture 0
    #|  Alternate
    #|    Capture 1
    #|      Single a
    #|    Concatenate
    #|      Single b
    #|      Single c
    #|)
  )?
  inspect(test_parse("((a)|(b))"), content=
    #|Ok(
    #|Number of captures: 3
    #|Capture name mapping: Map::[]
    #|Ast:
    #|Capture 0
    #|  Alternate
    #|    Capture 1
    #|      Single a
    #|    Capture 2
    #|      Single b
    #|)
  )?
}

test "should parse non-capturing group" {
  inspect(
    test_parse("(?:a)"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Group
      #|  Single a
      #|)
    ,
  )?
}

test "should parse named group" {
  inspect(
    test_parse("(?<group1>a)"),
    content=
      #|Ok(
      #|Number of captures: 1
      #|Capture name mapping: Map::[("group1", 0)]
      #|Ast:
      #|Capture 0
      #|  Single a
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
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Single *
      #|)
    ,
  )?
  inspect(
    test_parse("\\+"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Single +
      #|)
    ,
  )?
  inspect(
    test_parse("\\?"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Single ?
      #|)
    ,
  )?
  inspect(
    test_parse("\\a"),
    content=
      #|Ok(
      #|Number of captures: 0
      #|Capture name mapping: Map::[]
      #|Ast:
      #|Single a
      #|)
    ,
  )?
}
// #endregion

// #region common
test "should parse common regexp" {
  inspect(test_parse("^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$"), content=
    #|Ok(
    #|Number of captures: 2
    #|Capture name mapping: Map::[]
    #|Ast:
    #|Concatenate
    #|  BeginOfLine
    #|  Capture 0
    #|    ClassLoop {1,} [97, 122, 65, 90, 48, 57, 46, 46, 95, 95, 37, 37, 43, 43, 45, 45]
    #|  Single @
    #|  Capture 1
    #|    Concatenate
    #|      ClassLoop {1,} [97, 122, 65, 90, 48, 57, 46, 46, 45, 45]
    #|      Single .
    #|      ClassLoop {2,} [97, 122, 65, 90]
    #|  EndOfLine
    #|)
  )?
}
// #endregion

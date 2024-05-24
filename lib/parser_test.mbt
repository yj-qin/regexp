fn p(s : String) -> Result[Ast, String] {
  Parser::new(s).parse()
}

// #region concat
test "should parse concat" {
  inspect(
    p("abc"),
    content=
      #|Ok(Concat(Char(a,false),Char(b,false),Char(c,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}
// #endregion

// #region alt
test "should parse alt" {
  inspect(
    p("a|b|c"),
    content=
      #|Ok(Alt(Char(a,false),Char(b,false),Char(c,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}
// #endregion

// #region repeat
test "should parse star" {
  inspect(
    p("a*"),
    content=
      #|Ok(Star(Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse plus" {
  inspect(
    p("a+"),
    content=
      #|Ok(Plus(Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse quest" {
  inspect(
    p("a?"),
    content=
      #|Ok(Quest(Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse exact repeat" {
  inspect(
    p("a{2}"),
    content=
      #|Ok(Repeat{2,2}(Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse repeat [min, max]" {
  inspect(
    p("a{1,2}"),
    content=
      #|Ok(Repeat{1,2}(Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse repeat [min, infinity]" {
  inspect(
    p("a{0,}"),
    content=
      #|Ok(Repeat{0,}(Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "throws on invalid repeat" {
  inspect(p("a{,1}"), content="Err(invalid repeat range)")?
  inspect(p("a{0,1"), content="Err(invalid repeat range)")?
  inspect(p("a{}"), content="Err(invalid repeat range)")?
}
// #endregion

// #region class
test "should parse class" {
  inspect(
    p("[abc]"),
    content=
      #|Ok(Class(abc)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse range class" {
  inspect(
    p("[a-z]"),
    content=
      #|Ok(Class(a-z)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
  inspect(
    p("[a-zA-Z]"),
    content=
      #|Ok(Class(a-zA-Z)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
  inspect(
    p("[0-9]"),
    content=
      #|Ok(Class(0-9)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse negated class" {
  inspect(
    p("[^abc]"),
    content=
      #|Ok(Class(^abc)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "throws on unclosed class" {
  inspect(p("[abc"), content="Err(class missing end bracket)")?
}
// #endregion

// #region group
test "should parse group" {
  inspect(
    p("(a)"),
    content=
      #|Ok(Group[0,capture:true,name:""](Char(a,false))
      #|capture_num: 1
      #|capture_name_map: Map::[])
    ,
  )?
  inspect(
    p("(a)(b)"),
    content=
      #|Ok(Concat(Group[0,capture:true,name:""](Char(a,false)),Group[1,capture:true,name:""](Char(b,false)))
      #|capture_num: 2
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse nested group" {
  inspect(
    p("((a)bc)"),
    content=
      #|Ok(Group[0,capture:true,name:""](Concat(Group[1,capture:true,name:""](Char(a,false)),Char(b,false),Char(c,false)))
      #|capture_num: 2
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse nested group concat" {
  inspect(
    p("((a)(b))"),
    content=
      #|Ok(Group[0,capture:true,name:""](Concat(Group[1,capture:true,name:""](Char(a,false)),Group[2,capture:true,name:""](Char(b,false))))
      #|capture_num: 3
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse nested group alt" {
  // FIXME:
  inspect(p("((a)|(b))"), content="Err(internal parser error)")?
}

test "should parse non-capturing group" {
  inspect(
    p("(?:a)"),
    content=
      #|Ok(Group[0,capture:false,name:""](Char(a,false))
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}

test "should parse named group" {
  inspect(
    p("(?<group1>a)"),
    content=
      #|Ok(Group[0,capture:true,name:"group1"](Char(a,false))
      #|capture_num: 1
      #|capture_name_map: Map::[("group1", 0)])
    ,
  )?
}

test "throws on unclosed group" {
  inspect(p("(abc"), content="Err(group missing end paren)")?
}

test "throws on empty group" {
  inspect(p("()"), content="Err(empty group)")?
}

test "throws on empty group name" {
  inspect(p("(?<>abc)"), content="Err(empty group name)")?
}
// #endregion

// #region escape
test "should parse escape" {
  inspect(
    p("\\*"),
    content=
      #|Ok(Char(*,true)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
  inspect(
    p("\\+"),
    content=
      #|Ok(Char(+,true)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
  inspect(
    p("\\?"),
    content=
      #|Ok(Char(?,true)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
  inspect(
    p("\\a"),
    content=
      #|Ok(Char(a,true)
      #|capture_num: 0
      #|capture_name_map: Map::[])
    ,
  )?
}
// #endregion

// #region common
test "should parse common regexp" {
  inspect(
    p("^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$"),
    content=
      #|Ok(Concat(Assert(BeginOfLine),Group[0,capture:true,name:""](Plus(Class(a-zA-Z0-9._%+-))),Char(@,false),Group[1,capture:true,name:""](Concat(Plus(Class(a-zA-Z0-9.-)),Char(.,true),Repeat{2,}(Class(a-zA-Z)))),Assert(EndOfLine))
      #|capture_num: 2
      #|capture_name_map: Map::[])
    ,
  )?
}
// #endregion

fn p(s : String) -> Result[Ast, String] {
  Parser::new(s).parse()
}

test "parse concat" {
  inspect(
    p("abc"),
    content="Ok({root: Concat(Char(a,false),Char(b,false),Char(c,false)), capture_num: 0})",
  )?
}

test "parse alt" {
  inspect(
    p("a|b|c"),
    content="Ok({root: Alt(Char(a,false),Char(b,false),Char(c,false)), capture_num: 0})",
  )?
}

test "parse repeat" {
  inspect(
    p("a*"),
    content="Ok({root: Star(Char(a,false)), capture_num: 0})",
  )?
  inspect(
    p("a+"),
    content="Ok({root: Plus(Char(a,false)), capture_num: 0})",
  )?
  inspect(
    p("a?"),
    content="Ok({root: Quest(Char(a,false)), capture_num: 0})",
  )?
  inspect(
    p("a{1,2}"),
    content="Ok({root: Repeat{1,2}(Char(a,false)), capture_num: 0})",
  )?
  inspect(
    p("a{0,}"),
    content="Ok({root: Repeat{0,}(Char(a,false)), capture_num: 0})",
  )?
  inspect(
    p("a{2}"),
    content="Ok({root: Repeat{2,2}(Char(a,false)), capture_num: 0})",
  )?
  inspect(p("a{,1}"), content="Err(invalid repeat range)")?
  inspect(p("a{0,1"), content="Err(invalid repeat range)")?
  inspect(p("a{}"), content="Err(invalid repeat range)")?
}

test "parse class" {
  inspect(p("[abc]"), content="Ok({root: Class(abc), capture_num: 0})")?
  inspect(p("[^abc]"), content="Ok({root: Class(^abc), capture_num: 0})")?
  inspect(
    p("[a-z]"),
    content="Ok({root: Class(a-z), capture_num: 0})",
  )?
  inspect(
    p("[a-zA-Z]"),
    content="Ok({root: Class(a-zA-Z), capture_num: 0})",
  )?
  inspect(
    p("[0-9]"),
    content="Ok({root: Class(0-9), capture_num: 0})",
  )?
  inspect(p("[abc"), content="Err(class missing end bracket)")?
}

test "parse group" {
  inspect(
    p("(abc)"),
    content="Ok({root: Group[0](Concat(Char(a,false),Char(b,false),Char(c,false))), capture_num: 1})",
  )?
  inspect(
    p("(abc)(def)"),
    content="Ok({root: Concat(Group[0](Concat(Char(a,false),Char(b,false),Char(c,false))),Group[1](Concat(Char(d,false),Char(e,false),Char(f,false)))), capture_num: 2})",
  )?
  inspect(p("((a)bc)"), content="Ok({root: Group[0](Concat(Group[1](Char(a,false)),Char(b,false),Char(c,false))), capture_num: 2})")?
  inspect(p("(abc"), content="Err(group missing end paren)")?
}

test "parse escape" {
  inspect(p("\\*"), content="Ok({root: Char(*,true), capture_num: 0})")?
  inspect(p("\\+"), content="Ok({root: Char(+,true), capture_num: 0})")?
  inspect(p("\\?"), content="Ok({root: Char(?,true), capture_num: 0})")?
  inspect(p("\\a"), content="Ok({root: Char(a,true), capture_num: 0})")?
}

test "parse" {
  inspect(p("^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$"), content="Ok({root: Concat(Assert(BeginOfLine),Group[0](Plus(Class(a-zA-Z0-9._%+-))),Char(@,false),Group[1](Concat(Plus(Class(a-zA-Z0-9.-)),Char(.,true),Repeat{2,}(Class(a-zA-Z)))),Assert(EndOfLine)), capture_num: 2})")?
}
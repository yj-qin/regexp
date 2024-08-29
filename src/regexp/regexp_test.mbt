test "should match single" {
  inspect!(
    @regexp.compile!("a").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("d").matches("abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match concat" {
  inspect!(
    @regexp.compile!("cde").matches("abcdef"),
    content=
      #|{success: true, captures: ["cde"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("efg").matches("abcdef"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match alt" {
  inspect!(
    @regexp.compile!("a|b|c").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a|b|c").matches("b"),
    content=
      #|{success: true, captures: ["b"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a|b|c").matches("c"),
    content=
      #|{success: true, captures: ["c"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a|b|c").matches("d"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match class" {
  inspect!(
    @regexp.compile!("[abc]").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[abc]").matches("d"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[^abc]").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[^abc]").matches("d"),
    content=
      #|{success: true, captures: ["d"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-zA-Z]").matches("A"),
    content=
      #|{success: true, captures: ["A"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-zA-Z]").matches("0"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match assert" {
  inspect!(
    @regexp.compile!("^abc").matches("abcdef"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("^def").matches("abcdef"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("abc$").matches("abcdef"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("def$").matches("abcdef"),
    content=
      #|{success: true, captures: ["def"], named_captures: {}}
    ,
  )
}

test "should match one or more" {
  inspect!(
    @regexp.compile!("a+").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a+").matches("b"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match zero or more" {
  inspect!(
    @regexp.compile!("a*").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a*").matches("b"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

test "should match zero or one" {
  inspect!(
    @regexp.compile!("a?").matches("aaa"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a?").matches("b"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

test "should match quantifier" {
  inspect!(
    @regexp.compile!("a{2}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2}").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{1,2}").matches(""),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{1,2}").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{1,2}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2,}").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2,}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2,}").matches("aaaaaaaaaaaaa"),
    content=
      #|{success: true, captures: ["aaaaaaaaaaaaa"], named_captures: {}}
    ,
  )
}

test "should match non-greedy" {
  inspect!(
    @regexp.compile!("a*?").matches("aaabc"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a+?").matches("aaabc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a??").matches("aaabc"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("<.*?>").matches("<foo> <bar> new </bar> </foo>"),
    content=
      #|{success: true, captures: ["<foo>"], named_captures: {}}
    ,
  )
}

test "should match group" {
  inspect!(
    @regexp.compile!("(abc)|(def)").matches("def"),
    content=
      #|{success: true, captures: ["def", "", "def"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("(a*)bc").matches("aaaaabc"),
    content=
      #|{success: true, captures: ["aaaaabc", "aaaaa"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("(Hello, (?<name>[a-zA-Z]{2,}))! Welcome!").matches(
      "Hello, John! Welcome!",
    ),
    content=
      #|{success: true, captures: ["Hello, John! Welcome!", "Hello, John", "John"], named_captures: {"name": "John"}}
    ,
  )
}

test "should match common pattern" {
  inspect!(
    @regexp.compile!(
      "^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$",
    ).matches("123456@test.com"),
    content=
      #|{success: true, captures: ["123456@test.com", "123456", "test.com"], named_captures: {"addr": "123456", "host": "test.com"}}
    ,
  )
}

test "should match single" {
  inspect!(
    @regexp.compile!("a").matches("abc"),
    content=
      #|{success: true, captures: ["a"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("d").matches("abc"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match concat" {
  inspect!(
    @regexp.compile!("cde").matches("abcdef"),
    content=
      #|{success: true, captures: ["cde"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("efg").matches("abcdef"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match alt" {
  inspect!(
    @regexp.compile!("a|b|c").matches("a"),
    content=
      #|{success: true, captures: ["a"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a|b|c").matches("b"),
    content=
      #|{success: true, captures: ["b"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a|b|c").matches("c"),
    content=
      #|{success: true, captures: ["c"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a|b|c").matches("d"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match class" {
  inspect!(
    @regexp.compile!("[abc]").matches("a"),
    content=
      #|{success: true, captures: ["a"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[abc]").matches("d"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[^abc]").matches("a"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[^abc]").matches("d"),
    content=
      #|{success: true, captures: ["d"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-zA-Z]").matches("A"),
    content=
      #|{success: true, captures: ["A"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-zA-Z]").matches("0"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match assert" {
  inspect!(
    @regexp.compile!("^abc").matches("abcdef"),
    content=
      #|{success: true, captures: ["abc"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("^def").matches("abcdef"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("abc$").matches("abcdef"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("def$").matches("abcdef"),
    content=
      #|{success: true, captures: ["def"], capture_name_mapping: {}}
    ,
  )
}

test "should match one or more" {
  inspect!(
    @regexp.compile!("a+").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a+").matches("b"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match zero or more" {
  inspect!(
    @regexp.compile!("a*").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a*").matches("b"),
    content=
      #|{success: true, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match zero or one" {
  inspect!(
    @regexp.compile!("a?").matches("aaa"),
    content=
      #|{success: true, captures: ["a"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a?").matches("b"),
    content=
      #|{success: true, captures: [""], capture_name_mapping: {}}
    ,
  )
}

test "should match quantifier" {
  inspect!(
    @regexp.compile!("a{2}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2}").matches("a"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{1,2}").matches(""),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{1,2}").matches("a"),
    content=
      #|{success: true, captures: ["a"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{1,2}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2,}").matches("a"),
    content=
      #|{success: false, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2,}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a{2,}").matches("aaaaaaaaaaaaa"),
    content=
      #|{success: true, captures: ["aaaaaaaaaaaaa"], capture_name_mapping: {}}
    ,
  )
}

test "should match non-greedy" {
  inspect!(
    @regexp.compile!("a*?").matches("aaabc"),
    content=
      #|{success: true, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a+?").matches("aaabc"),
    content=
      #|{success: true, captures: ["a"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("a??").matches("aaabc"),
    content=
      #|{success: true, captures: [""], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("<.*?>").matches("<foo> <bar> new </bar> </foo>"),
    content=
      #|{success: true, captures: ["<foo>"], capture_name_mapping: {}}
    ,
  )
}

test "should match group" {
  inspect!(
    @regexp.compile!("(abc)|(def)").matches("def"),
    content=
      #|{success: true, captures: ["def", "", "def"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("(a*)bc").matches("aaaaabc"),
    content=
      #|{success: true, captures: ["aaaaabc", "aaaaa"], capture_name_mapping: {}}
    ,
  )
  inspect!(
    @regexp.compile!("(Hello, (?<name>[a-zA-Z]{2,}))! Welcome!").matches(
      "Hello, John! Welcome!",
    ),
    content=
      #|{success: true, captures: ["Hello, John! Welcome!", "Hello, John", "John"], capture_name_mapping: {"name": 2}}
    ,
  )
}

test "should match common pattern" {
  inspect!(
    @regexp.compile!(
      "^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$",
    ).matches("123456@test.com"),
    content=
      #|{success: true, captures: ["123456@test.com", "123456", "test.com"], capture_name_mapping: {"addr": 1, "host": 2}}
    ,
  )
}

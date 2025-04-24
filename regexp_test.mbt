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

test "should match escape" {
  inspect!(
    @regexp.compile!("\\d").matches("123"),
    content=
      #|{success: true, captures: ["1"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\d").matches("abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\D").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\D").matches("123"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\w").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\w").matches(" "),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\W").matches(" "),
    content=
      #|{success: true, captures: [" "], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\W").matches("abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\s").matches(" "),
    content=
      #|{success: true, captures: [" "], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\s").matches("123"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\S").matches("123"),
    content=
      #|{success: true, captures: ["1"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\S").matches(" "),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\n").matches("a\nb"),
    content=
      #|{success: true, captures: ["\n"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\r").matches("a\rb"),
    content=
      #|{success: true, captures: ["\r"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\t").matches("a\tb"),
    content=
      #|{success: true, captures: ["\t"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\v").matches("a\u000Bb"),
    content=
      #|{success: true, captures: ["\x0b"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("\\f").matches("a\u000Cb"),
    content=
      #|{success: true, captures: ["\x0c"], named_captures: {}}
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

test "should match escape class" {
  inspect!(
    @regexp.compile!("[\\d]+").matches("abc123"),
    content=
      #|{success: true, captures: ["123"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[\\D]+").matches("abc123"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[\\s]+").matches("123 abc"),
    content=
      #|{success: true, captures: [" "], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[\\S]+").matches("123 abc"),
    content=
      #|{success: true, captures: ["123"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[\\w]+").matches("123abc"),
    content=
      #|{success: true, captures: ["123abc"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[\\W]+").matches("123abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match class repeat" {
  inspect!(
    @regexp.compile!("[a-z]{3}").matches("abc"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-z]{3}").matches("ab"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should match class loop" {
  inspect!(
    @regexp.compile!("[a-z]*").matches("abc"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-z]*").matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-z]*").matches("123"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

test "should match class lazy loop" {
  inspect!(
    @regexp.compile!("[a-z]+?").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect!(
    @regexp.compile!("[a-z]*?").matches("abc"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
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

test "should match email address" {
  inspect!(
    @regexp.compile!(
      "^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$",
    ).matches("123456@test.com"),
    content=
      #|{success: true, captures: ["123456@test.com", "123456", "test.com"], named_captures: {"addr": "123456", "host": "test.com"}}
    ,
  )
}

test "should handle NotSingle and NotSingleRepeat" {
  inspect!(
    @regexp.compile!(".").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  
  inspect!(
    @regexp.compile!("[^a]").matches("b"),
    content=
      #|{success: true, captures: ["b"], named_captures: {}}
    ,
  )
  
  // Testing NotSingleRepeat
  inspect!(
    @regexp.compile!(".{2}").matches("ab"),
    content=
      #|{success: true, captures: ["ab"], named_captures: {}}
    ,
  )
  
  inspect!(
    @regexp.compile!(".{2}").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should handle NotSingleLoop" {
  inspect!(
    @regexp.compile!("[^a]*").matches("bcd"),
    content=
      #|{success: true, captures: ["bcd"], named_captures: {}}
    ,
  )
  
  inspect!(
    @regexp.compile!("[^a]+").matches("bcd"),
    content=
      #|{success: true, captures: ["bcd"], named_captures: {}}
    ,
  )
  
  inspect!(
    @regexp.compile!("[^a]+").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

test "should handle special captures and complex patterns" {
  inspect!(
    @regexp.compile!("(a|ab)(bc|c)").matches("abc"),
    content=
      #|{success: true, captures: ["abc", "a", "bc"], named_captures: {}}
    ,
  )
  
  // Test backreferences
  // inspect!(
  //   @regexp.compile!("(\\w+)\\s+\\1").matches("hello hello"),
  //   content=
  //     #|{success: true, captures: ["hello hello", "hello"], named_captures: {}}
  //   ,
  // )
  
  // Test special chars in character classes
  // inspect!(
  //   @regexp.compile!("[-]").matches("-"),
  //   content=
  //     #|{success: true, captures: ["-"], named_captures: {}}
  //   ,
  // )
  
  // Test complex loop targets
  inspect!(
    @regexp.compile!("(ab)+").matches("ababab"),
    content=
      #|{success: true, captures: ["ababab", "ab"], named_captures: {}}
    ,
  )
  
  // inspect!(
  //   @regexp.compile!("(a{1,3}?)(a{1,3}?)").matches("aaa"),
  //   content=
  //     #|{success: true, captures: ["aaa", "a", "aa"], named_captures: {}}
  //   ,
  // )
}

test "should handle NullMark and other special opcodes" {
  // Using loop repetition which should trigger NullMark
  inspect!(
    @regexp.compile!("(abc)*def").matches("abcabcdef"),
    content=
      #|{success: true, captures: ["abcabcdef", "abc"], named_captures: {}}
    ,
  )
  
  inspect!(
    @regexp.compile!("(abc)*def").matches("def"),
    content=
      #|{success: true, captures: ["def", ""], named_captures: {}}
    ,
  )
  
  // This should test BranchMark in backtracking
  inspect!(
    @regexp.compile!("(a*)(b*)").matches("aaabbb"),
    content=
      #|{success: true, captures: ["aaabbb", "aaa", "bbb"], named_captures: {}}
    ,
  )
  
  // This tests BranchMark with BacktrackingBranch
  inspect!(
    @regexp.compile!("(a*)(a*)b").matches("aaab"),
    content=
      #|{success: true, captures: ["aaab", "aaa", ""], named_captures: {}}
    ,
  )
}

// test "should handle debug_info" {
//   let re = @regexp.compile!("abc.*")
//   let result = re.debug_info()
//   inspect!(result.length() > 0, content=#|true
//   )
// }
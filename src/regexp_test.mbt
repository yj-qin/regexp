///|
test "should match single" {
  inspect(
    @regexp.compile("a").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("d").matches("abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match escape" {
  inspect(
    @regexp.compile("\\d").matches("123"),
    content=
      #|{success: true, captures: ["1"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\d").matches("abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\D").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\D").matches("123"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\w").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\w").matches(" "),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\W").matches(" "),
    content=
      #|{success: true, captures: [" "], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\W").matches("abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\s").matches(" "),
    content=
      #|{success: true, captures: [" "], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\s").matches("123"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\S").matches("123"),
    content=
      #|{success: true, captures: ["1"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\S").matches(" "),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\n").matches("a\nb"),
    content=
      #|{success: true, captures: ["\n"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\r").matches("a\rb"),
    content=
      #|{success: true, captures: ["\r"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\t").matches("a\tb"),
    content=
      #|{success: true, captures: ["\t"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\v").matches("a\u000Bb"),
    content=
      #|{success: true, captures: ["\u{0b}"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("\\f").matches("a\u000Cb"),
    content=
      #|{success: true, captures: ["\u{0c}"], named_captures: {}}
    ,
  )
}

///|
test "should match concat" {
  inspect(
    @regexp.compile("cde").matches("abcdef"),
    content=
      #|{success: true, captures: ["cde"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("efg").matches("abcdef"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match alt" {
  inspect(
    @regexp.compile("a|b|c").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a|b|c").matches("b"),
    content=
      #|{success: true, captures: ["b"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a|b|c").matches("c"),
    content=
      #|{success: true, captures: ["c"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a|b|c").matches("d"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match class" {
  inspect(
    @regexp.compile("[abc]").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[abc]").matches("d"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[^abc]").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[^abc]").matches("d"),
    content=
      #|{success: true, captures: ["d"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[a-zA-Z]").matches("A"),
    content=
      #|{success: true, captures: ["A"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[a-zA-Z]").matches("0"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match escape class" {
  inspect(
    @regexp.compile("[\\d]+").matches("abc123"),
    content=
      #|{success: true, captures: ["123"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[\\D]+").matches("abc123"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[\\s]+").matches("123 abc"),
    content=
      #|{success: true, captures: [" "], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[\\S]+").matches("123 abc"),
    content=
      #|{success: true, captures: ["123"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[\\w]+").matches("123abc"),
    content=
      #|{success: true, captures: ["123abc"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[\\W]+").matches("123abc"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match class repeat" {
  inspect(
    @regexp.compile("[a-z]{3}").matches("abc"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[a-z]{3}").matches("ab"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match class loop" {
  inspect(
    @regexp.compile("[a-z]*").matches("abc"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[a-z]*").matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[a-z]*").matches("123"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match class lazy loop" {
  inspect(
    @regexp.compile("[a-z]+?").matches("abc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[a-z]*?").matches("abc"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match assert" {
  inspect(
    @regexp.compile("^abc").matches("abcdef"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("^def").matches("abcdef"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("abc$").matches("abcdef"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("def$").matches("abcdef"),
    content=
      #|{success: true, captures: ["def"], named_captures: {}}
    ,
  )
}

///|
test "should match one or more" {
  inspect(
    @regexp.compile("a+").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a+").matches("b"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match zero or more" {
  inspect(
    @regexp.compile("a*").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a*").matches("b"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match zero or one" {
  inspect(
    @regexp.compile("a?").matches("aaa"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a?").matches("b"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should match quantifier" {
  inspect(
    @regexp.compile("a{2}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{2}").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{1,2}").matches(""),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{1,2}").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{1,2}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{2,}").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{2,}").matches("aa"),
    content=
      #|{success: true, captures: ["aa"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a{2,}").matches("aaaaaaaaaaaaa"),
    content=
      #|{success: true, captures: ["aaaaaaaaaaaaa"], named_captures: {}}
    ,
  )
}

///|
test "should match non-greedy" {
  inspect(
    @regexp.compile("a*?").matches("aaabc"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a+?").matches("aaabc"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("a??").matches("aaabc"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("<.*?>").matches("<foo> <bar> new </bar> </foo>"),
    content=
      #|{success: true, captures: ["<foo>"], named_captures: {}}
    ,
  )
}

///|
test "should match group" {
  inspect(
    @regexp.compile("(abc)|(def)").matches("def"),
    content=
      #|{success: true, captures: ["def", "", "def"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("(a*)bc").matches("aaaaabc"),
    content=
      #|{success: true, captures: ["aaaaabc", "aaaaa"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("(Hello, (?<name>[a-zA-Z]{2,}))! Welcome!").matches(
      "Hello, John! Welcome!",
    ),
    content=
      #|{success: true, captures: ["Hello, John! Welcome!", "Hello, John", "John"], named_captures: {"name": "John"}}
    ,
  )
}

///|
test "should match email address" {
  inspect(
    @regexp.compile(
      "^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$",
    ).matches("123456@test.com"),
    content=
      #|{success: true, captures: ["123456@test.com", "123456", "test.com"], named_captures: {"addr": "123456", "host": "test.com"}}
    ,
  )
}

///|
test "should handle NotSingle and NotSingleRepeat" {
  inspect(
    @regexp.compile(".").matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[^a]").matches("b"),
    content=
      #|{success: true, captures: ["b"], named_captures: {}}
    ,
  )

  // Testing NotSingleRepeat
  inspect(
    @regexp.compile(".{2}").matches("ab"),
    content=
      #|{success: true, captures: ["ab"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile(".{2}").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle NotSingleLoop" {
  inspect(
    @regexp.compile("[^a]*").matches("bcd"),
    content=
      #|{success: true, captures: ["bcd"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[^a]+").matches("bcd"),
    content=
      #|{success: true, captures: ["bcd"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("[^a]+").matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle special captures and complex patterns" {
  inspect(
    @regexp.compile("(a|ab)(bc|c)").matches("abc"),
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
  inspect(
    @regexp.compile("(ab)+").matches("ababab"),
    content=
      #|{success: true, captures: ["ababab", "ab"], named_captures: {}}
    ,
  )
}

///|
test {
  inspect(
    @regexp.compile("(a{1,3}?)(a{1,3}?)").matches("aaa"),
    content=
      #|{success: true, captures: ["aa", "a", "a"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("(a{1,3}?)(a{1,3}?)$").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa", "a", "aa"], named_captures: {}}
    ,
  )
}

///|
test "should handle NullMark and other special opcodes" {
  // Using loop repetition which should trigger NullMark
  inspect(
    @regexp.compile("(abc)*def").matches("abcabcdef"),
    content=
      #|{success: true, captures: ["abcabcdef", "abc"], named_captures: {}}
    ,
  )
  inspect(
    @regexp.compile("(abc)*def").matches("def"),
    content=
      #|{success: true, captures: ["def", ""], named_captures: {}}
    ,
  )

  // This should test BranchMark in backtracking
  inspect(
    @regexp.compile("(a*)(b*)").matches("aaabbb"),
    content=
      #|{success: true, captures: ["aaabbb", "aaa", "bbb"], named_captures: {}}
    ,
  )

  // This tests BranchMark with BacktrackingBranch
  inspect(
    @regexp.compile("(a*)(a*)b").matches("aaab"),
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

///|
test "should access regexp pattern" {
  let re = @regexp.compile("abc.*")
  inspect(re.pattern(), content="abc.*")
}

///|
test "should access match result captures" {
  let result = @regexp.compile("(a)(b)(c)").matches("abc")
  let captures = result.captures()
  inspect(
    captures,
    content=
      #|["abc", "a", "b", "c"]
    ,
  )
}

///|
test "should handle BranchCount and BranchCountLazy opcodes" {
  // This pattern will use BranchCount when compiled
  let re = @regexp.compile("(?:abc){2,5}")
  inspect(
    re.matches("abcabc"),
    content=
      #|{success: true, captures: ["abcabc"], named_captures: {}}
    ,
  )

  // This pattern will use BranchCountLazy when compiled
  let re_lazy = @regexp.compile("(?abc){2,5}?")
  inspect(
    re_lazy.matches("abcabcabc"),
    content=
      #|{success: true, captures: ["abcabc", "abc"], named_captures: {}}
    ,
  )
}

///|
test "should handle NotSingleLoop opcode" {
  // This pattern uses NotSingleLoop to match any character except 'a' repeated
  let re = @regexp.compile("[^a]+")
  inspect(
    re.matches("bcde"),
    content=
      #|{success: true, captures: ["bcde"], named_captures: {}}
    ,
  )

  // Test that it fails when only 'a' is present
  inspect(
    re.matches("a"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )

  // Test with mixed content
  inspect(
    re.matches("bcadef"),
    content=
      #|{success: true, captures: ["bc"], named_captures: {}}
    ,
  )
}

///|
test "should handle ClassLazy opcode" {
  // This pattern uses ClassLazy to match classes lazily
  let re = @regexp.compile("[a-z]{1,5}?")
  inspect(
    re.matches("abcde"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )

  // Test that it keeps matching when forced to by the pattern
  let re2 = @regexp.compile("[a-z]{1,5}?c")
  inspect(
    re2.matches("abc"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )
}

///|
test "should handle NullMark in simple capture" {
  // This should use NullMark internally
  let re = @regexp.compile("(a*)")
  inspect(
    re.matches(""),
    content=
      #|{success: true, captures: ["", ""], named_captures: {}}
    ,
  )
}

///|
test "should handle BranchMark in captures" {
  // This should use BranchMark
  let re = @regexp.compile("(a*)(b)")
  inspect(
    re.matches("aaab"),
    content=
      #|{success: true, captures: ["aaab", "aaa", "b"], named_captures: {}}
    ,
  )
}

///|
test "should handle NotSingleRepeat opcode" {
  // This tests NotSingleRepeat
  let re = @regexp.compile("[^a]{2}")
  inspect(
    re.matches("bc"),
    content=
      #|{success: true, captures: ["bc"], named_captures: {}}
    ,
  )

  // Test failure case
  inspect(
    re.matches("ac"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle SetCount and related count operations" {
  // This should use SetCount for quantifiers with min > 1
  let re = @regexp.compile("a{3,5}")
  inspect(
    re.matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )

  // Test with exact count
  let re2 = @regexp.compile("a{3}")
  inspect(
    re2.matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )

  // Test with min=0
  let re3 = @regexp.compile("a{0,3}")
  inspect(
    re3.matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle BranchMarkLazy opcode" {
  // This uses lazy matching with BranchMarkLazy
  let re = @regexp.compile("(a*?)b")
  inspect(
    re.matches("aaab"),
    content=
      #|{success: true, captures: ["aaab", "aaa"], named_captures: {}}
    ,
  )
}

///|
test "should handle NullCount opcode" {
  // This should use NullCount
  let re = @regexp.compile("(a{0,5})")
  inspect(
    re.matches(""),
    content=
      #|{success: true, captures: ["", ""], named_captures: {}}
    ,
  )
}

///|
test "should handle fixed quantifiers in classes" {
  // This should use ClassRepeat for matching char classes with specific lengths
  let re = @regexp.compile("[0-9]{3}")
  inspect(
    re.matches("123"),
    content=
      #|{success: true, captures: ["123"], named_captures: {}}
    ,
  )

  // Test with min/max range
  let re2 = @regexp.compile("[0-9]{2,4}")
  inspect(
    re2.matches("123"),
    content=
      #|{success: true, captures: ["123"], named_captures: {}}
    ,
  )

  // Test with unbounded max
  let re3 = @regexp.compile("[0-9]{2,}")
  inspect(
    re3.matches("12345"),
    content=
      #|{success: true, captures: ["12345"], named_captures: {}}
    ,
  )
}

///|
test "should handle dash in character classes" {
  // This should test dash in character classes
  let re = @regexp.compile("[-a]")
  inspect(
    re.matches("-"),
    content=
      #|{success: true, captures: ["-"], named_captures: {}}
    ,
  )
}

///|
test "should handle complex repetition cases" {
  // Test with lazy matching of NotSingleLoop
  let re = @regexp.compile("[^a]*?")
  inspect(
    re.matches("bcd"),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )

  // Test with ClassLazy and multiple matches
  let re2 = @regexp.compile("[0-9]+?[a-z]")
  inspect(
    re2.matches("123a456b"),
    content=
      #|{success: true, captures: ["123a"], named_captures: {}}
    ,
  )

  // Test with SingleLazy and backtracking
  let re3 = @regexp.compile("a+?b")
  inspect(
    re3.matches("aab"),
    content=
      #|{success: true, captures: ["aab"], named_captures: {}}
    ,
  )
}

///|
test "should handle non-capturing groups with explicit flags" {
  // Test non-capturing group with a colon
  let re = @regexp.compile("(?:abc)")
  inspect(
    re.matches("abc"),
    content=
      #|{success: true, captures: ["abc"], named_captures: {}}
    ,
  )

  // Test non-capturing group with alternation
  let re2 = @regexp.compile("(?:a|b)c")
  inspect(
    re2.matches("ac"),
    content=
      #|{success: true, captures: ["ac"], named_captures: {}}
    ,
  )
  inspect(
    re2.matches("bc"),
    content=
      #|{success: true, captures: ["bc"], named_captures: {}}
    ,
  )
}

///|
test "should handle complex character classes" {
  // Test character class with ranges and individual characters
  let re = @regexp.compile("[a-z0-9_]")
  inspect(
    re.matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    re.matches("5"),
    content=
      #|{success: true, captures: ["5"], named_captures: {}}
    ,
  )
  inspect(
    re.matches("_"),
    content=
      #|{success: true, captures: ["_"], named_captures: {}}
    ,
  )

  // Test inverted class
  let re2 = @regexp.compile("[^0-9]")
  inspect(
    re2.matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    re2.matches("5"),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle named captures" {
  let re = @regexp.compile("(?<name>a)")
  let result = re.matches("a")
  inspect(
    result,
    content=
      #|{success: true, captures: ["a", "a"], named_captures: {"name": "a"}}
    ,
  )
}

///|
test "panic UnmatchedGroupEnd" {
  let _ = @regexp.compile("a)")

}

///|
test "panic UnmatchedCharClassEnd" {
  let _ = @regexp.compile("a]")

}

///|
test "panic UnspecifiedLoopTarget" {
  let _ = @regexp.compile("*")

}

///|
test "panic InvalidLoop" {
  let _ = @regexp.compile("a{}")

}

///|
test "panic LoopCountOutOfRange" {
  let _ = @regexp.compile("a{999999999}")

}

///|
test "panic LoopMaxCountSmallerThanMinCount" {
  let _ = @regexp.compile("a{5,3}")

}

///|
test "panic UnmatchedGroupBegin" {
  let _ = @regexp.compile("(")

}

///|
test "panic EmptyGroupName" {
  let _ = @regexp.compile("(?<>a)")

}

///|
test "panic EmptyGroup" {
  let _ = @regexp.compile("()")

}

///|
test "panic GroupMissingParen" {
  let _ = @regexp.compile("(abc")

}

///|
test "panic UnmatchedGroupName" {
  let _ = @regexp.compile("(?<name")

}

///|
test "panic ClassMissingBracket" {
  let _ = @regexp.compile("[abc")

}

///|
test "panic EndPatternAtEscape" {
  let _ = @regexp.compile("\\")

}

///|
test "should handle empty pattern alternation" {
  let re = @regexp.compile("a|")
  inspect(
    re.matches("a"),
    content=
      #|{success: true, captures: ["a"], named_captures: {}}
    ,
  )
  inspect(
    re.matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle empty pattern" {
  let re = @regexp.compile("")
  inspect(
    re.matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )
}

///|
test "should handle escaped special characters in character classes" {
  let re = @regexp.compile("[\\t\\r\\n]")
  inspect(
    re.matches("\t"),
    content=
      #|{success: true, captures: ["\t"], named_captures: {}}
    ,
  )
  inspect(
    re.matches("\r"),
    content=
      #|{success: true, captures: ["\r"], named_captures: {}}
    ,
  )
  inspect(
    re.matches("\n"),
    content=
      #|{success: true, captures: ["\n"], named_captures: {}}
    ,
  )
}

///|
test "should handle custom escape characters in character classes" {
  // Test with a custom escape character in a character class
  let re = @regexp.compile("[\\x]")
  inspect(
    re.matches("x"),
    content=
      #|{success: true, captures: ["x"], named_captures: {}}
    ,
  )
}

///|
test "should handle backslashed characters in character classes" {
  let re = @regexp.compile("[\\\\]")
  inspect(
    re.matches("\\"),
    content=
      #|{success: true, captures: ["\\"], named_captures: {}}
    ,
  )
}

///|
test "should handle escape sequences within character classes" {
  // Test backslash within character class
  inspect(
    @regexp.compile("[\\\\abc]").matches("\\"),
    content=
      #|{success: true, captures: ["\\"], named_captures: {}}
    ,
  )

  // Test hyphen at the end of character class
  inspect(
    @regexp.compile("[abc-]").matches("-"),
    content=
      #|{success: true, captures: ["-"], named_captures: {}}
    ,
  )

  // Test caret not at the beginning
  inspect(
    @regexp.compile("[a^b]").matches("^"),
    content=
      #|{success: true, captures: ["^"], named_captures: {}}
    ,
  )
}

///|
test "should handle nested groups with quantifiers" {
  // Test nested capturing groups
  inspect(
    @regexp.compile("((a)b(c))").matches("abc"),
    content=
      #|{success: true, captures: ["abc", "abc", "a", "c"], named_captures: {}}
    ,
  )

  // Test nested groups with quantifiers
  inspect(
    @regexp.compile("((a+)b)+").matches("abaab"),
    content=
      #|{success: true, captures: ["abaab", "aab", "aa"], named_captures: {}}
    ,
  )
}

///|
test "should handle complex alternations" {
  // Test alternation with empty options
  inspect(
    @regexp.compile("a||b").matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )

  // Test alternation with groups
  inspect(
    @regexp.compile("(a|b)(c|d)").matches("ac"),
    content=
      #|{success: true, captures: ["ac", "a", "c"], named_captures: {}}
    ,
  )

  // Test alternation with different lengths
  inspect(
    @regexp.compile("abc|ab|a").matches("ab"),
    content=
      #|{success: true, captures: ["ab"], named_captures: {}}
    ,
  )
}

///|
test "should handle boundary cases for quantifiers" {
  // Test zero-width quantifier
  inspect(
    @regexp.compile("a{0}").matches(""),
    content=
      #|{success: true, captures: [""], named_captures: {}}
    ,
  )

  // Test minimum boundary
  inspect(
    @regexp.compile("a{1,}").matches(""),
    content=
      #|{success: false, captures: [""], named_captures: {}}
    ,
  )

  // Test exact boundary
  inspect(
    @regexp.compile("a{3,3}").matches("aaa"),
    content=
      #|{success: true, captures: ["aaa"], named_captures: {}}
    ,
  )
}

///|
test "should handle named captures with complex patterns" {
  // Test multiple named captures
  inspect(
    @regexp.compile("(?<first>a+)(?<second>b+)").matches("aabb"),
    content=
      #|{success: true, captures: ["aabb", "aa", "bb"], named_captures: {"first": "aa", "second": "bb"}}
    ,
  )

  // Test nested named captures
  inspect(
    @regexp.compile("(?<outer>a(?<inner>b+)c)").matches("abbc"),
    content=
      #|{success: true, captures: ["abbc", "abbc", "bb"], named_captures: {"outer": "abbc", "inner": "bb"}}
    ,
  )
}

///|
test "should handle complex nested groups with lookahead and quantifiers" {
  // Complex nested groups
  inspect(
    @regexp.compile("((a{2,3})b+)*(c?)").matches("aabaabc"),
    content=
      #|{success: true, captures: ["aabaabc", "aab", "aa", "c"], named_captures: {}}
    ,
  )

  // Multiple groups with alternations
  inspect(
    @regexp.compile("(a|b)*c((d|e){2,3})(f|g)?").matches("abcddef"),
    content=
      #|{success: true, captures: ["abcddef", "b", "dde", "e", "f"], named_captures: {}}
    ,
  )
}

///|
test "should handle complex named captures with nested groups" {
  // Nested named captures with quantifiers
  inspect(
    @regexp.compile("(?<outer>a(?<middle>b(?<inner>c{1,2})d)*e)f").matches(
      "abcdbcdef",
    ),
    content=
      #|{success: true, captures: ["abcdbcdef", "abcdbcde", "bcd", "c"], named_captures: {"outer": "abcdbcde", "middle": "bcd", "inner": "c"}}
    ,
  )

  // Multiple named captures with alternations
  inspect(
    @regexp.compile("(?<first>[0-9]+)(?<sep>[,-]?)(?<second>[a-z]+)").matches(
      "123-abc",
    ),
    content=
      #|{success: true, captures: ["123-abc", "123", "-", "abc"], named_captures: {"first": "123", "sep": "-", "second": "abc"}}
    ,
  )
}

///|
test "should handle complex lazy and greedy quantifier interactions" {
  // Lazy and greedy quantifier combinations
  inspect(
    @regexp.compile("(a+?b+)(a+b+?)").matches("aabaaab"),
    content=
      #|{success: true, captures: ["aabaaab", "aab", "aaab"], named_captures: {}}
    ,
  )

  // Nested lazy quantifiers
  inspect(
    @regexp.compile("(a*?b+?)*(c*?)").matches("ababc"),
    content=
      #|{success: true, captures: ["abab", "ab", ""], named_captures: {}}
    ,
  )
}

///|
test "should handle complex boundary conditions" {
  // Mixed boundary conditions
  inspect(
    @regexp.compile("^([a-z]+?)([0-9]+)$").matches("abc123"),
    content=
      #|{success: true, captures: ["abc123", "abc", "123"], named_captures: {}}
    ,
  )

  // Empty matches within groups
  inspect(
    @regexp.compile("(a*)(b*)(c*)").matches(""),
    content=
      #|{success: true, captures: ["", "", "", ""], named_captures: {}}
    ,
  )
}

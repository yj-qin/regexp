fn test_emit(ast : Ast) -> Program {
  Emitter::new(ast).emit()
}

test "should emit single" {
  inspect(
    test_parse("a")? |> test_emit(),
    content=
      #|0 BranchLazy 7
      #|2 SetMark
      #|3 Single 'a'
      #|5 CaptureMark 0
      #|7 Stop
      #|
    ,
  )?
}

test "should emit concat" {
  inspect(
    test_parse("abc")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 Single 'a'
      #|5 Single 'b'
      #|7 Single 'c'
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
}

test "should emit alt" {
  inspect(
    test_parse("a|b|c")? |> test_emit(),
    content=
      #|0 BranchLazy 19
      #|2 SetMark
      #|3 BranchLazy 9
      #|5 Single 'a'
      #|7 Goto 17
      #|9 BranchLazy 15
      #|11 Single 'b'
      #|13 Goto 17
      #|15 Single 'c'
      #|17 CaptureMark 0
      #|19 Stop
      #|
    ,
  )?
}

test "should emit loop" {
  inspect(
    test_parse("a*")? |> test_emit(),
    content=
      #|0 BranchLazy 8
      #|2 SetMark
      #|3 SingleLoop 'a' 2147483647
      #|6 CaptureMark 0
      #|8 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a+")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 SingleRepeat 'a' 1
      #|6 SingleLoop 'a' 2147483647
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a?")? |> test_emit(),
    content=
      #|0 BranchLazy 8
      #|2 SetMark
      #|3 SingleLoop 'a' 1
      #|6 CaptureMark 0
      #|8 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a{3}")? |> test_emit(),
    content=
      #|0 BranchLazy 8
      #|2 SetMark
      #|3 SingleRepeat 'a' 3
      #|6 CaptureMark 0
      #|8 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a{1,3}")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 SingleRepeat 'a' 1
      #|6 SingleLoop 'a' 2
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a{1,}")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 SingleRepeat 'a' 1
      #|6 SingleLoop 'a' 2147483647
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a*?")? |> test_emit(),
    content=
      #|0 BranchLazy 8
      #|2 SetMark
      #|3 SingleLazy 'a' 2147483647
      #|6 CaptureMark 0
      #|8 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a+?")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 SingleRepeat 'a' 1
      #|6 SingleLazy 'a' 2147483647
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a??")? |> test_emit(),
    content=
      #|0 BranchLazy 8
      #|2 SetMark
      #|3 SingleLazy 'a' 1
      #|6 CaptureMark 0
      #|8 Stop
      #|
    ,
  )?
  inspect(
    test_parse("a{1,2}?")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 SingleRepeat 'a' 1
      #|6 SingleLazy 'a' 1
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
}

test "should emit class" {
  inspect(
    test_parse("[abc]")? |> test_emit(),
    content=
      #|0 BranchLazy 7
      #|2 SetMark
      #|3 Class [abc]
      #|5 CaptureMark 0
      #|7 Stop
      #|
    ,
  )?
  inspect(
    test_parse("[^abc]")? |> test_emit(),
    content=
      #|0 BranchLazy 7
      #|2 SetMark
      #|3 Class [^abc]
      #|5 CaptureMark 0
      #|7 Stop
      #|
    ,
  )?
  inspect(
    test_parse("[a-zA-Z0-9]")? |> test_emit(),
    content=
      #|0 BranchLazy 7
      #|2 SetMark
      #|3 Class [a-zA-Z0-9]
      #|5 CaptureMark 0
      #|7 Stop
      #|
    ,
  )?
}

test "should emit group" {
  inspect(
    test_parse("(abc)")? |> test_emit(),
    content=
      #|0 BranchLazy 14
      #|2 SetMark
      #|3 SetMark
      #|4 Single 'a'
      #|6 Single 'b'
      #|8 Single 'c'
      #|10 CaptureMark 1
      #|12 CaptureMark 0
      #|14 Stop
      #|
    ,
  )?
  inspect(
    test_parse("((a)bc)")? |> test_emit(),
    content=
      #|0 BranchLazy 17
      #|2 SetMark
      #|3 SetMark
      #|4 SetMark
      #|5 Single 'a'
      #|7 CaptureMark 2
      #|9 Single 'b'
      #|11 Single 'c'
      #|13 CaptureMark 1
      #|15 CaptureMark 0
      #|17 Stop
      #|
    ,
  )?
  inspect(
    test_parse("((a)|(b))")? |> test_emit(),
    content=
      #|0 BranchLazy 22
      #|2 SetMark
      #|3 SetMark
      #|4 BranchLazy 13
      #|6 SetMark
      #|7 Single 'a'
      #|9 CaptureMark 2
      #|11 Goto 18
      #|13 SetMark
      #|14 Single 'b'
      #|16 CaptureMark 3
      #|18 CaptureMark 1
      #|20 CaptureMark 0
      #|22 Stop
      #|
    ,
  )?
}

test "should emit non-capturing group" {
  inspect(
    test_parse("(?:abc)")? |> test_emit(),
    content=
      #|0 BranchLazy 11
      #|2 SetMark
      #|3 Single 'a'
      #|5 Single 'b'
      #|7 Single 'c'
      #|9 CaptureMark 0
      #|11 Stop
      #|
    ,
  )?
}

test "should emit named group" {
  inspect(
    test_parse("(?<group1>abc)")? |> test_emit(),
    content=
      #|0 BranchLazy 14
      #|2 SetMark
      #|3 SetMark
      #|4 Single 'a'
      #|6 Single 'b'
      #|8 Single 'c'
      #|10 CaptureMark 1
      #|12 CaptureMark 0
      #|14 Stop
      #|
    ,
  )?
}

test "should emit common pattern" {
  let ast = test_parse("^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$")?
  inspect(
    test_emit(ast),
    content=
      #|0 BranchLazy 35
      #|2 SetMark
      #|3 BeginOfInput
      #|4 SetMark
      #|5 ClassRepeat [a-zA-Z0-9._%+-] 1
      #|8 ClassLoop [a-zA-Z0-9._%+-] 2147483647
      #|11 CaptureMark 1
      #|13 Single '@'
      #|15 SetMark
      #|16 ClassRepeat [a-zA-Z0-9.-] 1
      #|19 ClassLoop [a-zA-Z0-9.-] 2147483647
      #|22 Single '.'
      #|24 ClassRepeat [a-zA-Z] 2
      #|27 ClassLoop [a-zA-Z] 2147483647
      #|30 CaptureMark 2
      #|32 EndOfInput
      #|33 CaptureMark 0
      #|35 Stop
      #|
    ,
  )?
}

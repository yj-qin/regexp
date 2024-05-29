fn test_emit(ast: Ast) -> Program {
  Emitter::new(ast).emit()
}
test "should emit single" {
  inspect(test_parse("a")? |> test_emit(), content=
    #|0 BranchLazy 4
    #|2 Single 'a'
    #|4 Stop
    #|
  )?
}

test "should emit concat" {
  inspect(test_parse("abc")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 Single 'a'
    #|4 Single 'b'
    #|6 Single 'c'
    #|8 Stop
    #|
  )?
}

test "should emit alt" {
  inspect(test_parse("a|b|c")? |> test_emit(), content=
    #|0 BranchLazy 16
    #|2 BranchLazy 8
    #|4 Single 'a'
    #|6 Goto 16
    #|8 BranchLazy 14
    #|10 Single 'b'
    #|12 Goto 16
    #|14 Single 'c'
    #|16 Stop
    #|
  )?
}

test "should emit loop" {
  inspect(test_parse("a*")? |> test_emit(), content=
    #|0 BranchLazy 5
    #|2 SingleLoop 'a' -1
    #|5 Stop
    #|
  )?
  inspect(test_parse("a+")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 SingleRepeat 'a' 1
    #|5 SingleLoop 'a' -1
    #|8 Stop
    #|
  )?
  inspect(test_parse("a?")? |> test_emit(), content=
    #|0 BranchLazy 5
    #|2 SingleLoop 'a' 1
    #|5 Stop
    #|
  )?
  inspect(test_parse("a{3}")? |> test_emit(), content=
    #|0 BranchLazy 5
    #|2 SingleRepeat 'a' 3
    #|5 Stop
    #|
  )?
  inspect(test_parse("a{1,3}")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 SingleRepeat 'a' 1
    #|5 SingleLoop 'a' 2
    #|8 Stop
    #|
  )?
  inspect(test_parse("a{1,}")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 SingleRepeat 'a' 1
    #|5 SingleLoop 'a' -1
    #|8 Stop
    #|
  )?
  inspect(test_parse("a*?")? |> test_emit(), content=
    #|0 BranchLazy 5
    #|2 SingleLazy 'a' -1
    #|5 Stop
    #|
  )?
  inspect(test_parse("a+?")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 SingleRepeat 'a' 1
    #|5 SingleLazy 'a' -1
    #|8 Stop
    #|
  )?
  inspect(test_parse("a??")? |> test_emit(), content=
    #|0 BranchLazy 5
    #|2 SingleLazy 'a' 1
    #|5 Stop
    #|
  )?
  inspect(test_parse("a{1,2}?")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 SingleRepeat 'a' 1
    #|5 SingleLazy 'a' 1
    #|8 Stop
    #|
  )?
}

test "should emit class" {
  inspect(test_parse("[abc]")? |> test_emit(), content=
    #|0 BranchLazy 4
    #|2 Class [abc]
    #|4 Stop
    #|
  )?
  inspect(test_parse("[^abc]")? |> test_emit(), content=
    #|0 BranchLazy 4
    #|2 Class [^abc]
    #|4 Stop
    #|
  )?
  inspect(test_parse("[a-zA-Z0-9]")? |> test_emit(), content=
    #|0 BranchLazy 4
    #|2 Class [a-zA-Z0-9]
    #|4 Stop
    #|
  )?
}

test "should emit group" {
  inspect(test_parse("(abc)")? |> test_emit(), content=
    #|0 BranchLazy 11
    #|2 SetMark
    #|3 Single 'a'
    #|5 Single 'b'
    #|7 Single 'c'
    #|9 CaptureMark 0
    #|11 Stop
    #|
  )?
  inspect(test_parse("((a)bc)")? |> test_emit(), content=
    #|0 BranchLazy 14
    #|2 SetMark
    #|3 SetMark
    #|4 Single 'a'
    #|6 CaptureMark 1
    #|8 Single 'b'
    #|10 Single 'c'
    #|12 CaptureMark 0
    #|14 Stop
    #|
  )?
  inspect(test_parse("((a)|(b))")? |> test_emit(), content=
    #|0 BranchLazy 19
    #|2 SetMark
    #|3 BranchLazy 12
    #|5 SetMark
    #|6 Single 'a'
    #|8 CaptureMark 1
    #|10 Goto 17
    #|12 SetMark
    #|13 Single 'b'
    #|15 CaptureMark 2
    #|17 CaptureMark 0
    #|19 Stop
    #|
  )?
}

test "should emit non-capturing group" {
  inspect(test_parse("(?:abc)")? |> test_emit(), content=
    #|0 BranchLazy 8
    #|2 Single 'a'
    #|4 Single 'b'
    #|6 Single 'c'
    #|8 Stop
    #|
  )?
}

test "should emit named group" {
  inspect(test_parse("(?<group1>abc)")? |> test_emit(), content=
    #|0 BranchLazy 11
    #|2 SetMark
    #|3 Single 'a'
    #|5 Single 'b'
    #|7 Single 'c'
    #|9 CaptureMark 0
    #|11 Stop
    #|
  )?
}

test "should emit common pattern" {
  let ast = test_parse("^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$")?
  inspect(test_emit(ast), content=
    #|0 BranchLazy 32
    #|2 BeginOfInput
    #|3 SetMark
    #|4 ClassRepeat [a-zA-Z0-9._%+-] 1
    #|7 ClassLoop [a-zA-Z0-9._%+-] -1
    #|10 CaptureMark 0
    #|12 Single '@'
    #|14 SetMark
    #|15 ClassRepeat [a-zA-Z0-9.-] 1
    #|18 ClassLoop [a-zA-Z0-9.-] -1
    #|21 Single '.'
    #|23 ClassRepeat [a-zA-Z] 2
    #|26 ClassLoop [a-zA-Z] -1
    #|29 CaptureMark 1
    #|31 EndOfInput
    #|32 Stop
    #|
  )?
}
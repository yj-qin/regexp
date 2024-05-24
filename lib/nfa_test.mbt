test "nfa" {
  let ast = p("([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})")?
  inspect(Nfa::new(ast), content=
    #|0. State #0 START
    #|	CaptureStart(index=0) -> State #1
    #|1. State #1
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 95, 95, 37, 37, 43, 43, 45, 45]) -> State #2
    #|2. State #2
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 95, 95, 37, 37, 43, 43, 45, 45]) -> State #2
    #|	CaptureEnd(index=0) -> State #3
    #|3. State #3
    #|	Single(negated=false, chars=[64]) -> State #4
    #|4. State #4
    #|	CaptureStart(index=1) -> State #5
    #|5. State #5
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 45, 45]) -> State #6
    #|6. State #6
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 45, 45]) -> State #6
    #|	Single(negated=false, chars=[46]) -> State #7
    #|7. State #7
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #8
    #|8. State #8
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #9
    #|9. State #9
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #10
    #|	CaptureEnd(index=1) -> State #11
    #|10. State #10
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #10
    #|	CaptureEnd(index=1) -> State #11
    #|11. State #11 END
    #|
  )?
}

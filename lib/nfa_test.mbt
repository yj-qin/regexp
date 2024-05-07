test "nfa" {
  let ast = p("([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})")?
  inspect(Nfa::new(ast), content=
    #|0. State #1 START
    #|	GroupStart(index=0, capture=true) -> State #2
    #|1. State #2
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 95, 95, 37, 37, 43, 43, 45, 45]) -> State #6
    #|2. State #6
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 95, 95, 37, 37, 43, 43, 45, 45]) -> State #6
    #|	GroupEnd(index=0) -> State #4
    #|3. State #4
    #|	Single(negated=false, chars=[64]) -> State #10
    #|4. State #10
    #|	GroupStart(index=1, capture=true) -> State #12
    #|5. State #12
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 45, 45]) -> State #16
    #|6. State #16
    #|	Single(negated=false, chars=[97, 122, 65, 90, 48, 57, 46, 46, 45, 45]) -> State #16
    #|	Single(negated=false, chars=[46]) -> State #20
    #|7. State #20
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #24
    #|8. State #24
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #26
    #|9. State #26
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #28
    #|	GroupEnd(index=1) -> State #14
    #|10. State #28
    #|	Single(negated=false, chars=[97, 122, 65, 90]) -> State #28
    #|	GroupEnd(index=1) -> State #14
    #|11. State #14 END
    #|
  )?
}

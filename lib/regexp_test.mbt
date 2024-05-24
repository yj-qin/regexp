test "matcher" {
  inspect(
    RegExp::new("([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})")?.matches(
      "123456@test.com",
    ),
    content=
      #|Ok({success: true, captures: ["123456@test.com", "123456", "test.com"], capture_name_map: Map::[]})
    ,
  )?
  inspect(
    RegExp::new("abc")?.matches("123abcdef"),
    content=
      #|Ok({success: true, captures: ["abc"], capture_name_map: Map::[]})
    ,
  )?
}

test "catastrophic_backtracking" {
  let re = RegExp::new("^(a+)+$")?
  // FIXME: capture error
  inspect(
    re.matches("aaaaaa"),
    content=
      #|Ok({success: true, captures: ["aaaaaa", ""], capture_name_map: Map::[]})
    ,
  )?
  inspect(
    re.matches("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaX"),
    content=
      #|Ok({success: false, captures: ["", ""], capture_name_map: Map::[]})
    ,
  )?
}

test "matcher" {
  let matcher = Matcher::new("([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})")?
  inspect(matcher.matches("123456@test.com"), content="Ok(true)")?
}
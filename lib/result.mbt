struct MatchResult {
  success : Bool
  captures : Array[String]
  capture_name_map : @map.Map[String, Int]
} derive(Debug, Show)

fn success(self : MatchResult) -> Bool {
  self.success
}

fn cap(self : MatchResult, idx : Int) -> Option[String] {
  if idx < 0 || idx >= self.captures.length() {
    None
  } else {
    Some(self.captures[idx])
  }
}

fn named_cap(self : MatchResult, name : String) -> Option[String] {
  match self.capture_name_map.lookup(name) {
    Some(idx) => Some(self.captures[idx])
    None => None
  }
}

test "get captures" {
  let res = {
    success: true,
    captures: ["111222333", "111", "222", "333"],
    capture_name_map: @map.Map::[("a", 1), ("b", 2), ("c", 3)],
  }
  inspect(res.success(), content="true")?
  inspect(res.cap(0), content="Some(111222333)")?
  inspect(res.cap(1), content="Some(111)")?
  inspect(res.cap(2), content="Some(222)")?
  inspect(res.cap(3), content="Some(333)")?
  inspect(res.cap(-1), content="None")?
  inspect(res.named_cap("a"), content="Some(111)")?
  inspect(res.named_cap("b"), content="Some(222)")?
  inspect(res.named_cap("c"), content="Some(333)")?
  inspect(res.named_cap("d"), content="None")?
}

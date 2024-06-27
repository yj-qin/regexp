struct Match {
  success : Bool
  captures : FixedArray[String]
  capture_name_mapping : Map[String, Int]
} derive(Show)

pub fn success(self : Match) -> Bool {
  self.success
}

pub fn capture(self : Match, idx : Int) -> String? {
  if idx < 0 || idx >= self.captures.length() {
    None
  } else {
    Some(self.captures[idx])
  }
}

pub fn named(self : Match, name : String) -> String? {
  match self.capture_name_mapping.get(name) {
    Some(idx) => Some(self.captures[idx])
    None => None
  }
}

pub fn debug_write(self : Match, buf : Buffer) -> Unit {
  let success = self.success
  buf.write_string("success: \(success)\n")
  let captures = self.captures.to_string()
  buf.write_string("captures: \(captures)\n")
  let mapping = self.capture_name_mapping.to_string()
  buf.write_string("capture_name_mapping: \(mapping)")
}

test "get captures" {
  let res = {
    success: true,
    captures: ["111222333", "111", "222", "333"],
    capture_name_mapping: Map::[("a", 1), ("b", 2), ("c", 3)],
  }
  inspect(res.success(), content="true")?
  inspect(res.capture(0), content="Some(111222333)")?
  inspect(res.capture(1), content="Some(111)")?
  inspect(res.capture(2), content="Some(222)")?
  inspect(res.capture(3), content="Some(333)")?
  inspect(res.capture(-1), content="None")?
  inspect(res.named("a"), content="Some(111)")?
  inspect(res.named("b"), content="Some(222)")?
  inspect(res.named("c"), content="Some(333)")?
  inspect(res.named("d"), content="None")?
}

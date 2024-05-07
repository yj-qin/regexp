struct StringSeq {
  str : String
  mut pos : Int
}

fn pos(self : StringSeq) -> Int {
  self.pos
}

fn set_pos(self : StringSeq, pos : Int) -> Unit {
  self.pos = pos
}

fn more(self : StringSeq) -> Bool {
  self.pos < self.str.length()
}

fn peek(self : StringSeq) -> Char {
  self.str[self.pos]
}

fn eat(self : StringSeq) -> Char {
  let c = self.str[self.pos]
  self.pos += 1
  c
}

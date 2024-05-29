struct CharClass {
  neg : Bool
  ranges : Array[Int]
} derive(Show, Eq)

fn CharClass::new(ranges : Array[Int], neg : Bool) -> CharClass {
  { neg, ranges }
}

fn debug_write(self : CharClass, buf: Buffer) -> Unit {
  buf.write_char('[')
  if self.neg {
    buf.write_char('^')
  }
  for i = 0; i < self.ranges.length(); i = i + 2 {
    let min = self.ranges[i]
    let max = self.ranges[i + 1]
    if min == max {
      buf.write_char(Char::from_int(min))
    } else {
      buf.write_char(Char::from_int(min))
      buf.write_char('-')
      buf.write_char(Char::from_int(max))
    }
  }
  buf.write_char(']')
}

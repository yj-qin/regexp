priv struct CharClass {
  neg : Bool
  ranges : Array[Int]
} derive(Eq)

fn CharClass::new(ranges : Array[Int], neg : Bool) -> CharClass {
  { neg, ranges }
}

fn contains(self : CharClass, char : Int) -> Bool {
  let mut result = false
  for i = 0; i < self.ranges.length(); i = i + 2 {
    let low = self.ranges[i]
    let high = self.ranges[i + 1]
    if char >= low && char <= high {
      result = true
      break
    }
  }
  if self.neg {
    result.not()
  } else {
    result
  }
}

impl Show for CharClass with output(self, logger) -> Unit {
  logger.write_char('[')
  if self.neg {
    logger.write_char('^')
  }
  for i = 0; i < self.ranges.length(); i = i + 2 {
    let min = self.ranges[i]
    let max = self.ranges[i + 1]
    if min == max {
      logger.write_char(Char::from_int(min))
    } else {
      logger.write_char(Char::from_int(min))
      logger.write_char('-')
      logger.write_char(Char::from_int(max))
    }
  }
  logger.write_char(']')
}

fn to_string(self : CharClass) -> String {
  Show::to_string(self)
}

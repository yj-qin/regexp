let internal_parser_err = "internal parser error"

let unmatched_group_begin = "unmatched group begin"

let unmatched_group_end = "unmatched group end"

let unmatched_group_name = "unmatched group name"

let empty_group_name = "empty group name"

let empty_group = "empty group"

let unmatched_char_class_end = "unmatched char class end"

let unspecified_loop_target = "unspecified loop target"

let invalid_loop = "invalid loop"

let loop_count_out_of_range = "loop count out of range"

let loop_max_count_smaller_than_min_count = "loop max count is smaller than min count"

let end_pattern_at_escape = "end pattern at escape"

let class_missing_bracket = "class missing end bracket"

let group_missing_paren = "group missing end paren"

let max_loop_count = 100_000

priv struct Parser {
  pattern : String
  mut pos : Int
  mut pos_mark : Int
  mut group_index : Int
  mut capture_num : Int
  capture_name_mapping : Map[String, Int]
}

fn Parser::new(pattern : String) -> Parser {
  {
    pattern,
    pos: 0,
    pos_mark: 0,
    group_index: 0,
    capture_num: 0,
    capture_name_mapping: {  },
  }
}

fn pos(self : Parser) -> Int {
  self.pos
}

fn rewind(self : Parser, n : Int) -> Unit {
  self.pos -= n
}

fn advance(self : Parser, n : Int) -> Unit {
  self.pos += n
}

fn mark(self : Parser) -> Unit {
  self.pos_mark = self.pos
}

fn restore(self : Parser) -> Unit {
  self.pos = self.pos_mark
}

fn more(self : Parser) -> Bool {
  self.pos < self.pattern.length()
}

fn peek(self : Parser) -> Char {
  if self.more().not() {
    abort("index out of bounds")
  }
  self.pattern[self.pos]
}

fn peek_is(self : Parser, expected : Char) -> Bool {
  if self.more().not() {
    false
  } else {
    self.peek() == expected
  }
}

fn check_exist(self : Parser, c : Char) -> Bool {
  self.mark()
  while self.more() {
    if self.peek_is(c) {
      self.restore()
      return true
    }
    self.advance(1)
  }
  self.restore()
  false
}

fn fetch_unsigned_num(self : Parser) -> Int? {
  let num_buf = Buffer::new()
  loop self.peek() {
    '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' as d => {
      num_buf.write_char(d)
      self.advance(1)
      if self.more() {
        continue self.peek()
      }
    }
    _ => break
  }
  let num_str = num_buf.to_string()
  if num_str == "" {
    return None
  }
  try {
    return Some(@strconv.parse_int!(num_str))
  } catch {
    _ => return None
  }
}

fn parse(self : Parser) -> Ast! {
  let root = AstNode::new(Capture(index=self.group_index))
  self.group_index += 1
  self.capture_num += 1
  root.add_child(self.parse_expr!(false))
  {
    root,
    capture_num: self.capture_num,
    capture_name_mapping: self.capture_name_mapping,
  }
}

fn parse_expr(self : Parser, in_group : Bool) -> AstNode! {
  let node = self.parse_concat!(in_group)
  if self.more().not() || (in_group && self.peek_is(')')) {
    return node
  } else if self.peek_is('|') {
    let alt_node = AstNode::new(Alternate)
    alt_node.add_child(node)
    while self.peek_is('|') {
      self.advance(1) // |
      alt_node.add_child(self.parse_concat!(in_group))
    }
    if in_group.not() && self.more() {
      fail!(internal_parser_err)
    } else {
      alt_node
    }
  } else {
    fail!(internal_parser_err)
  }
}

fn parse_concat(self : Parser, in_group : Bool) -> AstNode! {
  let node = self.parse_node!(in_group)
  if self.more().not() || self.peek_is('|') || (in_group && self.peek_is(')')) {
    node
  } else {
    let concat_node = AstNode::new(Concatenate)
    concat_node.add_child(node)
    while self.more() && self.peek_is('|').not() && (in_group && self.peek_is(
            ')',
          )).not() {
      concat_node.add_child(self.parse_node!(in_group))
    }
    concat_node
  }
}

fn parse_node(self : Parser, in_group : Bool) -> AstNode! {
  if self.more().not() || (in_group && self.peek_is(')')) {
    return AstNode::new(Empty)
  }
  let node = match self.peek() {
    '|' => {
      self.advance(1)
      AstNode::new(Empty)
    }
    '.' => {
      self.advance(1)
      AstNode::new(NotSingle(char='\n'))
    }
    '^' => {
      self.advance(1)
      AstNode::new(BeginOfInput)
    }
    '$' => {
      self.advance(1)
      AstNode::new(EndOfInput)
    }
    '(' => {
      self.advance(1)
      self.parse_group!()
    }
    ')' => fail!(unmatched_group_end)
    '[' => {
      self.advance(1)
      self.parse_class!()
    }
    ']' => fail!(unmatched_char_class_end)
    '*' | '+' | '?' | '{' | '}' => fail!(unspecified_loop_target)
    '\\' => {
      self.advance(1)
      self.parse_escape!()
    }
    _ as char => {
      self.advance(1)
      AstNode::new(Single(~char))
    }
  }
  self.parse_loop!(node)
}

fn parse_loop(self : Parser, target : AstNode) -> AstNode! {
  if self.more().not() {
    return target
  }
  let mut greedy = true
  let mut min = 0
  let mut max : Int? = None
  match self.peek() {
    '*' => self.advance(1)
    '+' => {
      self.advance(1)
      min = 1
    }
    '?' => {
      self.advance(1)
      max = Some(1)
    }
    '{' => {
      self.advance(1)
      let range = self.parse_loop_range!()
      min = range.0
      max = range.1
    }
    _ => return target
  }
  if self.peek_is('?') {
    self.advance(1)
    greedy = false
  }
  match target.internal {
    Single(~char) => AstNode::new(SingleLoop(~char, ~min, ~max, ~greedy))
    NotSingle(~char) => AstNode::new(NotSingleLoop(~char, ~min, ~max, ~greedy))
    Class(~class) => AstNode::new(ClassLoop(~class, ~min, ~max, ~greedy))
    _ => {
      let node = AstNode::new(Loop(~min, ~max, ~greedy))
      node.add_child(target)
      node
    }
  }
}

fn parse_loop_range(self : Parser) -> (Int, Int?)! {
  if self.more().not() {
    fail!(invalid_loop)
  }
  let min = match self.fetch_unsigned_num() {
    Some(v) => v
    None => fail!(invalid_loop)
  }
  if min < 0 || min > max_loop_count {
    fail!(loop_count_out_of_range)
  }
  if self.more().not() {
    fail!(invalid_loop)
  }
  let max : Int? = if self.peek_is(',') {
    self.advance(1) // ','
    self.fetch_unsigned_num()
  } else {
    Some(min)
  }
  if max.is_empty().not() && (max.unwrap() < 0 || max.unwrap() > max_loop_count) {
    fail!(loop_count_out_of_range)
  }
  if self.more().not() || self.peek_is('}').not() {
    fail!(invalid_loop)
  }
  self.advance(1) // '}'
  if max.is_empty().not() && min > max.unwrap() {
    fail!(loop_max_count_smaller_than_min_count)
  }
  (min, max)
}

fn parse_group(self : Parser) -> AstNode! {
  if self.more().not() {
    fail!(unmatched_group_begin)
  }
  let mut capture = true
  let mut name = ""
  let index = self.group_index
  self.group_index += 1
  self.capture_num += 1
  if self.peek_is('?') {
    self.advance(1) // '?'
    match self.peek() {
      ':' => {
        capture = false
        self.capture_num -= 1
        self.advance(1) // ':'
      }
      '<' => {
        name = self.parse_group_name!()
        if name == "" {
          fail!(empty_group_name)
        }
        self.capture_name_mapping.set(name, index)
      }
      _ => ()
    }
  }
  if self.more().not() || self.peek_is(')') {
    fail!(empty_group)
  }
  let node = if capture {
    AstNode::new(Capture(~index))
  } else {
    AstNode::new(Group)
  }
  node.add_child(self.parse_expr!(true))
  if self.more().not() || self.peek_is(')').not() {
    fail!(group_missing_paren)
  }
  self.advance(1) // ')'
  node
}

fn parse_group_name(self : Parser) -> String! {
  self.advance(1) // '<'
  let buf = Buffer::new()
  while self.more() && self.peek_is('>').not() {
    buf.write_char(self.peek())
    self.advance(1)
  }
  if self.peek_is('>').not() {
    fail!(unmatched_group_name)
  }
  self.advance(1) // '>'
  buf.to_string()
}

fn parse_class(self : Parser) -> AstNode! {
  let neg = if self.peek_is('^') {
    self.advance(1)
    true
  } else {
    false
  }
  let ranges : Array[Int] = []
  let mut first = true
  // Allow ']' and '-' as first char in class
  while self.more() && (self.peek_is(']').not() || first) {
    if self.peek_is(']') && first {
      ranges.push(']'.to_int())
      ranges.push(']'.to_int())
      self.advance(1) // ']'
    }
    if self.peek_is('-') && first {
      ranges.push('-'.to_int())
      ranges.push('-'.to_int())
      self.advance(1) // '-'
    }
    first = false
    let low = self.parse_char_class_char!()
    let mut high = low
    if self.more() && self.peek_is('-') {
      self.advance(1) // '-'
      if self.more() && self.peek_is(']') {
        // '-' is the last char
        self.rewind(1)
      } else {
        high = self.parse_char_class_char!()
      }
    }
    ranges.push(low.to_int())
    ranges.push(high.to_int())
  }
  if self.more().not() || self.peek_is(']').not() {
    fail!(class_missing_bracket)
  } else {
    self.advance(1) // ']'
    AstNode::new(Class(class=CharClass::new(ranges, neg)))
  }
}

fn parse_char_class_char(self : Parser) -> Char! {
  if self.more().not() {
    fail!(class_missing_bracket)
  }
  if self.peek_is('\\') {
    self.advance(1)
  }
  let c = self.peek()
  self.advance(1)
  c
}

fn parse_escape(self : Parser) -> AstNode! {
  if self.more().not() {
    fail!(end_pattern_at_escape)
  }
  match self.peek() {
    _ as char => {
      self.advance(1)
      AstNode::new(Single(~char))
    }
  }
}

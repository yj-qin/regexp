let internal_parser_err = "internal parser error"

let unmatched_group_begin = "unmatched group begin"

let unmatched_group_end = "unmatched group end"

let unmatched_group_name = "unmatched group name"

let empty_group_name = "empty group name"

let empty_group = "empty group"

let unmatched_char_class_end = "unmatched char class end"

let unspecified_repeat_target = "unspecified repeat target"

let invalid_repeat_range = "invalid repeat range"

let repeat_num_out_of_range = "repeat num out of range"

let repeat_max_smaller_than_min = "repeat max num is smaller than min num"

let end_pattern_at_escape = "end pattern at escape"

let class_missing_bracket = "class missing end bracket"

let group_missing_paren = "group missing end paren"

let max_repeat_num = 100_000

struct Parser {
  pattern : String
  mut pos : Int
  mut pos_mark : Int
  mut group_index : Int
  mut capture_num : Int
  mut capture_name_map : @map.Map[String, Int]
}

fn Parser::new(pattern : String) -> Parser {
  {
    pattern,
    pos: 0,
    pos_mark: 0,
    group_index: 0,
    capture_num: 0,
    capture_name_map: @map.Map::[],
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

fn fetch_unsigned_num(self : Parser) -> Option[Int] {
  let num_buf = Buffer::make(0)
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
  @strconv.parse_int(num_str).to_option()
}

fn parse(self : Parser) -> Result[Ast, String] {
  let root = self.parse_expr(false)?
  Ok(
    {
      root,
      capture_num: self.capture_num,
      capture_name_map: self.capture_name_map,
    },
  )
}

fn parse_expr(self : Parser, in_group : Bool) -> Result[AstNode, String] {
  let node = self.parse_concat_nodes(in_group)?
  if self.more().not() || in_group && self.peek_is(')') {
    return Ok(node)
  } else if self.peek_is('|') {
    let alt_nodes = [node]
    while self.peek_is('|') {
      self.advance(1) // |
      alt_nodes.push(self.parse_concat_nodes(in_group)?)
    }
    if self.more() {
      Err(internal_parser_err)
    } else {
      Ok(Alt(nodes=alt_nodes))
    }
  } else {
    Err(internal_parser_err)
  }
}

fn parse_concat_nodes(
  self : Parser,
  in_group : Bool
) -> Result[AstNode, String] {
  let node = self.parse_node(in_group)?
  if self.more().not() || self.peek_is('|') || in_group && self.peek_is(')') {
    Ok(node)
  } else {
    let concat_nodes = [node]
    while self.more() && self.peek_is('|').not() && (in_group && self.peek_is(
            ')',
          )).not() {
      let n = self.parse_node(in_group)?
      concat_nodes.push(n)
    }
    Ok(Concat(nodes=concat_nodes))
  }
}

fn parse_node(self : Parser, in_group : Bool) -> Result[AstNode, String] {
  if self.more().not() || in_group && self.peek_is(')') {
    return Ok(Empty)
  }
  let node : AstNode = match self.peek() {
    '|' => {
      self.advance(1)
      Empty
    }
    '.' => {
      self.advance(1)
      Any
    }
    '^' => {
      self.advance(1)
      Assert(kind=BeginOfLine)
    }
    '$' => {
      self.advance(1)
      Assert(kind=EndOfLine)
    }
    '(' => {
      self.advance(1)
      self.parse_group()?
    }
    ')' => return Err(unmatched_group_end)
    '[' => {
      self.advance(1)
      self.parse_class()?
    }
    ']' => return Err(unmatched_char_class_end)
    '*' | '+' | '?' | '{' | '}' => return Err(unspecified_repeat_target)
    '\\' => {
      self.advance(1)
      self.parse_escape()?
    }
    _ as c => {
      self.advance(1)
      Char(char=c.to_int(), escaped=false)
    }
  }
  self.parse_node_repeat(node)
}

fn parse_node_repeat(
  self : Parser,
  target : AstNode
) -> Result[AstNode, String] {
  if self.more().not() {
    return Ok(target)
  }
  let node : AstNode = match self.peek() {
    '*' => {
      self.advance(1)
      Star(~target)
    }
    '+' => {
      self.advance(1)
      Plus(~target)
    }
    '?' => {
      self.advance(1)
      Quest(~target)
    }
    '{' => {
      self.advance(1)
      self.parse_repeat_range(target)?
    }
    _ => target
  }
  Ok(node)
}

fn parse_repeat_range(
  self : Parser,
  target : AstNode
) -> Result[AstNode, String] {
  if self.more().not() {
    return Err(invalid_repeat_range)
  }
  let min = match self.fetch_unsigned_num() {
    Some(v) => v
    None => return Err(invalid_repeat_range)
  }
  if min < 0 || min > max_repeat_num {
    return Err(repeat_num_out_of_range)
  }
  if self.more().not() {
    return Err(invalid_repeat_range)
  }
  let max : Option[Int] = if self.peek_is(',') {
    self.advance(1) // ','
    self.fetch_unsigned_num()
  } else {
    Some(min)
  }
  if max.is_empty().not() && (max.unwrap() < 0 || max.unwrap() > max_repeat_num) {
    return Err(repeat_num_out_of_range)
  }
  if self.more().not() || self.peek_is('}').not() {
    return Err(invalid_repeat_range)
  }
  self.advance(1) // '}'
  if max.is_empty().not() && min > max.unwrap() {
    return Err(repeat_max_smaller_than_min)
  }
  Ok(Repeat(~target, ~min, ~max))
}

fn parse_group(self : Parser) -> Result[AstNode, String] {
  if self.more().not() {
    return Err(unmatched_group_begin)
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
        name = self.parse_group_name()?
        if name == "" {
          return Err(empty_group_name)
        }
        self.capture_name_map = self.capture_name_map.insert(name, index)
      }
      _ => ()
    }
  }
  if self.more().not() || self.peek_is(')') {
    return Err(empty_group)
  }
  let node : AstNode = Group(
    ~index,
    ~capture,
    ~name,
    node=self.parse_expr(true)?,
  )
  if self.more().not() || self.peek_is(')').not() {
    Err(group_missing_paren)
  } else {
    self.advance(1) // ')'
    Ok(node)
  }
}

fn parse_group_name(self : Parser) -> Result[String, String] {
  self.advance(1) // '<'
  let buf = Buffer::make(0)
  while self.more() && self.peek_is('>').not() {
    buf.write_char(self.peek())
    self.advance(1)
  }
  if self.peek_is('>').not() {
    return Err(unmatched_group_name)
  }
  self.advance(1) // '>'
  Ok(buf.to_string())
}

fn parse_class(self : Parser) -> Result[AstNode, String] {
  let negated = if self.peek_is('^') {
    self.advance(1)
    true
  } else {
    false
  }
  let chars : Array[Int] = []
  let mut first = true
  // Allow ']' and '-' as first char in class
  while self.more() && (self.peek_is(']').not() || first) {
    if self.peek_is(']') && first {
      chars.push(']'.to_int())
      chars.push(']'.to_int())
      self.advance(1) // ']'
    }
    if self.peek_is('-') && first {
      chars.push('-'.to_int())
      chars.push('-'.to_int())
      self.advance(1) // '-'
    }
    first = false
    let low = self.parse_char_class_char()?
    let mut high = low
    if self.more() && self.peek_is('-') {
      self.advance(1) // '-'
      if self.more() && self.peek_is(']') {
        // '-' is the last char
        self.rewind(1)
      } else {
        high = self.parse_char_class_char()?
      }
    }
    chars.push(low.to_int())
    chars.push(high.to_int())
  }
  if self.more().not() || self.peek_is(']').not() {
    return Err(class_missing_bracket)
  } else {
    self.advance(1) // ']'
    Ok(CharClass(~negated, ~chars))
  }
}

fn parse_char_class_char(self : Parser) -> Result[Char, String] {
  if self.more().not() {
    return Err(class_missing_bracket)
  }
  if self.peek_is('\\') {
    self.advance(1)
  }
  let c = self.peek()
  self.advance(1)
  Ok(c)
}

fn parse_escape(self : Parser) -> Result[AstNode, String] {
  if self.more().not() {
    return Err(end_pattern_at_escape)
  }
  let node : AstNode = match self.peek() {
    _ as c => {
      self.advance(1)
      Char(char=c.to_int(), escaped=true)
    }
  }
  Ok(node)
}

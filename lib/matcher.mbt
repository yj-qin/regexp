struct Snapshot {
  state_id : Int
  start_pos : Int
  pos : Int
  trans : Int
  captures : FixedArray[Capture]
}

struct Capture {
  mut start : Int
  mut end : Int
}

fn valid(self : Capture) -> Bool {
  self.start > -1 && self.end > -1
}

struct Matcher {
  nfa : Nfa
  snapshots : Array[Snapshot]
  mut input : Array[Char]
  mut start_pos : Int
  mut pos : Int
  mut state : State
  mut trans : Int
  mut captures : FixedArray[Capture]
  capture_name_map : @map.Map[String, Int]
}

fn Matcher::new(nfa : Nfa, ast : Ast) -> Result[Matcher, String] {
  Ok(
    {
      nfa,
      snapshots: [],
      input: [],
      start_pos: 0,
      pos: 0,
      state: nfa.start,
      trans: 0,
      captures: @fixedarray.new(
        ast.capture_num,
        fn() { { start: -1, end: -1 } },
      ),
      capture_name_map: ast.capture_name_map,
    },
  )
}

fn reset(self : Matcher) -> Unit {
  self.input.clear()
  self.snapshots.clear()
  self.start_pos = 0
  self.pos = 0
  self.trans = 0
  self.state = self.nfa.start
}

fn get_char(self : Matcher) -> Char {
  self.input[self.pos]
}

fn more_char(self : Matcher) -> Bool {
  self.pos < self.input.length()
}

fn snapshot(self : Matcher) -> Unit {
  self.snapshots.push(
    {
      state_id: self.state.id,
      start_pos: self.start_pos,
      pos: self.pos,
      trans: self.trans,
      captures: self.captures,
    },
  )
}

fn backtrack(self : Matcher) -> Bool {
  if self.snapshots.is_empty() {
    return false
  }
  let snapshot = self.snapshots.pop_exn()
  self.state = self.nfa.states[snapshot.state_id]
  self.pos = snapshot.pos
  self.start_pos = snapshot.start_pos
  self.trans = snapshot.trans
  self.captures = snapshot.captures
  true
}

fn next_trans(self : Matcher) -> Option[Transition] {
  if self.trans >= self.state.trans.length() {
    None
  } else {
    self.trans += 1
    Some(self.state.trans[self.trans - 1])
  }
}

fn goto(self : Matcher, state : State) -> Unit {
  self.snapshot()
  self.state = state
  self.trans = 0
}

fn next_start_pos(self : Matcher) -> Bool {
  if self.start_pos == self.input.length() - 1 {
    return false
  }
  self.start_pos += 1
  self.pos = self.start_pos
  self.state = self.nfa.start
  self.trans = 0
  true
}

fn capture_result(self : Matcher) -> Array[String] {
  let arr = []
  let buf = Buffer::make(0)
  for i = self.start_pos; i < self.pos; i = i + 1 {
    buf.write_char(self.input[i])
  }
  arr.push(buf.to_string())
  self.captures.iter(
    fn(cap) {
      if cap.valid() {
        buf.reset()
        for i = cap.start; i < cap.end; i = i + 1 {
          buf.write_char(self.input[i])
        }
        arr.push(buf.to_string())
      } else {
        arr.push("")
      }
    },
  )
  arr
}

fn matches(self : Matcher, input : String) -> Result[MatchResult, String] {
  self.reset()
  self.input = input.to_array()
  let mut matched = false
  while true {
    if self.state.end {
      matched = true
      break
    }
    let trans_opt = self.next_trans()
    if trans_opt.is_empty() {
      // no more path to go, backtrack.
      if self.backtrack() {
        continue
      }
      // stack empty, start from next start pos.
      if self.next_start_pos() {
        continue
      }
      break
    }
    let trans = trans_opt.unwrap()
    match trans.kind {
      Single(~negated, ~chars) => {
        if self.more_char().not() {
          // input exhausted, fail.
          continue
        }
        if match_single_char(negated, chars, self.get_char()) {
          self.pos += 1
          self.goto(trans.to)
        } else {
          continue
        }
      }
      Any => {
        if self.more_char().not() {
          continue
        }
        self.pos += 1
        self.goto(trans.to)
      }
      CaptureStart(~index) => {
        self.captures[index].start = self.pos
        self.goto(trans.to)
      }
      CaptureEnd(~index) => {
        self.captures[index].end = self.pos
        self.goto(trans.to)
      }
      Assert(~kind) =>
        if self.match_assert(kind) {
          self.goto(trans.to)
        } else {
          continue
        }
      _ => return Err("unknown transition")
    }
  }
  Ok(
    {
      success: matched,
      captures: self.capture_result(),
      capture_name_map: self.capture_name_map,
    },
  )
}

fn match_assert(self : Matcher, kind : AssertKind) -> Bool {
  match kind {
    BeginOfLine => self.pos == 0
    EndOfLine => self.pos == self.input.length()
  }
}

fn match_single_char(negated : Bool, chars : Array[Int], char : Char) -> Bool {
  let mut matched = false
  let c = char.to_int()
  if chars.length() == 1 {
    matched = c == chars[0]
  } else {
    for i = 0; i < chars.length(); i = i + 2 {
      if c >= chars[i] && c <= chars[i + 1] {
        matched = true
        break
      }
    }
  }
  if negated {
    matched.not()
  } else {
    matched
  }
}

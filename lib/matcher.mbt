struct Snapshot {
  state_id : Int
  cursor : Int
  trans : Int
}

struct Matcher {
  states : @hashmap.HashMap[Int, State]
  mut input : Array[Char]
  mut cursor : Int
  mut state : State
  mut trans : Int
  snapshots : Array[Snapshot]
}

fn get_char(self : Matcher) -> Char {
  self.input[self.cursor]
}

fn more_char(self : Matcher) -> Bool {
  self.cursor < self.input.length()
}

fn snapshot(self : Matcher) -> Unit {
  self.snapshots.push(
    { state_id: self.state.id, cursor: self.cursor, trans: self.trans },
  )
}

fn backtrack(self : Matcher) -> Bool {
  if self.snapshots.is_empty() {
    return false
  }
  let snapshot = self.snapshots.pop_exn()
  self.state = self.states[snapshot.state_id].unwrap()
  self.cursor = snapshot.cursor
  self.trans = snapshot.trans
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

pub fn Matcher::new(pattern : String) -> Result[Matcher, String] {
  let ast = Parser::new(pattern).parse()?
  let nfa = Nfa::new(ast)
  let states = @hashmap.HashMap::new()
  nfa.states.iter(fn(s) { states[s.id] = s })
  Ok(
    { states, input: [], cursor: 0, state: nfa.start, trans: 0, snapshots: [] },
  )
}

pub fn matches(self : Matcher, str : String) -> Result[Bool, String] {
  self.input = str.to_array()
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
      } else {
        break
      }
    }
    let trans = trans_opt.unwrap()
    match trans.kind {
      Single(~negated, ~chars) => {
        if self.more_char().not() {
          // input exhausted, fail.
          continue
        }
        if match_single_char(negated, chars, self.get_char()) {
          self.cursor += 1
          self.goto(trans.to)
        } else {
          continue
        }
      }
      Any => {
        if self.more_char().not() {
          continue
        }
        self.cursor += 1
        self.goto(trans.to)
      }
      GroupStart(..) =>
        // TODO: record capture info
        self.goto(trans.to)
      GroupEnd(..) =>
        // TODO: record capture info
        self.goto(trans.to)
      Assert(..) =>
        // TODO: check assertion
        self.goto(trans.to)
      _ => return Err("unknown transition")
    }
  }
  Ok(matched)
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

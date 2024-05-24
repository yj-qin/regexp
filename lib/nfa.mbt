enum TransitionKind {
  Epsilon
  Single(~negated : Bool, ~chars : Array[Int])
  Any
  CaptureStart(~index : Int)
  CaptureEnd(~index : Int)
  Assert(~kind : AssertKind)
} derive(Debug, Show)

struct Transition {
  kind : TransitionKind
  to : State
}

fn is_epsilon(self : Transition) -> Bool {
  match self.kind {
    Epsilon => true
    _ => false
  }
}

struct State {
  mut id : Int
  mut end : Bool
  mut valid : Bool
  mut trans : Array[Transition]
}

fn op_equal(self : State, other : State) -> Bool {
  self.id == other.id
}

fn add_trans(self : State, kind : TransitionKind, to : State) -> Unit {
  if self.end {
    self.end = false
  }
  // if a state has a non-epsilon transition input, it is valid and should not be simplified.
  match kind {
    Epsilon => ()
    _ => to.valid = true
  }
  self.trans.push({ kind, to })
}

fn epsilon_trans(self : State, to : State) -> Unit {
  self.add_trans(Epsilon, to)
}

fn get_trans(self : State) -> Array[Transition] {
  self.trans.filter(fn(t) { t.is_epsilon().not() })
}

fn get_epsilon_trans(self : State) -> Array[Transition] {
  self.trans.filter(fn(t) { t.is_epsilon() })
}

fn epsilon_closure(self : State) -> Array[State] {
  let closure = []
  let q = @queue.new()
  self.get_epsilon_trans().iter(fn(t) { q.push(t.to) })
  while q.is_empty().not() {
    let s = q.pop_exn()
    closure.push(s)
    s.get_epsilon_trans().iter(fn(t) { q.push(t.to) })
  }
  closure
}

fn remove_epsilon_trans(self : State) -> Unit {
  self.trans = self.get_trans()
}

struct NfaBuilder {
  mut state_idx : Int
}

fn NfaBuilder::new() -> NfaBuilder {
  { state_idx: 0 }
}

fn new_state(self : NfaBuilder, ~end : Bool = false) -> State {
  self.state_idx += 1
  { id: self.state_idx, end, valid: false, trans: [] }
}

fn empty(self : NfaBuilder) -> Nfa {
  let start = self.new_state()
  let end = self.new_state(end=true)
  start.epsilon_trans(end)
  { states: [start, end], start, end: [end] }
}

fn trans(self : NfaBuilder, kind : TransitionKind) -> Nfa {
  let start = self.new_state()
  let end = self.new_state(end=true)
  start.add_trans(kind, end)
  { states: [start, end], start, end: [end] }
}

struct Nfa {
  states : Array[State]
  start : State
  end : Array[State]
}

fn Nfa::new(ast : Ast) -> Nfa {
  let builder = NfaBuilder::new()
  let nfa = builder.build(ast.root)
  nfa.start.valid = true
  nfa.simplify()
}

/// Simplifies the NFA, removes epsilon transitions and non-valid states.
/// 1. get non-epsilon transitions from the epsilon closure and add to current state.
/// 2. remove epsilon transitions.
/// 3. remove non-valid states.
fn simplify(self : Nfa) -> Nfa {
  let end_state = self.end[0]
  let mut id = 0
  self.states.iter(
    fn(state) {
      if state.valid {
        state.id = id
        id += 1
        let ec = state.epsilon_closure()
        ec.iter(
          fn(ec_state) {
            ec_state.get_trans().iter(fn(t) { state.trans.push(t) })
            if ec_state == end_state {
              state.end = true
              self.end.push(state)
            }
          },
        )
      }
      state.remove_epsilon_trans()
    },
  )
  { ..self, states: self.states.filter(fn(s) { s.valid }) }
}

fn build(self : NfaBuilder, root : AstNode) -> Nfa {
  match root {
    Any => self.trans(Any)
    Char(~char, ..) => self.trans(Single(negated=false, chars=[char]))
    CharClass(~negated, ~chars) => self.trans(Single(~negated, ~chars))
    Alt(~nodes) => {
      let mut nfa = self.build(nodes[0])
      for i = 1; i < nodes.length(); i = i + 1 {
        nfa = self.alt(nfa, self.build(nodes[i]))
      }
      nfa
    }
    Concat(~nodes) => {
      let mut nfa = self.build(nodes[0])
      for i = 1; i < nodes.length(); i = i + 1 {
        nfa = concat(nfa, self.build(nodes[i]))
      }
      nfa
    }
    Empty => self.empty()
    Star(~target) => self.zero_or_more(self.build(target))
    Plus(~target) => self.one_or_more(self.build(target))
    Quest(~target) => self.zero_or_one(self.build(target))
    Repeat(~target, ~min, ~max) => {
      let mut nfa = self.empty()
      for i = 0; i < min; i = i + 1 {
        nfa = concat(nfa, self.build(target))
      }
      match max {
        Some(n) =>
          for i = 0; i < n; i = i + 1 {
            nfa = concat(nfa, self.zero_or_one(self.build(target)))
          }
        None => nfa = concat(nfa, self.zero_or_more(self.build(target)))
      }
      nfa
    }
    Assert(~kind) => self.trans(Assert(~kind))
    Group(~index, ~capture, ~node, ..) => {
      let sub = self.build(node)
      if capture {
        let left = self.trans(CaptureStart(~index))
        let right = self.trans(CaptureEnd(~index))
        concat(concat(left, sub), right)
      } else {
        sub
      }
    }
  }
}

fn concat(n1 : Nfa, n2 : Nfa) -> Nfa {
  n1.end[0].add_trans(Epsilon, n2.start)
  let states = n1.states + n2.states
  { states, start: n1.start, end: n2.end }
}

fn alt(self : NfaBuilder, n1 : Nfa, n2 : Nfa) -> Nfa {
  let start = self.new_state()
  start.epsilon_trans(n1.start)
  start.epsilon_trans(n2.start)
  let end = self.new_state(end=true)
  n1.end[0].epsilon_trans(end)
  n2.end[0].epsilon_trans(end)
  let states = [start]
  states.append(n1.states)
  states.append(n2.states)
  states.push(end)
  { states, start, end: [end] }
}

fn zero_or_more(self : NfaBuilder, n : Nfa) -> Nfa {
  let start = self.new_state()
  let end = self.new_state(end=true)
  start.epsilon_trans(end)
  start.epsilon_trans(n.start)
  n.end[0].epsilon_trans(n.start)
  n.end[0].epsilon_trans(end)
  let states = [start]
  states.append(n.states)
  states.push(end)
  { states, start, end: [end] }
}

fn one_or_more(self : NfaBuilder, n : Nfa) -> Nfa {
  let start = self.new_state()
  let end = self.new_state(end=true)
  start.epsilon_trans(n.start)
  n.end[0].epsilon_trans(end)
  n.end[0].epsilon_trans(n.start)
  let states = [start]
  states.append(n.states)
  states.push(end)
  { states, start, end: [end] }
}

fn zero_or_one(self : NfaBuilder, n : Nfa) -> Nfa {
  let start = self.new_state()
  let end = self.new_state(end=true)
  start.epsilon_trans(end)
  start.epsilon_trans(n.start)
  n.end[0].epsilon_trans(end)
  let states = [start]
  states.append(n.states)
  states.push(end)
  { states, start, end: [end] }
}

fn to_string(self : Nfa) -> String {
  let buf = Buffer::make(0)
  self.states.iteri(
    fn(i, s) {
      buf.write_string("\(i). ")
      buf.write_string("State #" + s.id.to_string())
      if s.id == self.start.id {
        buf.write_string(" START")
      }
      if s.end {
        buf.write_string(" END")
      }
      buf.write_char('\n')
      if s.trans.length() > 0 {
        s.trans.iter(
          fn(t) {
            buf.write_char('\t')
            buf.write_string(t.kind.to_string())
            buf.write_string(" -> ")
            buf.write_string("State #" + t.to.id.to_string())
            buf.write_char('\n')
          },
        )
      }
    },
  )
  buf.to_string()
}

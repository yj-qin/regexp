enum AstNodeInternal {
  // Leave nodes of the AST.
  Empty
  //Nothing
  Single(~char : Char)
  NotSingle(~char : Char)
  Class(~class : CharClass)
  //Multi(~str : String)
  SingleLoop(~char : Char, ~min : Int, ~max : Option[Int])
  NotSingleLoop(~char : Char, ~min : Int, ~max : Option[Int])
  ClassLoop(~class : CharClass, ~min : Int, ~max : Option[Int])
  SingleLoopNG(~char : Char, ~min : Int, ~max : Option[Int])
  NotSingleLoopNG(~char : Char, ~min : Int, ~max : Option[Int])
  ClassLoopNG(~class : CharClass, ~min : Int, ~max : Option[Int])
  //Backreference(~index : Int)
  BeginOfLine
  EndOfLine
  // Branch nodes of the AST that have at least one child.
  Alternate
  Concatenate
  Loop(~min : Int, ~max : Option[Int])
  LoopNG(~min : Int, ~max : Option[Int])
  Capture(~index : Int)
  Group
} derive(Eq)

fn to_string(self : AstNodeInternal) -> String {
  fn range_to_string(min : Int, max : Option[Int]) {
    match max {
      Some(max) => if min == max { "{\(min)} " } else { "{\(min),\(max)} " }
      None => "{\(min),} "
    }
  }

  match self {
    Empty => "Empty"
    Single(~char) => "Single " + char.to_string()
    NotSingle(~char) => "NotSingle " + char.to_string()
    Class(~class) => "Class " + class.to_string()
    SingleLoop(~char, ~min, ~max) =>
      "SingleLoop " + range_to_string(min, max) + char.to_string()
    NotSingleLoop(~char, ~min, ~max) =>
      "NotSingleLoop " + range_to_string(min, max) + char.to_string()
    ClassLoop(~class, ~min, ~max) =>
      "ClassLoop " + range_to_string(min, max) + class.to_string()
    SingleLoopNG(~char, ~min, ~max) =>
      "SingleLoopNG " + range_to_string(min, max) + char.to_string()
    NotSingleLoopNG(~char, ~min, ~max) =>
      "NotSingleLoopNG " + range_to_string(min, max) + char.to_string()
    ClassLoopNG(~class, ~min, ~max) =>
      "ClassLoopNG " + range_to_string(min, max) + class.to_string()
    BeginOfLine => "BeginOfLine"
    EndOfLine => "EndOfLine"
    Alternate => "Alternate"
    Concatenate => "Concatenate"
    Loop(~min, ~max) => "Loop " + range_to_string(min, max)
    LoopNG(~min, ~max) => "LoopNG " + range_to_string(min, max)
    Capture(~index) => "Capture \(index)"
    Group => "Group"
  }
}

struct AstNode {
  internal : AstNodeInternal
  mut parent : Option[AstNode]
  children : Array[AstNode]
}

fn AstNode::make(
  internal : AstNodeInternal,
  ~parent : Option[AstNode] = None,
  ~children : Array[AstNode] = []
) -> AstNode {
  { internal, parent, children }
}

fn add_child(self : AstNode, child : AstNode) -> Unit {
  child.parent = Some(self)
  self.children.push(child)
}

fn get_child(self : AstNode, idx : Int) -> AstNode {
  self.children[idx]
}

fn child_num(self : AstNode) -> Int {
  self.children.length()
}

fn to_string(self : AstNode) -> String {
  let buf = Buffer::make(0)
  let mut cur_node = self
  let mut cur_child = 0
  let stack = []
  buf.write_string(cur_node.internal.to_string())
  buf.write_char('\n')
  for ; ; {
    if cur_child < cur_node.child_num() {
      stack.push(cur_child + 1)
      cur_node = cur_node.get_child(cur_child)
      cur_child = 0
      for i = 0; i < stack.length(); i = i + 1 {
        buf.write_string("  ")
      }
      buf.write_string(cur_node.internal.to_string())
      buf.write_char('\n')
    } else {
      if stack.is_empty() {
        break
      }
      cur_child = stack.pop_exn()
      cur_node = match cur_node.parent {
        Some(node) => node
        None => break
      }
    }
  }
  buf.to_string()
}

struct Ast {
  root : AstNode
  capture_num : Int
  capture_name_mapping : @map.Map[String, Int]
}

fn to_string(self : Ast) -> String {
  let buf = Buffer::make(0)
  buf.write_char('\n')
  buf.write_string("Number of captures: " + self.capture_num.to_string())
  buf.write_char('\n')
  buf.write_string("Capture name mapping: ")
  self.capture_name_mapping.debug_write(buf)
  buf.write_char('\n')
  buf.write_string("Ast:\n")
  buf.write_string(self.root.to_string())
  buf.to_string()
}

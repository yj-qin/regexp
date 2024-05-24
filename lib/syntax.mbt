pub enum AstNode {
  Empty
  Any
  Char(~char : Int, ~escaped : Bool)
  CharClass(~negated : Bool, ~chars : Array[Int])
  Assert(~kind : AssertKind)
  Star(~target : AstNode)
  Plus(~target : AstNode)
  Quest(~target : AstNode)
  Repeat(~target : AstNode, ~min : Int, ~max : Option[Int])
  Group(~capture : Bool, ~index : Int, ~name: String, ~node : AstNode)
  Alt(~nodes : Array[AstNode])
  Concat(~nodes : Array[AstNode])
} derive(Eq, Show)

pub enum AssertKind {
  BeginOfLine
  EndOfLine
} derive(Debug, Show, Eq)

fn debug_write(self : AstNode, buf : Buffer) -> Unit {
  match self {
    Empty => buf.write_string("Empty")
    Char(~char, ~escaped) => {
      buf.write_string("Char(")
      buf.write_char(Char::from_int(char))
      buf.write_string(",\(escaped)")
      buf.write_char(')')
    }
    Any => buf.write_string("Any")
    Assert(~kind) => {
      buf.write_string("Assert(")
      buf.write_string(kind.to_string())
      buf.write_char(')')
    }
    CharClass(~negated, ~chars) => {
      buf.write_string("Class(")
      if negated {
        buf.write_char('^')
      }
      for i = 0; i < chars.length(); i = i + 2 {
        if chars[i] == chars[i + 1] {
          buf.write_char(Char::from_int(chars[i]))
        } else {
          buf.write_char(Char::from_int(chars[i]))
          buf.write_char('-')
          buf.write_char(Char::from_int(chars[i + 1]))
        }
      }
      buf.write_char(')')
    }
    Repeat(~target, ~min, ~max) => {
      buf.write_string("Repeat")
      buf.write_string("{\(min),")
      if max.is_empty().not() {
        buf.write_string(max.unwrap().to_string())
      }
      buf.write_char('}')
      buf.write_char('(')
      target.debug_write(buf)
      buf.write_char(')')
    }
    Star(~target) => {
      buf.write_string("Star")
      buf.write_char('(')
      target.debug_write(buf)
      buf.write_char(')')
    }
    Plus(~target) => {
      buf.write_string("Plus")
      buf.write_char('(')
      target.debug_write(buf)
      buf.write_char(')')
    }
    Quest(~target) => {
      buf.write_string("Quest")
      buf.write_char('(')
      target.debug_write(buf)
      buf.write_char(')')
    }
    Group(~index, ~node, ~capture, ~name) => {
      buf.write_string("Group")
      buf.write_string("[\(index),capture:\(capture),name:\"\(name)\"]")
      buf.write_char('(')
      node.debug_write(buf)
      buf.write_char(')')
    }
    Alt(~nodes) => {
      buf.write_string("Alt(")
      nodes.iteri(
        fn(i, node) {
          if i > 0 {
            buf.write_char(',')
          }
          node.debug_write(buf)
        },
      )
      buf.write_char(')')
    }
    Concat(~nodes) => {
      buf.write_string("Concat(")
      nodes.iteri(
        fn(i, node) {
          if i > 0 {
            buf.write_char(',')
          }
          node.debug_write(buf)
        },
      )
      buf.write_char(')')
    }
  }
}

pub fn is_literal(self : AstNode) -> Bool {
  match self {
    Char(..) => true
    _ => false
  }
}

pub struct Ast {
  root : AstNode
  capture_num : Int
  capture_name_map: @map.Map[String, Int]
} derive(Show)

fn debug_write(self: Ast, buf: Buffer) -> Unit {
  self.root.debug_write(buf)
  buf.write_char('\n')
  buf.write_string("capture_num: " + self.capture_num.to_string())
  buf.write_char('\n')
  buf.write_string("capture_name_map: ")
  self.capture_name_map.debug_write(buf)
}
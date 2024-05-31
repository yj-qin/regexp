priv struct Program {
  bytecodes : Array[Int]
  classes : Array[CharClass]
  capture_num : Int
  capture_name_mapping : @map.Map[String, Int]
} derive(Show)

fn op_code(self : Program, pos : Int) -> OpCode {
  OpCode::from_bytecode(self.bytecodes[pos])
}

fn operand(self : Program, pos : Int) -> Int {
  self.bytecodes[pos]
}

fn debug_write(self : Program, buf : Buffer) -> Unit {
  let mut pos = 0
  while pos < self.bytecodes.length() {
    buf.write_string("\(pos) ")
    let opcode = OpCode::from_bytecode(self.bytecodes[pos])
    match opcode {
      Nop | Stop | BeginOfInput | EndOfInput | NullMark | SetMark | GetMark => {
        buf.write_string("\(opcode)\n")
        pos += 1
      }
      Goto
      | BranchLazy
      | BranchMark | BranchMarkLazy | NullCount | SetCount | CaptureMark => {
        let opd = self.bytecodes[pos + 1]
        buf.write_string("\(opcode) \(opd)\n")
        pos += 2
      }
      Single | NotSingle => {
        let char = self.bytecodes[pos + 1]
        buf.write_string("\(opcode) \(char)\n")
        pos += 2
      }
      Class => {
        let class_idx = self.bytecodes[pos + 1]
        let class = self.classes[class_idx]
        buf.write_string("\(opcode) \(class)\n")
        pos += 2
      }
      SingleRepeat
      | NotSingleRepeat
      | SingleLoop | NotSingleLoop | SingleLazy | NotSingleLazy => {
        let char = self.bytecodes[pos + 1]
        let opd2 = self.bytecodes[pos + 2]
        buf.write_string("\(opcode) \(char) \(opd2)\n")
        pos += 3
      }
      BranchCount | BranchCountLazy => {
        let opd1 = self.bytecodes[pos + 1]
        let opd2 = self.bytecodes[pos + 2]
        buf.write_string("\(opcode) \(opd1) \(opd2)\n")
        pos += 3
      }
      ClassRepeat | ClassLoop | ClassLazy => {
        let class_idx = self.bytecodes[pos + 1]
        let class = self.classes[class_idx]
        let opd2 = self.bytecodes[pos + 2]
        buf.write_string("\(opcode) \(class) \(opd2)\n")
        pos += 3
      }
    }
  }
}

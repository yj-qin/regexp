# RegExp
[![check](https://github.com/yj-qin/regexp/actions/workflows/check.yml/badge.svg)](https://github.com/yj-qin/regexp/actions/workflows/check.yml)
[![coverage](https://coveralls.io/repos/github/yj-qin/regexp/badge.svg?branch=main)](https://coveralls.io/github/yj-qin/regexp?branch=main)

A regular expression module based on a backtracking engine. Due to backtracking during matching, some regular expressions will run for a long time under specific inputs, also known as catastrophic backtracking.
The design of the bytecode and interpreter was heavily inspired by the .NET regular expression library.

## Usage

```moonbit
test "basic" {
  let regexp = @regexp.compile!(
    "^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$",
  )
  let match_result = regexp.matches("12345@test.com")
  @json.inspect!(match_result.success(), content=true)
  @json.inspect!(match_result.captures(), content=[
    "12345@test.com", "12345", "test.com",
  ])
  @json.inspect!(match_result.named_captures(), content={
    "addr": "12345",
    "host": "test.com",
  })
}
```

## Features

### Character classes

- [x] Character range
- [x] Escapes (e.g. `\d`, `\D`, `\s`, `\S`, `\w`, `\W`)

### Assertions

- [x] Begin of input
- [x] End of input
- [ ] Word boundary
- [ ] Lookaround

### Groups

- [x] Capturing group
- [x] Non-capturing group
- [x] Named capturing group

### Backreferences

- [ ] Group backreference
- [ ] Named backreference

### Quantifiers

- [x] Zero or more (\*)
- [x] Zero or one (?)
- [x] One or more (+)
- [x] Range ({n}, {n,}, {n, m})
- [x] Non-greedy

### Encodings

- [ ] Unicode

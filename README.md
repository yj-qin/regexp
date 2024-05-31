# RegExp

## Usage

```
let regexp = @regexp.compile("^(?<addr>[a-zA-Z0-9._%+-]+)@(?<host>[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$")?
let match_result = regexp.matches("12345@test.com")
println(match_result.success()) // true
println(match_result.capture(0)) // 12345@test.com
println(match_result.capture(1)) // 12345
println(match_result.capture(2)) // test.com
println(match_result.named("addr")) // 12345
println(match_result.named("host")) // test.com
```

## Features

### Character classes

- [x] Character range
- [ ] POSIX character classes
- [ ] Perl's Backslash sequences

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
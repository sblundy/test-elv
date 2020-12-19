fn equals [expected actual]{
  if (builtin:not-eq $expected $actual) {
     fail 'equals: expected "'(to-string $expected)'" actual "'(to-string $actual)'"'
  }
}

fn not-equals [expected actual]{
  if (builtin:eq $expected $actual) {
     fail 'not-equals: expected "'(to-string $expected)'" actual "'(to-string $actual)'"'
  }
}

fn has-value [container value]{
  if (not (builtin:has-value $container $value)) {
     fail 'has-value: expected "'(to-string $value)'" in "'(to-string $container)'"'
  }
}

fn not-has-value [container value]{
  if (builtin:has-value $container $value) {
     fail 'not-has-value: expected "'(to-string $value)'" not in "'(to-string $container)'"'
  }
}

fn same-values [expected actual]{
  missing = [(all $expected | each [e]{ if (not (builtin:has-value $actual $e)) { put '  - '$e }})]
  additional = [(all $actual | each [a]{ if (not (builtin:has-value $expected $a)) { put '  + '$a }})]
  if (not (and (== 0 (count $missing)) (== 0 (count $additional)))) {
    use str
    fail (put 'values not same' (all $missing) (all $additional) | str:join "\n")
  }
}

fn has-key [container expected-key]{
  if (not (builtin:has-key $container $expected-key)) { fail 'key "'$expected-key'" missing' }
}

fn value-equals [container key expected]{
  if (not (builtin:has-key $container $key)) { fail 'key "'$key'" missing' }
  if (builtin:not-eq $container[$key] $expected) { fail 'key "'$key'" value: expected "'$expected'" actual "'$container[$key]'"' }
}
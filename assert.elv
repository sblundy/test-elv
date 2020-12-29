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

fn len [expected container]{
  if (!= $expected (count $container)) {
     fail 'len: expected "'(to-string $expected)'" actual "'(to-string (count $container))'":'(repr $container)
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
  if (not (builtin:has-key $container $key)) { fail 'key "'$key'" missing:'(repr $container) }
  if (builtin:not-eq $container[$key] $expected) { fail 'key "'$key'" value: expected "'$expected'" actual "'$container[$key]'"' }
}

fn element-values-match [container @expected]{
  if (!= (count $expected) (count $container)) {
     fail 'element-values-match: expected "'(to-string $expected)'" actual "'(to-string (count $container))'":'(repr $container)
  }
  diffs = [(range (count $expected) | each [i]{
    c = $container[$i]
    e = $expected[$i]
    value-diffs = [(keys $e | each [k]{
      if (not (builtin:has-key $c $k)) {
        put '    - '$k
      } elif (builtin:not-eq $c[$k] $e[$k]) {
        put '    !['$k']:'(repr $e[$k])' != '(repr $c[$k])
      }
    })]
    if (!= 0 (count $value-diffs)) {
      put '  ['$i']'
      all $value-diffs
    }
  })]
  if (!= 0 (count $diffs)) {
    use str
    lines = ['element-values-match:' (all $diffs)]
    repr $lines >> test.log
    fail (str:join "\n" $lines)
  }
}

fn is-fail [actual]{
  if (builtin:eq $ok $actual) {
    fail 'is-fail: actual "'(to-string $actual)'"'
  }
}

fn is-not-fail [actual]{
  if (builtin:not-eq $ok $actual) {
    use str
    fail 'is-not-fail: actual "'(str:join "\n" [(show $actual)])'"'
  }
}
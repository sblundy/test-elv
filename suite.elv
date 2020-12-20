fn format-error [e]{
  use str
  for line [(show $e)] {
    if (not-eq -1 (str:index $line '/test.elv, line')) {
      break
    }
    put $line
  }
}

fn print-results [results]{
  fn success-style [msg]{ put (styled '✓' green)' '$msg }
  fn failed-style [msg]{ put (styled '✗' red)' '$msg }
  fn print-result [result]{
    if (has-key $result 'description') {
      passed failed output = (print-results $result[output])
      put $passed $failed [(styled $result[description] bold) (all $output | each [l]{ put '  '$l })]
    } elif (has-key $result 'name') {
      output = $result[output]
      if (has-key $result error) {
        if (has-key $result[error][reason] content) {
          output = [(all $output) 'Failure: '$result[error][reason][content]]
        } elif (kind-of $result[error][reason] exception) {
          output = [(all $output) 'Error: '  (format-error $result[error])]
        } else {
          output = [(all $output) 'Error: '(to-string $result[error][reason])]
        }
      }
      output = [(all $output | each [l]{ put '  '(to-string $l) }) '']
      if $result[failed] {
        put 0 1 [(failed-style $result[name]) (all $output)]
      } else {
        put 1 0 [(success-style $result[name]) (all $output)]
      }
    } else {
      fail 'unknown type'
    }
  }
  passed = 0
  failed = 0
  output = []
  for result $results {
    p f o = (print-result $result)
    passed = (+ $passed $p)
    failed = (+ $failed $f)
    output = [(all $output) (all $o)]
  }
  put $passed $failed $output
}

fn format-results [results &duration='']{
  d-seg = ''
  if (not-eq  '' $duration) {
    d-seg = (styled ' ('$duration')' dim)
  }
  passed failed output = (print-results $results)
  all $output | each [l]{ echo $l }
  echo (styled $passed' passed' green)$d-seg
  if (!= 0 $failed) {
    echo (styled $failed' failed' red)
    exit 1
  }
}

fn describe [name test-fn]{
  org-level = 0
  rv = [&description=$name]
  if (has-env TEST_LEVEL) {
    org-level = $E:TEST_LEVEL
  }

  try {
    E:TEST_LEVEL = (to-string (+ $org-level 1))
    rv[output] = [($test-fn)]
  } finally {
    E:TEST_LEVEL = (to-string $org-level)
  }

  put $rv
}

fn it [name test-fn]{
  org-level = $E:TEST_LEVEL
  rv = [&name=$name]
  try {
    E:TEST_LEVEL = (to-string (+ $org-level 1))
    rv[output] = [(error = ?($test-fn))]
    if $error {
      rv[failed] = $false
    } else {
      rv[failed] = $true
      rv[error] = $error
    }
  } finally {
    E:TEST_LEVEL = (to-string $org-level)
  }

  put $rv
}

fn suite [test-fn]{
  results =  []
  d = (time { results = [($test-fn)] })
  format-results $results &duration=$d
}

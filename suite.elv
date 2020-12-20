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

  if (==s 0 $org-level) {
    put $rv | to-json
    del E:TEST_LEVEL
  } else {
    put $rv
  }
}

fn it [name test-fn]{
  fn format-error [e]{
    use str
    for line [(show $e)] {
      if (not-eq -1 (str:index $line '/suite.elv, line')) {
        break
      }
      put $line
    }
  }
  org-level = $E:TEST_LEVEL
  rv = [&name=$name]
  try {
    E:TEST_LEVEL = (to-string (+ $org-level 1))
    rv[output] = [(error = ?($test-fn))]
    if $error {
      rv[failed] = $false
    } else {
      rv[failed] = $true
      rv[error] = [(format-error $error)]
    }
  } finally {
    E:TEST_LEVEL = (to-string $org-level)
  }

  put $rv
}

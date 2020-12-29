fn describe [name test-fn]{
  fn exec-test [t]{
    if (has-key $t test-fn) {
      trv = ($t[test-fn])
      for key [(keys $trv)] {
        t[$key] = $trv[$key]
      }
    } elif (has-key $t output) {
      t[output] = [(all $t[output] | each [t]{ exec-test $t })]
    }
    put $t
  }
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
    put $rv | each [t]{ exec-test $t } | to-json
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
  rv[test-fn] = {
    trv = [&name=$name]
    try {
      E:TEST_LEVEL = (to-string (+ $org-level 1))
      trv[output] = [(error = ?($test-fn))]
      if $error {
        trv[failed] = $false
      } else {
        trv[failed] = $true
        trv[error] = [(format-error $error)]
      }
    } finally {
      E:TEST_LEVEL = (to-string $org-level)
    }
    put $trv
  }
  put $rv
}

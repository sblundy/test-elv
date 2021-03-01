files = $args
verbose = $false
if (!= 0 (count $args)) {
  if (==s '-v' $args[0]) {
    verbose = $true
    files = $args[1:(count $args)]
  }
}
if (== 0 (count $files)) {
  files = [*_test.elv]
}

fn print-results [results]{
  fn success-style [msg]{ put (styled '✓' green)' '$msg }
  fn failed-style [msg]{ put (styled '✗' red)' '$msg }
  fn print-result [result]{
    if (has-key $result 'description') {
      passed failed output = (print-results $result[output])
      put $passed $failed [(styled $result[description] bold) (all $output | each [l]{ put '  '$l })]
    } elif (has-key $result 'name') {
      local:output = $result[output]
      if (has-key $result error) {
        if (has-key $result[error] content) {
          output = [(all $output) 'Failure: '$result[error][content]]
        } elif (kind-of $result[error] exception) {
          output = [(all $output) (all $result[error])]
        } else {
          output = [(all $output) 'Error: '(to-string $result[error])]
        }
      }
      if (!= 0 (count $output)) {
        output = [(all $output | each [l]{ put '  '(to-string $l) }) '']
      }
      if (not (has-key $result failed)) { #TODO error case
        put 0 1 [(failed-style $result[name]) (all $output)]
      } elif $result[failed] {
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

fn exec-file [file]{
  output = [(error = ?(elvish $file))]
  if $error {
    all $output | each [o]{ echo $o | from-json }
  } else {
    put [&name=$file &output=$output]
  }
}

results = []
d = (time {
  results = [(all $files | each [file]{ exec-file $file })]
})

if $verbose {
  put $results | to-json | jq
}

format-results $results &duration=$d

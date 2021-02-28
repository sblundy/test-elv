use github.com/sblundy/test-elv/suite
use github.com/sblundy/test-elv/assert

use ./assert sut

suite:describe 'assert' {
  fn expect-ok [f]{
    err = ?($f)
    assert:equals $ok $err
  }
  fn expect-not-ok [f]{
    err = ?($f)
    assert:not-equals $ok $err
  }
  suite:describe 'equals' {
    suite:it 'should pass same int value' {
      expect-ok { sut:equals 42 42 }
    }
    suite:it 'should pass same string value' {
      expect-ok { sut:equals 'v1' 'v1' }
    }
    suite:it 'should fail different int value' {
      expect-not-ok { sut:equals 42 43 }
    }
    suite:it 'should fail different string value' {
      expect-not-ok { sut:equals 'v1' 'v2' }
    }
  }

  suite:describe 'not-equals' {
    suite:it 'should fail same int value' {
      expect-not-ok { sut:not-equals 42 42 }
    }
    suite:it 'should fail same string value' {
      expect-not-ok { sut:not-equals 'v1' 'v1' }
    }
    suite:it 'should pass different int value' {
      expect-ok { sut:not-equals 42 43 }
    }
    suite:it 'should pass different string value' {
      expect-ok { sut:not-equals 'v1' 'v2' }
    }
  }

  suite:describe 'len' {
    suite:describe 'strings' {
      suite:it 'should pass empty string with 0 length expected' {
        expect-ok { sut:len 0 '' }
      }
      suite:it 'should pass single length string with 1 length expected' {
        expect-ok { sut:len 1 'a' }
      }
      suite:it 'should fail empty string with other than 0 length expected' {
        expect-not-ok { sut:len 1 '' }
      }
      suite:it 'should fail single length string with 0 length expected' {
        expect-not-ok { sut:len 0 'a' }
      }
      suite:it 'should fail single length string with 2 length expected' {
        expect-not-ok { sut:len 2 'a' }
      }
    }
    suite:describe 'lists' {
      suite:it 'should pass empty list with 0 length expected' {
        expect-ok { sut:len 0 [] }
      }
      suite:it 'should pass single length list with 1 length expected' {
        expect-ok { sut:len 1 [a] }
      }
      suite:it 'should fail empty list with other than 0 length expected' {
        expect-not-ok { sut:len 1 [] }
      }
      suite:it 'should fail single length list with 0 length expected' {
        expect-not-ok { sut:len 0 [a] }
      }
      suite:it 'should fail single length list with 2 length expected' {
        expect-not-ok { sut:len 2 [a] }
      }
    }

    suite:describe 'maps' {
      suite:it 'should pass empty map with 0 length expected' {
        expect-ok { sut:len 0 [&] }
      }
      suite:it 'should pass single length map with 1 length expected' {
        expect-ok { sut:len 1 [&a=b] }
      }
      suite:it 'should fail empty map with other than 0 length expected' {
        expect-not-ok { sut:len 1 [&] }
      }
      suite:it 'should fail single length map with 0 length expected' {
        expect-not-ok { sut:len 0 [&a=b] }
      }
      suite:it 'should fail single length map with 2 length expected' {
        expect-not-ok { sut:len 2 [&a=b] }
      }
    }
  }

  suite:describe 'has-value' {
    suite:describe 'lists' {
      suite:it 'should pass list with expected value' {
        expect-ok { sut:has-value [a] a }
      }
      suite:it 'should fail empty list with any value' {
        expect-not-ok { sut:has-value [] a }
      }
      suite:it 'should fail list without expected value' {
        expect-not-ok { sut:has-value [a] b }
      }
      suite:it 'should fail list with expected value a substring' {
        expect-not-ok { sut:has-value [aa] a }
      }
    }

    suite:describe 'maps' {
      suite:it 'should pass maps with expected value' {
        expect-ok { sut:has-value [&b=a] a }
      }
      suite:it 'should fail maps where it is the key that matches' {
        expect-not-ok { sut:has-value [&a=b] a }
      }
      suite:it 'should fail list without expected value' {
        expect-not-ok { sut:has-value [&not-b=x] b }
      }
      suite:it 'should fail empty maps with any value' {
        expect-not-ok { sut:has-value [&] a }
      }
    }
  }

  suite:describe 'not-has-value' {
    suite:describe 'lists' {
      suite:it 'should fail list with expected value' {
        expect-not-ok { sut:not-has-value [a] a }
      }
      suite:it 'should pass empty list with any value' {
        expect-ok { sut:not-has-value [] a }
      }
      suite:it 'should pass list without expected value' {
        expect-ok { sut:not-has-value [a] b }
      }
      suite:it 'should pass list with expected value a substring' {
        expect-ok { sut:not-has-value [aa] a }
      }
    }

    suite:describe 'maps' {
      suite:it 'should fail maps with expected value' {
        expect-not-ok { sut:not-has-value [&b=a] a }
      }
      suite:it 'should pass maps where it is the key that matches' {
        expect-ok { sut:not-has-value [&a=b] a }
      }
      suite:it 'should pass list without expected value' {
        expect-ok { sut:not-has-value [&not-b=x] b }
      }
      suite:it 'should pass empty maps with any value' {
        expect-ok { sut:not-has-value [&] a }
      }
    }
  }

  suite:describe 'same-values' {
    suite:describe 'lists' {
      suite:it 'should pass list with expected value' {
        expect-ok { sut:same-values [a] [a] }
      }
      suite:it 'should pass empty lists' {
        expect-ok { sut:same-values [] [] }
      }
      suite:it 'should fail list with different values' {
        expect-not-ok { sut:same-values [a] [b] }
      }
      suite:it 'should pass list with diff number of same values' {
        expect-ok { sut:same-values [a a] [a] }
      }
    }
  }

  suite:describe 'has-key' {
    suite:describe 'lists' {
      suite:it 'should pass list with expected index' {
        expect-ok { sut:has-key [a] 0 }
      }
      suite:it 'should fail empty list with any index' {
        expect-not-ok { sut:has-key [] 0 }
      }
      suite:it 'should fail list without expected index' {
        expect-not-ok { sut:has-key [a] 1 }
      }
    }

    suite:describe 'maps' {
      suite:it 'should pass maps with expected key' {
        expect-ok { sut:has-key [&x=a] x }
      }
      suite:it 'should fail maps where it is the value that matches' {
        expect-not-ok { sut:has-key [&a=b] b }
      }
      suite:it 'should fail map without expected key' {
        expect-not-ok { sut:has-key [&not-b=x] b }
      }
      suite:it 'should fail empty maps with any key' {
        expect-not-ok { sut:has-key [&] a }
      }
    }
  }

  suite:describe 'value-equals' {
    suite:describe 'lists' {
      suite:it 'should pass list with expected value at expected index' {
        expect-ok { sut:value-equals [a] 0 a }
      }
      suite:it 'should fail list with expected value at different index' {
        expect-not-ok { sut:value-equals [b a] 0 a }
      }
      suite:it 'should fail list without expected value at expected index' {
        expect-not-ok { sut:value-equals [b] 0 a }
      }
      suite:it 'should fail list without expected index' {
        expect-not-ok { sut:value-equals [b] 1 b }
      }
    }

    suite:describe 'maps' {
      suite:it 'should pass map with expected value at expected key' {
        expect-ok { sut:value-equals [&x=a] x a }
      }
      suite:it 'should fail map with expected value at different key' {
        expect-not-ok { sut:value-equals [&x=b &y=a] x a }
      }
      suite:it 'should fail map without expected value at expected key' {
        expect-not-ok { sut:value-equals [&x=b] x a }
      }
      suite:it 'should fail map without expected key' {
        expect-not-ok { sut:value-equals [&y=b] x a }
      }
    }
  }
}
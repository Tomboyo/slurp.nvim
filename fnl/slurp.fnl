(local LPAR "(")
(local RPAR ")")

(fn indexOf [xs x]
  "Return the index of the first occurrence of x in xs or nil if x is not in xs"
  (var result nil)
  (var i 0)
  (while (and (<= i (length xs))
              (not result))
    (set i (+ i 1))
    (when (= x (. xs i))
      (set result i)))
  result)

(indexOf [1 2 3] 2)
(indexOf {1 :a 2 :b 3 :c} :b)

(fn search [text chars origin offset]
  (var i origin)
  (var char (text:sub i i))
  (var result (when (indexOf chars char) [char i]))
  (while (and (not result)
              (<= 1 i (length text)))
    (set i (+ i offset))
    (set char (text:sub i i))
    (when (indexOf chars char)
      (set result [char i])))
  (or result ["" -1]))

; Finds the index of the LPAR of the s-exp under the cursor, where both the LPAR
; and RPAR count as being part of the s-exp.
(fn selectExpression []
  ;; Line and column are 1-based
  (local [line col] (vim.api.nvim_win_get_cursor 0))
  (local text (vim.fn.getline line))
  (var i (+ 1 col))
  (var c nil)
  (var result nil)
  ; Setting RPAR = -1 causes stack to balance when finding the corresponding
  ; LPAR: (foo (bar baz|) bang) finds the LPAR containing bar baz. Otherwise the
  ; impl would return the LPAR before foo, which isn't intuitive.
  (var stack (if (= (text:sub i i) RPAR)
                 -1
                 0))
  (while (and (not result)
              (<= 1 i (length text)))
    (set [c i] (search text [LPAR RPAR] i -1))
    (print (string.format "c %s i %s stack %s result %s" c i stack result))
    (match c
      RPAR (do (set stack (+ 1 stack))
               (set i (- i 1)))
      LPAR (if (<= stack 0)
               (set result i)
               (do
                 (set stack (- stack 1))
                 (set i (- i 1))))))
  (print (string.format "%s %s,%s: %s" (+ 1 col) line i c)))

(fn setup [config]
  (vim.keymap.set :n "<Plug>(slurp-expression)" selectExpression))

(fn debug []
  (vim.keymap.set :n "<LocalLeader>se" "<Plug>(slurp-expression)"))

; Module
{: setup}

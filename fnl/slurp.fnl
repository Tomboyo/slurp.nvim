(local LPAR "(")
(local RPAR ")")

(fn search [text char origin offset]
  (var i origin)
  (while (and (>= i 1)
              (<= i (length text))
              (not (= char (text:sub i i))))
    (set i (+ i offset)))
  (if (= char (text:sub i i))
      i
      nil))

(fn selectExpression []
  ;; Line and column are 1-based
  (local [line col] (vim.api.nvim_win_get_cursor 0))
  (local text (vim.fn.getline line))
  (let [left (search text LPAR col -1)
        right (search text RPAR col 1)]
    (print (string.format "%s,%s - %s,%s" line left line right)))
  )

(fn setup [config]
  (vim.keymap.set :n "<Plug>(slurp-expression)" selectExpression))

(fn debug []
  (vim.keymap.set :n "<LocalLeader>se" "<Plug>(slurp-expression)"))

; Module
{: setup}

(fn selectExpression []
  (let [[line col] (vim.api.nvim_win_get_cursor 0)]
    (print (string.format "line %s col %s" line col))))

(fn setup [config]
  (vim.keymap.set :n "<Plug>(slurp-expression)" selectExpression))

; Module
{: setup}

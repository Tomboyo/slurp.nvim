(fn setup [nvim lines pos]
  (vim.rpcrequest nvim :nvim_buf_set_lines 0 0 1 false lines)
  (vim.rpcrequest nvim
                  :nvim_set_option_value
                  :filetype
                  :fennel
                  {})
  (vim.rpcrequest nvim
                  :nvim_exec_lua
                  "vim.treesitter.start()"
                  {})
  (vim.rpcrequest nvim
                  :nvim_win_set_cursor
                  0
                  pos))
(fn plug [nvim mapping]
  (vim.rpcrequest
    nvim
    :nvim_feedkeys
    (vim.api.nvim_replace_termcodes mapping true true true)
    :m
    false))
(fn actual [nvim]
  (. (vim.rpcrequest nvim :nvim_buf_get_lines 0 0 1 true) 1))

(describe
  "slurping"
  (fn []
    (var nvim nil)
    (before_each
      (fn []
        (set nvim (vim.fn.jobstart
                    [:nvim :--embed :--headless]
                    {:rpc true
                     :width 80
                     :height 24}))))

    (after_each
      (fn []
        (vim.fn.jobstop nvim)))

    (describe
      "slurp close paren forward"
      (it
        "swaps the closing paren with the node's sibling"
        (fn []
          (setup nvim ["(foo (bar (baz) bang) whizz)"] [1 12])
          (plug nvim "<Plug>(slurp-slurp-close-paren-forward)")
          (assert.is.equal
            "(foo (bar (baz bang)) whizz)"
            (actual nvim))))
      (it
        "applies to the smallest node around the cursor with a sibling"
        (fn []
          (setup nvim ["(foo (bar ((baz)) bang) whizz)"] [1 13])
          (plug nvim "<Plug>(slurp-slurp-close-paren-forward)")
          (assert.is.equal
            ; Note that baz is still surrounded by one set of parenthesis
            "(foo (bar ((baz) bang)) whizz)"
            (actual nvim)))))
    (describe
      "slurp open paren backward"
      (fn []
        (it
          "swaps the opening paren with the preceding element"
          (fn []
            (setup nvim ["(foo (bar (baz) bang) whizz)"] [1 12])
            (plug nvim "<Plug>(slurp-slurp-open-paren-backward)")
            (assert.is.equal
              "(foo ((bar baz) bang) whizz)"
              (actual nvim))))
        (it
          "applies to the smallest node around the cursor with a sibling"
          (fn []
            (setup nvim ["(foo (bar ((baz)) bang) whizz)"] [1 13])
            (plug nvim "<Plug>(slurp-slurp-open-paren-backward)")
            (assert.is.equal
              "(foo ((bar (baz)) bang) whizz)"
              (actual nvim))))))))


(local n (require :util.nvim))

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
          (n.setup nvim ["(foo (bar (baz) bang) whizz)"] [1 12])
          (n.plug nvim "<Plug>(slurp-slurp-close-paren-forward)")
          (assert.is.equal
            "(foo (bar (baz bang)) whizz)"
            (n.actual nvim))))
      (it
        "applies to the smallest node around the cursor with a sibling"
        (fn []
          (n.setup nvim ["(foo (bar ((baz)) bang) whizz)"] [1 13])
          (n.plug nvim "<Plug>(slurp-slurp-close-paren-forward)")
          (assert.is.equal
            ; Note that baz is still surrounded by one set of parenthesis
            "(foo (bar ((baz) bang)) whizz)"
            (n.actual nvim)))))
    (describe
      "slurp open paren backward"
      (fn []
        (it
          "swaps the opening paren with the preceding element"
          (fn []
            (n.setup nvim ["(foo (bar (baz) bang) whizz)"] [1 12])
            (n.plug nvim "<Plug>(slurp-slurp-open-paren-backward)")
            (assert.is.equal
              "(foo ((bar baz) bang) whizz)"
              (n.actual nvim))))
        (it
          "applies to the smallest node around the cursor with a sibling"
          (fn []
            (n.setup nvim ["(foo (bar ((baz)) bang) whizz)"] [1 13])
            (n.plug nvim "<Plug>(slurp-slurp-open-paren-backward)")
            (assert.is.equal
              "(foo ((bar (baz)) bang) whizz)"
              (n.actual nvim))))))))


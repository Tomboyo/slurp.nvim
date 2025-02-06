(macro describe [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.describe ,name (fn [] ,(unpack body)))))
(macro it [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.it ,name (fn [] ,(unpack body)))))
(macro before_each [& body]
  `(let [b# (require :plenary.busted)]
     (b#.before_each (fn [] ,(unpack body)))))
(macro after_each [& body]
  `(let [b# (require :plenary.busted)]
     (b#.after_each (fn [] ,(unpack body)))))

(local nvim (require :util/nvim))
(local slurp (require :slurp))

(describe
  "barfForward"
  (var buf nil)
  (before_each
    (set buf (vim.api.nvim_create_buf false true)))
  (after_each
    (vim.api.nvim_buf_delete buf {}))
  (it
    "swaps the opening delimiter with the last child"
    (nvim.setup buf ["(foo (bar baz) bang)"] [1 9])
    (slurp.barfForward "(")
    (assert.is.equal
      "(foo bar (baz) bang)"
      (nvim.actual buf)))
  (it
    "is recursive"
    (nvim.setup buf ["(foo (bar ()) baz)"] [1 11])
    (slurp.barfForward "(")
    (assert.is.equal
      "(foo bar (()) baz)"
      (nvim.actual buf))))

(describe
  "barfBackward"
  (var buf nil)
  (before_each
    (set buf (vim.api.nvim_create_buf false true)))
  (after_each
    (vim.api.nvim_buf_delete buf {}))
  (it
    "swaps the closing delimiter with the last child"
    (nvim.setup buf ["(foo (bar baz) bang)"] [1 9])
    (slurp.barfBackward ")")
    (assert.is.equal
      "(foo (bar) baz bang)"
      (nvim.actual buf)))
  (it
    "is recursive"
    (nvim.setup buf ["(foo (() bar) baz)"] [1 6])
    (slurp.barfBackward ")")
    (assert.is.equal
      "(foo (()) bar baz)"
      (nvim.actual buf))))

nil

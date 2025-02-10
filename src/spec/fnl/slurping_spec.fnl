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

(local nvim (require :slurp/util/nvim))
(local slurp (require :slurp))

(describe
  "slurpForward"
  (var buf nil)
  (before_each
    (set buf (vim.api.nvim_create_buf false true)))
  (after_each
    (vim.api.nvim_buf_delete buf {}))
  (it
    "swaps the closing delimiter with the sibling to the right"
    (nvim.setup buf ["(foo (bar (b|az) bang) whizz)"])
    (slurp.slurpForward ")")
    (assert.is.equal
      "(foo (bar (baz bang)) whizz)"
      (nvim.actual buf)))
  (it
    "is recursive"
    (nvim.setup buf ["(foo (bar (b|az)) bang)"])
    (slurp.slurpForward ")")
    (assert.is.equal
      "(foo (bar (baz) bang))"
      (nvim.actual buf))))

(describe
  "slurpBackward"
  (var buf nil)
  (before_each
    (set buf (vim.api.nvim_create_buf false true)))
  (after_each
    (vim.api.nvim_buf_delete buf {}))
  (it
    "swaps the opening delimiter with the sibling to the left"
    (nvim.setup buf ["(foo (bar (b|az) bang) whizz)"])
    (slurp.slurpBackward "(")
    (assert.is.equal
      "(foo ((bar baz) bang) whizz)"
      (nvim.actual buf)))
  (it
    "is recursive"
    (nvim.setup buf ["(foo ((b|ar) baz) bang)"])
    (slurp.slurpBackward "(")
    (assert.is.equal
      "((foo (bar) baz) bang)"
      (nvim.actual buf))))

nil

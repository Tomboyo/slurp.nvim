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
  "replaceParent"
  (var buf nil)
  (before_each
    (set buf (vim.api.nvim_create_buf false true)))
  (after_each
    (vim.api.nvim_buf_delete buf {}))
  (it
    "replaces the parent element with the one under the cursor"
    (nvim.setup buf ["(foo b|ar baz)"])
    (slurp.replaceParent)
    (assert.is.equal
      "bar"
      (nvim.actual buf)))
  (it
    "works across lines"
    (nvim.setup buf ["(foo" "b|ar" "baz)"])
    (slurp.replaceParent)
    (assert.is.equal
      "bar"
      (nvim.actual buf))))

nil

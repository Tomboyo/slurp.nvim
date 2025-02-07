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
  "unwrap"
  (var buf nil)
  (before_each
    (set buf (vim.api.nvim_create_buf false true)))
  (after_each
    (vim.api.nvim_buf_delete buf {}))
  (it
    "splices the content of a node into its parent"
    (nvim.setup buf ["(foo (bar baz) baz)"] [1 7])
    (slurp.unwrap "(" ")")
    (assert.is.equal
      "(foo bar baz baz)"
      (nvim.actual buf)))
  (it
    "works with arbitrary delimiters (that are grammatically correct)"
    (nvim.setup buf ["(foo [bar baz] bang)"] [1 7])
    (slurp.unwrap "[" "]")
    (assert.is.equal
      "(foo bar baz bang)"
      (nvim.actual buf))))

nil

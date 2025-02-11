(macro describe [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.describe ,name (fn [] ,(unpack body)))))
(macro it [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.it ,name (fn [] ,(unpack body)))))

(local busted (require :plenary.busted))
(local nvim (require :slurp/util/nvim))
(local slurp (require :slurp))

(describe
  "select"
  (it
    "selects a given node"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo |bar baz)"])
        (let [n (vim.treesitter.get_node)
              p (n:parent)]
          (slurp.select p))
        (assert.is.same
          ["(foo bar baz)"]
          (nvim.actualSelection buf)))))
  (it
    "selects multiline nodes"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo" "bar" "baz)"])
        (slurp.select (vim.treesitter.get_node))
        (assert.is.same
          ["(foo" "bar" "baz)"]
          (nvim.actualSelection buf)))))
  (it
    "selects nothing when given nil"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo bar baz)"])
        (slurp.select)
        (assert.is.same
          ["("] ; no difference between a zero-selection and what's under the
                ; cursor
          (nvim.actualSelection buf)))))
  )

  nil

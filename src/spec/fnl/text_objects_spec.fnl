(macro describe [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.describe ,name (fn [] ,(unpack body)))))
(macro it [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.it ,name (fn [] ,(unpack body)))))

(local nvim (require :slurp/util/nvim))
(local slurp (require :slurp))

(describe
  "select"
  (it
    "selects the node under the cursor when given no args"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo b|ar baz)"])
        (slurp.selectNode)
        (assert.is.same
          ["bar"]
          (nvim.actualSelection buf)))))
  (it
    "selects a given node"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo |bar baz)"])
        (let [n (vim.treesitter.get_node)
              p (n:parent)]
          (slurp.selectNode p))
        (assert.is.same
          ["(foo bar baz)"]
          (nvim.actualSelection buf)))))
  (it
    "selects multiline nodes"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo" "bar" "baz)"])
        (slurp.selectNode)
        (assert.is.same
          ["(foo" "bar" "baz)"]
          (nvim.actualSelection buf)))))
  (describe
    "when {:inner true}"
    (it
      "selects the contents of the node under the cursor"
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf ["|(foo bar baz)"])
          (slurp.selectNode {:inner true})
          (assert.is.same ["foo bar baz"] (nvim.actualSelection buf)))))
    (it
      "selects the contents of a given node"
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf ["(foo |bar baz)"])
          (let [n (vim.treesitter.get_node)]
            (slurp.selectNode (n:parent) {:inner true}))
          (assert.is.same ["foo bar baz"] (nvim.actualSelection buf)))))
    (it
      "selects an entire atomic node"
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf ["|foo"])
          (slurp.selectNode {:inner true})
          (assert.is.same ["foo"] (nvim.actualSelection buf)))))
    (it
      "selects the whitespace content of an empty node"
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf ["|(   )"])
          (slurp.selectNode {:inner true})
          (assert.is.same
            ["   "]
            (nvim.actualSelection buf)))))))

nil


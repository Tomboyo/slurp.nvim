(macro describe [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.describe ,name (fn [] ,(unpack body)))))
(macro it [name & body]
  `(let [b# (require :plenary.busted)]
     (b#.it ,name (fn [] ,(unpack body)))))

(local nvim (require :util/nvim))
(local slurp (require :slurp))

(describe
  "select"
  (it
    "selects nodes"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo b|ar baz)"])
        (slurp.select (vim.treesitter.get_node))
        (assert.is.same
          ["bar"]
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
    "selects 0,0-offset end-exclusive ranges"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo bar baz)"])
        (slurp.select [0 5 0 8])
        (assert.is.same
          ["bar"]
          (nvim.actualSelection buf)))))
  (it
    "selects multiline ranges"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo" "bar" "baz)"])
        (slurp.select [0 0 2 4])
        (assert.is.same
          ["(foo" "bar" "baz)"]
          (nvim.actualSelection buf))))))

nil


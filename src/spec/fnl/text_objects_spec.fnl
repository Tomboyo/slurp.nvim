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
    "selects the node under the cursor by default"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo b|ar baz)"])
        (slurp.selectNode)
        (assert.is.same
          ["bar"]
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
  (it
    "selects 0,0-offset end-exclusive ranges"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo bar baz)"])
        (slurp.selectNode [0 5 0 8])
        (assert.is.same
          ["bar"]
          (nvim.actualSelection buf)))))
  (it
    "selects multiline ranges"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(foo" "bar" "baz)"])
        (slurp.selectNode [0 0 2 4])
        (assert.is.same
          ["(foo" "bar" "baz)"]
          (nvim.actualSelection buf)))))
  (describe
    "when {:inner true}"
    (it
      "selects the contents of a node, excluding its first and last children"
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf ["|(foo" "bar" "baz)"])
          (slurp.selectNode nil {:inner true})
          (assert.is.same
            ["foo" "bar" "baz"]
            (nvim.actualSelection buf))))))
  (it
    "selects the whitespace content of a node with only unnamed children"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["|(   )"])
        (slurp.selectNode nil {:inner true})
        (assert.is.same
          ["   "]
          (nvim.actualSelection buf)))))
  )

nil


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
  "Forward into element"
  (it
    "moves the cursor to the start of the next element"
    (nvim.withBuf (fn [buf]
      (nvim.setup buf ["(|foo (bar baz) bang)"])
      (slurp.forwardInto)
      (assert.is.same
        ["(foo |(bar baz) bang)"]
        (nvim.actual buf {:cursor true})))))
  (it
    "moves to child elements before sibling elements"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo |(bar baz) bang)"])
        (slurp.forwardInto)
        (assert.is.same
          ["(foo (|bar baz) bang)"]
          (nvim.actual buf {:cursor true})))))
  (it
    "will move to subsequent lines"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(|foo" "bar" "baz)"])
        (slurp.forwardInto)
        (assert.is.same
          ["(foo" "|bar" "baz)"]
          (nvim.actual buf {:cursor true}))))))

(describe
  "Forward over element"
  (it
    "moves the cursor to the start of the next element"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(|foo (bar baz) bang)"])
        (slurp.forwardOver)
        (assert.is.same
          ["(foo |(bar baz) bang)"]
          (nvim.actual buf {:cursor true})))))
  (it
    "moves the cursor by sibling element only"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo |(bar baz) bang)"])
        (slurp.forwardOver)
        (assert.is.same
          ["(foo (bar baz) |bang)"]
          (nvim.actual buf {:cursor true})))))
  (it
    "will move to subsequent lines"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(|foo" "(bar baz)" "bang)"])
        (slurp.forwardOver)
        (assert.is.same
          ["(foo" "|(bar baz)" "bang)"]
          (nvim.actual buf {:cursor true}))))))

nil

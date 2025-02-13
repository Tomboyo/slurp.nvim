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
  "forwardInto fennel"
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
  "forwardOver fennel"
  (it
    "skips over symbol fragments"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(|a.b.c :arg :arg)"])
        (slurp.forwardOver (require :slurp/lang/fennel))
        (assert.is.same
          ["(a.b.c |:arg :arg)"]
          (nvim.actual buf {:cursor true}))))))

nil

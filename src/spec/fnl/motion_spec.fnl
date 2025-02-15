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
          (nvim.actual buf {:cursor true})))))
  (it
    "accepts custom typeOpts"
    (nvim.withBuf
      #(do (nvim.setup $1 ["(|foo :bar baz)"])
           (slurp.forwardInto {:not [:string :string_content]})
           (assert.is.same
             ["(foo :bar |baz)"]
             (nvim.actual $1 {:cursor true}))))))

(describe
  "forwardOver fennel"
  (it
    "skips over symbol fragments"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(|a.b.c :arg :arg)"])
        (slurp.forwardOver)
        (assert.is.same
          ["(a.b.c |:arg :arg)"]
          (nvim.actual buf {:cursor true})))))
  (it
    "accepts custom typeOpts"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(|foo :bar baz)"])
        (slurp.forwardOver {:not [:string :string_content]})
        (assert.is.same
          ["(foo :bar |baz)"]
          (nvim.actual buf {:cursor true}))))))

(describe
  "backwardOver fennel"
  (it
    "skips over symbol fragments"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(a.b.c |:arg)"])
        (slurp.backwardOver)
        (assert.is.same
          ["(|a.b.c :arg)"]
          (nvim.actual buf {:cursor true})))))
  (it
    "does not stop on the parent node"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo" "(|bar))"])
        (slurp.backwardOver)
        (assert.is.same
          ["(|foo" "(bar))"]
          (nvim.actual buf {:cursor true})))))
  (it
    "accepts custom typeOpts"
    (nvim.withBuf
      (fn [buf]
        (nvim.setup buf ["(foo :bar |baz)"])
        (slurp.backwardOver {:not [:string :string_content]})
        (assert.is.same
          ["(|foo :bar baz)"]
          (nvim.actual buf {:cursor true}))))))

(describe
  "backwardInto fennel"
  (it
    "stops on the deepest child of the previous sibling"
    (nvim.withBuf
      #(do (nvim.setup $1 ["(foo (bar ((baz))) |bang)"])
           (slurp.backwardInto)
           (assert.is.same
             ["(foo (bar ((|baz))) bang)"]
             (nvim.actual $1 {:cursor true})))))
  (it
    "stops on parent elements"
    (nvim.withBuf
      #(do (nvim.setup $1 ["(foo (|bar) baz)"])
           (slurp.backwardInto)
           (assert.is.same
             ["(foo |(bar) baz)"]
             (nvim.actual $1 {:cursor true})))))
  (it
    "stops on symbol fragments"
    (nvim.withBuf
      #(do (nvim.setup $1 ["a.b.|c"])
           (slurp.backwardInto)
           (assert.is.same
             ["a.|b.c"]
             (nvim.actual $1 {:cursor true})))))
  (it
    "accepts custom typeOpts"
    (nvim.withBuf
      #(do (nvim.setup $1 ["(drink (more :glurp) |slurm)"])
           (slurp.backwardInto {:not [:string :string_content]})
           (assert.is.same
             ["(drink (|more :glurp) slurm)"]
             (nvim.actual $1 {:cursor true}))))))

nil

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
(local iter (require :slurp/iter))
(local slurp (require :slurp))
(local fen (require :slurp.lang.fennel))

(local roundLists [
  [["(case |:in :left :right)"] ["(case :in :left :right)"]]
  [["(fn [] f|oo)"] ["(fn [] foo)"]]
  [["(let [foo :bar] |foo)"] ["(let [foo :bar] foo)"]]
  [["(:a :b |:c)"] ["(:a :b :c)"]]
  [["(match |:in" ":left :right" ")"] ["(match :in" ":left :right" ")"]]])
(local curlyLists [
  [["(local |{foo} {:foo})"] ["{foo}"]]
  [["{:a :|b :c}"] ["{:a :b :c}"]]])
(local squareLists [
  [["(let [foo :bar" "baz :bang]|" "foo)"] ["[foo :bar" "baz :bang]"]]
  [["[:a :b |:c]"] ["[:a :b :c]"]]
  [["(fn [a b |c] nil)"] ["[a b c]"]]])
(local allLists (iter.collect
                  (iter.concat (iter.iterate roundLists)
                               (iter.iterate curlyLists)
                               (iter.iterate squareLists))))

(describe
  "select a fennel.roundList"
  (each [i [given expected] (ipairs roundLists)]
    (it
      (string.format "%2d: %s" i (vim.inspect given))
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf given)
          (slurp.select (slurp.find fen.roundList))
          (assert.is.same
            expected
            (nvim.actualSelection buf)))))))

(describe
  "select a fennel.squareList"
  (each [i [given expected] (ipairs squareLists)]
    (it
      (string.format "%2d: %s" i (vim.inspect given))
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf given)
          (slurp.select (slurp.find fen.squareList))
          (assert.is.same
            expected
            (nvim.actualSelection buf)))))))

(describe
  "select a fennel.curlyList"
  (each [i [given expected] (ipairs curlyLists)]
    (it
      (string.format "%2d: %s" i (vim.inspect given))
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf given)
          (slurp.select (slurp.find fen.curlyList))
          (assert.is.same
            expected
            (nvim.actualSelection buf)))))))

(describe
  "select a fennel.anyList"
  (each [i [given expected] (ipairs allLists)]
    (it
      (string.format "%2d: %s" i (vim.inspect given))
      (nvim.withBuf
        (fn [buf]
          (nvim.setup buf given)
          (slurp.select (slurp.find fen.anyList))
          (assert.is.same
            expected
            (nvim.actualSelection buf)))))))

nil

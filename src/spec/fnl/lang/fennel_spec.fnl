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
(local fen (require :slurp.lang.fennel))
(describe
  "select any list"
  (each [i [given expected]
         (ipairs [[["(case |:in :left :right)"] ["(case :in :left :right)"]]
                  [["(fn [] f|oo)"] ["(fn [] foo)"]]
                  [["(let [foo :bar" "baz :bang]|" "foo)"] ["[foo :bar" "baz :bang]"]]
                  [["(let [foo :bar] |foo)"] ["(let [foo :bar] foo)"]]
                  [["(:a :b |:c)"] ["(:a :b :c)"]]
                  [["(match |:in" ":left :right" ")"] ["(match :in" ":left :right" ")"]]
                  [["[:a :b |:c]"] ["[:a :b :c]"]]
                  [["(fn [a b |c] nil)"] ["[a b c]"]]
                  [["{:a :|b :c}"] ["{:a :b :c}"]]
                  [["(local |{foo} {:foo})"] ["{foo}"]]
         ])]
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

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
  "selecting list-like elements"
  (each [_ [name given expected]
         (ipairs [[:binding_pair ["(local foo |:bar)"] ["foo :bar"]]
                  [:case_form ["(case |:in :left :right)"] ["(case :in :left :right)"]]
                  [:case_pair ["(case {:in}" "{:pattern} |nil" ")"] ["{:pattern} nil"]]
                  [:fn_form ["(fn [] f|oo)"] ["(fn [] foo)"]]
                  [:binding_pair ["(let [foo :ba|r] foo)"] ["foo :bar"]]
                  [:let_vars ["(let [foo :bar" "baz :bang]|" "foo)"] ["[foo :bar" "baz :bang]"]]
                  [:let_form ["(let [foo :bar] |foo)"] ["(let [foo :bar] foo)"]]
                  [:list ["(:a :b |:c)"] ["(:a :b :c)"]]
                  [:match_form ["(match |:in" ":left :right" ")"] ["(match :in" ":left :right" ")"]]
                  [:sequence ["[:a :b |:c]"] ["[:a :b :c]"]]
                  [:sequence_arguments ["(fn [a b |c] nil)"] ["[a b c]"]]
                  [:table ["{:a :|b :c}"] ["{:a :b :c}"]]
                  [:table_binding ["(let [{foo} | {:cats}] foo)"] ["{foo}  {:cats}"]]])]
    (describe
      (string.format "%s: given %s" name (vim.inspect given))
      (it
        (string.format "selects %s" (vim.inspect expected))
        (nvim.withBuf
          (fn [buf]
            (nvim.setup buf given)
            (slurp.select (slurp.find fen.listLike))
            (assert.is.same
              expected
              (nvim.actualSelection buf))))))))

nil

(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :slurp/tree))
(local iter (require :slurp/iter))

(fn typeMatch [node opts]
  (let [types (or (. opts :not) opts)
        f (if (. opts :not)
              (fn [t] (not (= t (node:type))))
              (fn [t] (= t (node:type))))]
    (iter.find f (iter.iterate types))))

(fn slurpSelect [nodeOrRange]
  (if (= nil nodeOrRange)
      nil
      (ts.update_selection 0 nodeOrRange)))

(fn find [types root]
  (if (= nil types)
      (vts.get_node)
      (let [root (or root (vts.get_node))]
        (iter.find
          (fn [n] 
            (iter.find
                    (fn [type] (= type (n:type)))
                    (iter.stateful (ipairs types))))
          (tree.namedParents root)))))

(fn forwardInto []
  (let [[_ row col _] (vim.fn.getpos ".")
        node (vts.get_node)]
    (ts.goto_node (->> (tree.nodesBelowLevel node)
                       (iter.find (fn [n] (tree.isLexicallyAfter n row col)))))))

(fn forwardOver [lang]
  (let [[_ row col _] (vim.fn.getpos ".")
        node (vts.get_node)
        ; TODO: better name for Iblings.
        target (->> (tree.nodesOnLevel node)
                    (iter.filter (fn [n] (tree.isLexicallyAfter n row col)))
                    (iter.find
                      (fn [n] (typeMatch n lang.forwardOver))))]
    (ts.goto_node target)))


; TODO: usage in README
{;manipulation
 ;TODO
 ;motion
 :forwardInto forwardInto
 :forwardOver forwardOver
 ;text objects
 :select slurpSelect
 :find find}

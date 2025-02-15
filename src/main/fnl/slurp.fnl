(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :slurp/tree))
(local iter (require :slurp/iter))

(fn typeMatch [node opts]
  (let [types (or (. opts :not) opts)
        f (if (. opts :not)
              #(not (= $1 (node:type)))
              #(= $1 (node:type)))]
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
          #(typeMatch $1 types)
          (iter.iterate tree.nextParent root)))))

(fn forwardInto []
  (let [[_ row col _] (vim.fn.getpos ".")
        root (vts.get_node)]
    (ts.goto_node (->> (iter.iterate tree.nextDescending root)
                       (iter.find #(tree.isLexicallyAfter $1 row col))))))

(fn forwardOver [lang]
  (let [[_ row col _] (vim.fn.getpos ".")
        root (vts.get_node)
        target (->> (iter.iterate tree.nextAscending root)
                    (iter.filter #(tree.isLexicallyAfter $1 row col))
                    (iter.find #(typeMatch $1 lang.forwardOver)))]
    (ts.goto_node target)))

(fn backwardOver [lang]
  (let [[_ row col _] (vim.fn.getpos ".")
        root (vts.get_node)]
    (ts.goto_node (->> (iter.iterate tree.prevAscending root)
                       (iter.filter #(tree.isLexicallyBefore $1 row col))
                       (iter.find #(typeMatch $1 lang.forwardOver))))))

; TODO: usage in README
{;manipulation
 ;TODO
 ;motion
 :forwardInto forwardInto
 :forwardOver forwardOver
 :backwardOver backwardOver
 ;text objects
 :select slurpSelect
 :find find}

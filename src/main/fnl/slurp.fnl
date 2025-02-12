(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :slurp/tree))
(local iter (require :slurp/iter))

; TODO
; want an API like
; (slurp.select (->> (slurp.find [:binding_form :list :array :set :etc])
;                    slurp.innerRange :fennel))
; to select the inside of a node. Find locates a node of the given type by going
; up the tree, then we have some functions to manipulat the node selection.
; These have to be by grammar to be the most accurate. If we tried to do this
; sort of thing in a language-unaware manner, it'd be impossible for the user to
; say something like "find the first let binding surrounding the cursor" because
; there's no way to match by delimiter or something.

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
  (let [[_ line col _] (vim.fn.getpos ".")]
    (ts.goto_node (tree.nextLexicalInnerNode
                    (ts.get_node_at_cursor)
                    (- line 1)
                    (- col 1)))))

(fn forwardOver []
  (let [[_ line col _] (vim.fn.getpos ".")
        node (vts.get_node)]
    (ts.goto_node (tree.nextLexicalOuterNode node (- line 1) (- col 1)))))

; TODO: usage in README
{;manipulation
 ;TODO
 ;motion
 :forwardInto forwardInto
 :forwardOver forwardOver
 ;text objects
 :select slurpSelect
 :find find}

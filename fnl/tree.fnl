(local ts (require "nvim-treesitter.ts_utils"))
(local m {})

(fn nextNamedParent [node]
  (let [p (node:parent)]
    (if (p:named)
        p
        (nextNamedParent p))))

(fn nextNamedIbling [node]
  "Get the next sibling or nibling"
  (if (node:next_named_sibling)
      (node:next_named_sibling)
      (nextNamedIbling (nextNamedParent node))))

(fn nextNamedNode [node]
  "Return the next named node after the given node according to in-order tree
  traversal"
  (if (> (node:named_child_count) 0)
      (node:named_child 0)
      (nextNamedIbling node)))

(fn m.range [node offset]
  (let [offset (or offset [1 0])
        [r c] offset
        {:start {:line l1 :character c1}
         :end   {:line l2 :character c2}} (ts.node_to_lsp_range node)]
    [(+ r l1) (+ c c1) (+ r l2) (+ c c2)]))

(fn m.nextLexicalNode [node line char]
  "Get the next node ahead of the cursor according to an in-order traversal of
  the tree. Line and char must be 1-based (as in vim.fn.getpos(\".\"))"
  (let [[l c _ _] (m.range node [1 1])]
    (if (or (and (= l line) (<= c char))
            (and (< l line)))
        (m.nextLexicalNode (nextNamedNode node) line char)
        node)))

m

(local ts (require "nvim-treesitter.ts_utils"))
(local m {})

(fn nextNamedParent [node]
  (let [p (node:parent)]
    (if (p:named)
        p
        (nextNamedParent p))))
; doing this to "publish" because its less error prone than changing the
; function name to m.* and breaking every call
(set m.nextNamedParent nextNamedParent)

(fn nextNamedIbling [node]
  "Get the next sibling or nibling"
  (if (node:next_named_sibling)
      (node:next_named_sibling)
      (nextNamedIbling (nextNamedParent node))))

(fn nextNamedInnerNode [node]
  (if (> (node:named_child_count) 0)
      (node:named_child 0)
      (nextNamedIbling node)))

(fn m.range [node offset]
  "Deprecated. Use vim.treesitter.get_node_range"
  (let [offset (or offset [1 0])
        [r c] offset
        {:start {:line l1 :character c1}
         :end   {:line l2 :character c2}} (ts.node_to_lsp_range node)]
    [(+ r l1) (+ c c1) (+ r l2) (+ c c2)]))

(fn m.nextLexicalInnerNode [node line char]
  "Get the next node ahead of the cursor according to an in-order traversal of
  the tree. Line and char must be 1-based (as in vim.fn.getpos(\".\"))"
  (let [[l c _ _] (m.range node [1 1])]
    (if (or (and (= l line) (<= c char))
            (and (< l line)))
        (m.nextLexicalInnerNode (nextNamedInnerNode node) line char)
        node)))

(fn m.nextLexicalOuterNode [node line char]
  (let [[l c _ _] (m.range node [1 1])]
    (if (or (and (= l line) (<= c char))
            (and (< l line)))
        (m.nextLexicalOuterNode (nextNamedIbling node) line char)
        node)))

(fn m.delimiters [node]
  (let [len (node:child_count)]
    (if (>= len 1)
      [(node:child 0) (node:child (- len 1))]
      [nil nil])))

(fn m.firstSurroundingNode [ldelim rdelim node]
  (let [node (or node (vim.treesitter.get_node))
        [open close] (m.delimiters node)]
    (if (and open
             close
             (= ldelim (vim.treesitter.get_node_text open 0))
             (= rdelim (vim.treesitter.get_node_text close 0)))
        [node open close]
        (m.firstSurroundingNode ldelim rdelim (nextNamedParent node)))))

m

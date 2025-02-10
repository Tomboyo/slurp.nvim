(local ts (require "nvim-treesitter.ts_utils"))
(local iter (require :slurp/iter))
(local m {})

(fn m.namedParents [root]
  "Returns an iterator over root and its named parents"
  (when (= nil root)
    (error "missing root node"))
  (iter.iterator m.nextNamedParent root))

(fn m.nextNamedParent [node]
  (let [p (node:parent)]
    (if p
        (if (p:named)
            p
            (m.nextNamedParent p))
        nil)))

(fn nextNamedIbling [node]
  "Get the next sibling or nibling"
  (if (node:next_named_sibling)
      (node:next_named_sibling)
      (nextNamedIbling (m.nextNamedParent node))))

(fn nextNamedInnerNode [node]
  (if (> (node:named_child_count) 0)
      (node:named_child 0)
      (nextNamedIbling node)))

(fn m.nextLexicalInnerNode [node line char]
  "Get the next node ahead of the cursor according to an in-order traversal of
  the tree. Line and char must be 1-based (as in vim.fn.getpos(\".\"))"
  (let [(l c _ _) (vim.treesitter.get_node_range node)]
    (if (or (and (= l line) (<= c char))
            (and (< l line)))
        (m.nextLexicalInnerNode (nextNamedInnerNode node) line char)
        node)))

(fn m.nextLexicalOuterNode [node line char]
  (let [(l c _ _) (vim.treesitter.get_node_range node)]
    (if (or (and (= l line) (<= c char))
            (and (< l line)))
        (m.nextLexicalOuterNode (nextNamedIbling node) line char)
        node)))

(fn m.firstSurroundingNode [ldelim rdelim node]
  (let [node (or node (vim.treesitter.get_node))
        [open close] (m.delimiters node)]
    (if (and open
             close
             (= ldelim (vim.treesitter.get_node_text open 0))
             (= rdelim (vim.treesitter.get_node_text close 0)))
        [node open close]
        (m.firstSurroundingNode ldelim rdelim (nextNamedParent node)))))

(fn m.child [node offset]
  (let [index (if (< offset 0)
                  (+ (node:child_count) offset)
                  offset)]
    (node:child index)))

(fn m.namedChild [node offset]
  (let [index (if (< offset 0)
                  (+ (node:named_child_count) offset)
                  offset)]
    (node:named_child index)))

(fn m.rangeBetween [s e]
  (let [(a b _ _) (vim.treesitter.get_node_range s)
        (_ _ g h) (vim.treesitter.get_node_range e)]
    [a b g h]))

m

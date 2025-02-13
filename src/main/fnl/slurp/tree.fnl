(local ts (require "nvim-treesitter.ts_utils"))
(local iter (require :slurp/iter))
(local m {})

(fn m.namedParents [root]
  "Returns an iterator over root and its named parents"
  (when (= nil root)
    (error "missing root node"))
  (iter.iterator m.nextNamedParent root))

(fn m.namedIblings [root]
  (when (= nil root)
    (error "missing root node"))
  (iter.iterator m.nextNamedIbling root))

(fn m.isLexicallyAfter [root row col]
  "True if the node's row and col is after the given 1,1-offset row and col."
  ; get_node_range is 0-basec.
  (let [(l c) (vim.treesitter.get_node_range root)
        l (+ 1 l)
        c (+ 1 c)]
    (or (> l row)
        (and (= l row) (> c col)))))

(fn m.nextNamedParent [node]
  (let [p (node:parent)]
    (if p
        (if (p:named)
            p
            (m.nextNamedParent p))
        nil)))

(fn m.nextNamedIbling [node]
  "Get the next sibling or nibling"
  (when (= nil node)
    (error "nil node"))
  (if (node:next_named_sibling)
      (node:next_named_sibling)
      (let [p (m.nextNamedParent node)]
        (if p (m.nextNamedIbling p)
              nil))))

(fn nextNamedInnerNode [node]
  (if (> (node:named_child_count) 0)
      (node:named_child 0)
      (m.nextNamedIbling node)))

(fn m.nextLexicalInnerNode [node line char]
  "Get the next node ahead of the cursor according to an in-order traversal of
  the tree. Line and char must be 1-based (as in vim.fn.getpos(\".\"))"
  (let [(l c _ _) (vim.treesitter.get_node_range node)]
    (if (or (and (= l line) (<= c char))
            (and (< l line)))
        (m.nextLexicalInnerNode (nextNamedInnerNode node) line char)
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

(fn m.visualChildren [node]
  (fn notBlank? [s] (not (or (= nil s) (= "" s))))
  (->> (node:iter_children)
       (iter.map (fn [c] [c (vim.treesitter.get_node_text c 0)]))
       (iter.filter (fn [[_ t]] (notBlank? t)))
       (iter.map (fn [[c _]] c))))

(fn m.rangeBetween [s e opt]
  "Get the [start row, col, end row, col] range between two nodes. If
  :exclusive=true, then the range excludes the start and end nodes."
  (let [opt (or opt {})
        (a b c d) (vim.treesitter.get_node_range s)
        (e f g h) (vim.treesitter.get_node_range e)]
    (if (. opt :exclusive)
        [c d e f]
        [a b g h])))

m

(local ts (require "nvim-treesitter.ts_utils"))
(local iter (require :slurp/iter))
(local m {})

(fn m.namedParents [root]
  "Returns an iterator over root and its named parents"
  (when (= nil root)
    (error "missing root node"))
  (iter.iterator m.nextNamedParent root))

(fn m.nodesOnLevel [root]
  (when (= nil root)
    (error "missing root node"))
  (iter.iterator m.nextNamedNodeOnLevel root))

(fn m.nodesBelowLevel [root]
  (when (= nil root)
    (error "missing root node"))
  (iter.iterator m.nextNodeBelowLevel root))

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

(fn m.nextNamedNodeOnLevel [node]
  "Get the next sibling or nibling"
  (when (= nil node)
    (error "nil node"))
  (if (node:next_named_sibling)
      (node:next_named_sibling)
      (let [p (m.nextNamedParent node)]
        (if p (m.nextNamedNodeOnLevel p)
              nil))))

(fn m.nextNodeBelowLevel [node]
  (if (> (node:named_child_count) 0)
      (node:named_child 0)
      (m.nextNamedNodeOnLevel node)))

m

(local ts (require "nvim-treesitter.ts_utils"))
(local iter (require :slurp/iter))
(local m {})

(fn m.isLexicallyAfter [root row col]
  "True if the node's row and col is after the given 1,1-offset row and col."
  ; get_node_range is 0,0-based.
  (let [(l c) (vim.treesitter.get_node_range root)
        l (+ 1 l)
        c (+ 1 c)]
    (or (> l row)
        (and (= l row) (> c col)))))

(lambda m.isLexicallyBefore [root row col]
  (let [(l c) (vim.treesitter.get_node_range root)
        l (+ 1 l)
        c (+ 1 c)]
    (or (< l row)
        (and (= l row) (< c col)))))

(fn m.nextParent [node]
  (let [p (node:parent)]
    (if p
        (if (p:named)
            p
            (m.nextParent p))
        nil)))

(fn m.nextAscending [node]
  (when (= nil node)
    (error "nil node"))
  (if (node:next_named_sibling)
      (node:next_named_sibling)
      (let [p (m.nextParent node)]
        (if p (m.nextAscending p)
              nil))))

(lambda m.prevAscending [node]
  (if (node:prev_named_sibling)
      (node:prev_named_sibling)
      (let [p (m.nextParent node)]
        (if p (m.prevAscending p)))))

(fn m.nextDescending [node]
  (if (> (node:named_child_count) 0)
      (node:named_child 0)
      (m.nextAscending node)))

(fn m.prevDescending [node]
  (let [prev (node:prev_named_sibling)]
    (if prev
        (let [c (prev:named_child_count)]
          (if (> c 0)
              (prev:named_child (- c 1))
              prev))
        (m.nextParent node))))

m

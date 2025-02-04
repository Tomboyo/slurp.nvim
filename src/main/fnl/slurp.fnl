(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :tree))
(local iter (require :iter))

; Structured text manipulation using treesitter
;
; We can take advantage of the s-exp tree created by treesitter to very
; accurately manipulate the contents of a file in terms of program structure.
; However, every language has its own grammar with distinct kinds of nodes and
; distinct names for their nodes. For example, strings in fennel consist of
; a string node containing two anonymous children and a string_content child,
; whereas the same structure in clojure is just a single string node. Even so,
; with a small set of functions and a lookup table per-language, we can
; implement a lot of vi-sexp/paredit style functions very accurately for a
; variety of languages, and the whole thing can be extended to new languages
; just with new lookup tables.
;
; Note: If we ask Treesitter for the node under the cursor and the cursor is in
; a string containing code for a different language, Treesitter will actually
; select the node of that embedded language. So if we try to outer-select a
; string, we might end up only selecting something inside it.

(fn select [nodeOrRange]
  (when nodeOrRange (ts.update_selection 0 nodeOrRange)))

(fn innerRange [n]
  (if n
      (let [s (tree.namedChild n 0)
              e (tree.namedChild n -1)]
        (if s (tree.rangeBetween s e)
              (tree.rangeBetween n n)))))

(fn namedParents [node]
  "An iterator over the node and its named parents."
  (iter.iterator
    (fn [n]
      (if n 
          (tree.nextNamedParent n)
          node))))

(fn surroundingNode [n]
  (let [p (and n (tree.nextNamedParent n))]
    (or p n)))

(fn delimitedRange [ldelim rdelim node]
  (let [nodes (node:iter_children)
        left (iter.find
               (fn [n] (= ldelim (vts.get_node_text n 0)))
               nodes)
        right (iter.find
                (fn [n] (= rdelim (vts.get_node_text n 0)))
                nodes)]
    (if (and left right)
        (tree.rangeBetween left right))))

(fn findDelimitedRange [ldelim rdelim node]
  (iter.find
    (fn [n] (delimitedRange ldelim rdelim n))
    (namedParents node)))

(fn forwardIntoElement []
  (let [[_ line col _] (vim.fn.getpos ".")]
    (ts.goto_node (tree.nextLexicalInnerNode (ts.get_node_at_cursor) line col))))

(fn forwardOverElement []
  (let [[_ line col _] (vim.fn.getpos ".")
        node (vts.get_node)]
    (ts.goto_node (tree.nextLexicalOuterNode node line col))))

(fn moveDelimiter [symbol getDelim getSubject getSubjectRange]
  (let [; Iterates over this node and its named parents
        nodes (iter.iterator
                (fn [n]
                  (if n 
                      (tree.nextNamedParent n)
                      (vts.get_node))))
        ; Filter out nodes without a matching delimiter
        nodes (iter.filter
                (fn [n]
                  (let [x (getDelim n)]
                    (and x (= symbol
                              (vts.get_node_text x 0)))))
                nodes)
        ; Filter out nodes which lack a subject to swap with the delimiter
        nodes (iter.filter getSubject nodes)
        node (nodes)]
    (when node
      (let [delim (getDelim node)
            subject (getSubject node)
            range (getSubjectRange delim subject)]
        (ts.swap_nodes delim range 0)))))

(fn slurpForward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n -1))
    (fn [n] (n:next_named_sibling))
    (fn [d s]
      (let [(_ _ c d) (vts.get_node_range d)
            (_ _ g h) (vts.get_node_range s)]
        [c d g h]))))

(fn slurpBackward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n 0))
    (fn [n] (n:prev_named_sibling))
    (fn [d s]
      (let [(a b _ _) (vts.get_node_range d)
            (e f _ _) (vts.get_node_range s)]
        [e f a b]))))

(fn barfForward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n 0))
    (fn [n] (tree.namedChild n 0))
    (fn [_d s]
      (let [sibling (s:next_sibling)
            (a b _ _) (vts.get_node_range s)
            (e f _ _) (vts.get_node_range sibling)]
        [a b e f]))))

(fn barfBackward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n -1))
    (fn [n] (tree.namedChild n -1))
    (fn [d s]
      (let [sibling (s:prev_sibling)
            (_ _ c d) (vts.get_node_range sibling)
            (_ _ g h) (vts.get_node_range s)]
        [c d g h]))))


;; Plug maps
; Element selection
(vim.keymap.set [:v :o] "<Plug>(slurp-select-element)"
                (fn [] (select (vts.get_node))))
(vim.keymap.set [:v :o]
                "<Plug>(slurp-select-inside-element)"
                (fn [] (select (innerRange (vts.get_node)))))
(vim.keymap.set [:v :o]
                "<Plug>(slurp-select-outside-element)"
                (fn [] (select (surroundingNode (vts.get_node)))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-(element))"
                (fn [] (select (findDelimitedRange "(" ")" (vts.get_node)))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-[element])"
                (fn [] (select (findDelimitedRange "[" "]" (vts.get_node)))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-{element})"
                (fn [] (select (findDelimitedRange "{" "}" (vts.get_node)))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-inside-(element))"
                (fn [] (select (innerRange (findDelimitedRange "(" ")" (vts.get_node))))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-inside-[element])"
                (fn [] (select (innerRange (findDelimitedRange "[" "]" (vts.get_node))))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-inside-{element})"
                (fn [] (select (innerRange (findDelimitedRange "{" "}" (vts.get_node))))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-outside-(element))"
                (fn [] (select (surroundingNode (findDelimitedRange "(" ")" (vts.get_node))))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-outside-[element])"
                (fn [] (select (surroundingNode (findDelimitedRange "[" "]" (vts.get_node))))))
(vim.keymap.set [:v :o] "<Plug>(slurp-select-outside-{element})"
                (fn [] (select (surroundingNode (findDelimitedRange "{" "}" (vts.get_node))))))

; motion
(vim.keymap.set [:n :v :o]
              "<Plug>(slurp-forward-into-element)"
              (fn [] (forwardIntoElement))
              {})
(vim.keymap.set [:n :v :o]
              "<Plug>(slurp-forward-over-element)"
              (fn [] (forwardOverElement))
              {})

; manipulation
(vim.keymap.set [:n]
                "<Plug>(slurp-slurp-close-paren-forward)"
                (fn [] (slurpForward ")")))
(vim.keymap.set [:n]
                "<Plug>(slurp-slurp-open-paren-backward)"
                (fn [] (slurpBackward "(")))
(vim.keymap.set [:n]
                "<Plug>(slurp-barf-open-paren-forward)"
                (fn [] (barfForward "(")))
(vim.keymap.set [:n]
                "<Plug>(slurp-barf-close-paren-backward)"
                (fn [] (barfBackward ")")))
(vim.keymap.set [:n]
                "<Plug>(slurp-replace-parent)"
                (fn [] (let [n (vts.get_node)
                             p (tree.nextNamedParent n)]
                         (if p
                             (let [(a b c d) (vts.get_node_range n)
                                   (e f g h) (vts.get_node_range p)
                                   lines (vim.api.nvim_buf_get_text 0 a b c d {})]
                         (vim.api.nvim_buf_set_text 0 e f g h lines))))))
(vim.keymap.set [:n]
                "<Plug>(slurp-delete-surrounding-())"
                (fn []
                  (vim.print "delete surrounding ()")
                  (let [p (findDelimitedRange "(" ")" (vts.get_node))
                        [a b c d] (innerRange p)
                        lines (vim.api.nvim_buf_get_text 0 a b c d {})
                        (e f g h) (vts.get_node_range p)]
                    (vim.api.nvim_buf_set_text 0 e f g h lines))))


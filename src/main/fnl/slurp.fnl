(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :slurp/tree))
(local iter (require :slurp/iter))

(fn select [nodeOrRange]
  (when nodeOrRange (ts.update_selection 0 nodeOrRange)))

(fn innerRange [n]
  (if n
      (let [s (tree.namedChild n 0)
              e (tree.namedChild n -1)]
        (if s (tree.rangeBetween s e)
              (tree.rangeBetween n n)))))

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
    (tree.iterateNamedParents node)))

(fn forwardIntoElement []
  (let [[_ line col _] (vim.fn.getpos ".")]
    (ts.goto_node (tree.nextLexicalInnerNode (ts.get_node_at_cursor) line col))))

(fn forwardOverElement []
  (let [[_ line col _] (vim.fn.getpos ".")
        node (vts.get_node)]
    (ts.goto_node (tree.nextLexicalOuterNode node line col))))

(fn moveDelimiter [symbol getDelim getSubject getSubjectRange]
  (let [ ; Filter out nodes without a matching delimiter
        nodes (iter.filter
                (fn [n]
                  (let [x (getDelim n)]
                    (and x (= symbol
                              (vts.get_node_text x 0)))))
                (tree.iterateNamedParents (vts.get_node)))
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

(fn replaceParent []
  (let [n (vts.get_node)
        p (tree.nextNamedParent n)]
    (if p
        (let [(a b c d) (vts.get_node_range n)
              (e f g h) (vts.get_node_range p)
              lines (vim.api.nvim_buf_get_text 0 a b c d {})]
          (vim.api.nvim_buf_set_text 0 e f g h lines)))))

(fn unwrap [ldelim rdelim]
  (let [p (findDelimitedRange ldelim rdelim (vts.get_node))
        [a b c d] (innerRange p)
        lines (vim.api.nvim_buf_get_text 0 a b c d {})
        (e f g h) (vts.get_node_range p)]
    (vim.api.nvim_buf_set_text 0 e f g h lines)))

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
              forwardIntoElement
              {})
(vim.keymap.set [:n :v :o]
              "<Plug>(slurp-forward-over-element)"
              forwardOverElement
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
                replaceParent)
(vim.keymap.set [:n]
                "<Plug>(slurp-delete-surrounding-())"
                (fn [] (unwrap "(" ")")))

; TODO: once all modules are exported, delete <Plug>s in favor of README. These
; functions need to be exposed so users can customize mappings per language.
{;manipulation
 :slurpForward slurpForward
 :slurpBackward slurpBackward
 :barfForward barfForward
 :barfBackward barfBackward
 :replaceParent replaceParent
 :unwrap unwrap
 ;motion
 :forwardIntoElement forwardIntoElement
 :forwardOverElement forwardOverElement
 ;text objects
 :select select}

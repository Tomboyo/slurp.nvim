(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :slurp/tree))
(local iter (require :slurp/iter))

; Note: in fennel, "foo" is a string node with children (" string_content "). If
; the cursor is on either quote, then the node under the cursor is the whole
; string. If the cursor is on the content, then the node under the cursor is
; only the content. Consider the following state:
;    [:foo :b|ar :baz]
; (selectNode :inner) will only select 'bar'.
;    [:foo |:bar :baz]
; will select 'bar'
;   |[:foo :bar :baz]
; will select ':foo :bar :baz'. So the user will need ways to say _which_ node
; to get the inside selection of (e.g. <LL>ei) v <LL>ei] )
(fn selectNode [arg1 arg2]
  "(selectNode node
               | node opts
               | opts
               | <no arguments>)
   Selects a given node (or the node under the cursor if none is given)
   according to passed options, if any. If {inner = true}, the 'contents' of the
   node are selected only."
  (fn nth [tab n]
    (if (< 0 n)
        (. tab n)
        (. tab (+ (length tab) n 1))))
  (fn innerRange [n]
    (let [cs (->> (tree.visualChildren n)
                  (iter.collect))]
      (case (length cs)
        0 [(vts.get_node_range n)]
        1 [(vts.get_node_range n)]
        2 (tree.rangeBetween (nth cs 1) (nth cs 2) {:exclusive true})
        3 [(vts.get_node_rage (nth cs 2))]
        _ (tree.rangeBetween (nth cs 2) (nth cs -2)))))
  (let [[node opts] (case [arg1 arg2]
                      [nil  nil] [(vts.get_node) {}]
                      (where [arg1 nil] (= :table (type arg1)))
                        [(vts.get_node) arg1]
                      [arg1 nil] [arg1 {}]
                      _ [arg1 arg2])
        range (case opts
                {:inner true} (innerRange node)
                _ [(vts.get_node_range node)])]
    (ts.update_selection 0 range)))

(fn select [nodeOrRange]
  (let [nodeOrRange (or nodeOrRange (vts.get_node))]
      _ (ts.update_selection 0 (or nodeOrRange (vts.get_node)))))

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
    (tree.namedParents node)))

(fn forwardIntoElement []
  (let [[_ line col _] (vim.fn.getpos ".")]
    (ts.goto_node (tree.nextLexicalInnerNode
                    (ts.get_node_at_cursor)
                    (- line 1)
                    (- col 1)))))

(fn forwardOverElement []
  (let [[_ line col _] (vim.fn.getpos ".")
        node (vts.get_node)]
    (ts.goto_node (tree.nextLexicalOuterNode node (- line 1) (- col 1)))))

(fn moveDelimiter [symbol getDelim getSubject getSubjectRange]
  (let [ ; Filter out nodes without a matching delimiter
        nodes (iter.filter
                (fn [n]
                  (let [x (getDelim n)]
                    (and x (= symbol
                              (vts.get_node_text x 0)))))
                (tree.namedParents (vts.get_node)))
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
 :selectNode selectNode}

(local ts (require "nvim-treesitter.ts_utils"))
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

(fn selectElementAtCursor []
  (ts.update_selection 0 (vim.treesitter.get_node)))

(fn selectInsideElementAtCursor []
  (let [n (vim.treesitter.get_node)
        s (tree.namedChild n 0)
        e (tree.namedChild n -1)]
    (ts.update_selection 0 (if s (tree.rangeBetween s e) n))))

(fn selectSurroundingElementAtCursor []
  (let [n (vim.treesitter.get_node)
        p (and n (tree.nextNamedParent n))]
    (ts.update_selection 0 (or p n))))

(fn selectDelimitedElement [open close n]
  (let [n (or n (vim.treesitter.get_node))
        start (tree.child n 0)
        start (and start (vim.treesitter.get_node_text start 0))
        end (tree.child n -1)
        end (and end (vim.treesitter.get_node_text end 0))]
    (if (and (= open start) (= close end))
        (ts.update_selection 0 n)
        (let [p (tree.nextNamedParent n)]
          (if p (selectDelimitedElement open close p))))))

(fn innerElementForward []
  (let [[_ line col _] (vim.fn.getpos ".")]
    (ts.goto_node (tree.nextLexicalInnerNode (ts.get_node_at_cursor) line col))))

(fn outerElementForward []
  (let [[_ line col _] (vim.fn.getpos ".")
        node (vim.treesitter.get_node)]
    (ts.goto_node (tree.nextLexicalOuterNode node line col))))

(fn moveDelimiter [symbol getDelim getSubject getSubjectRange]
  (let [; Iterates over this node and its named parents
        nodes (iter.iterator
                (fn [n]
                  (if n 
                      (tree.nextNamedParent n)
                      (vim.treesitter.get_node))))
        ; Filter out nodes without a matching delimiter
        nodes (iter.filter
                (fn [n]
                  (let [x (getDelim n)]
                    (and x (= symbol
                              (vim.treesitter.get_node_text x 0)))))
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
      (let [(_ _ c d) (vim.treesitter.get_node_range d)
            (_ _ g h) (vim.treesitter.get_node_range s)]
        [c d g h]))))

(fn slurpBackward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n 0))
    (fn [n] (n:prev_named_sibling))
    (fn [d s]
      (let [(a b _ _) (vim.treesitter.get_node_range d)
            (e f _ _) (vim.treesitter.get_node_range s)]
        [e f a b]))))

(fn barfForward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n 0))
    (fn [n] (tree.namedChild n 0))
    (fn [d s]
      (let [sibling (s:next_sibling)
            (a b _ _) (vim.treesitter.get_node_range s)
            (e f _ _) (vim.treesitter.get_node_range sibling)]
        [a b e f]))))

(fn barfBackward [symbol]
  (moveDelimiter
    symbol
    (fn [n] (tree.child n -1))
    (fn [n] (tree.namedChild n -1))
    (fn [d s]
      (let [sibling (s:prev_sibling)
            (_ _ c d) (vim.treesitter.get_node_range sibling)
            (_ _ g h) (vim.treesitter.get_node_range s)]
        [c d g h]))))

(fn setup [opts]
  ;; Plug maps

  ; Element selection
  (vim.keymap.set [:v :o] "<Plug>(slurp-select-element)"
                  selectElementAtCursor)
  (vim.keymap.set [:v :o]
                  "<Plug>(slurp-select-inside-element)"
                  selectInsideElementAtCursor)
  (vim.keymap.set [:v :o]
                  "<Plug>(slurp-select-outside-element)"
                  selectSurroundingElementAtCursor)
  (vim.keymap.set [:v :o] "<Plug>(slurp-select-(element))"
                  (fn [] (selectDelimitedElement "(" ")")))
  (vim.keymap.set [:v :o] "<Plug>(slurp-select-[element])"
                  (fn [] (selectDelimitedElement "[" "]")))
  (vim.keymap.set [:v :o] "<Plug>(slurp-select-{element})"
                  (fn [] (selectDelimitedElement "{" "}")))

  ; motion
  ; todo: rename as into and over (like a debugger)
  (vim.keymap.set [:n :v :o]
                "<Plug>(slurp-inner-element-forward)"
                (fn [] (innerElementForward))
                {})
  (vim.keymap.set [:n :v :o]
                "<Plug>(slurp-outer-element-forward)"
                (fn [] (outerElementForward))
                {})
  
  ; slurp/barf (move delimiter)
  (vim.keymap.set [:n :v :o]
                  "<Plug>(slurp-slurp-close-paren-forward)"
                  (fn [] (slurpForward ")")))
  (vim.keymap.set [:n :v :o]
                  "<Plug>(slurp-slurp-open-paren-backward)"
                  (fn [] (slurpBackward "(")))
  (vim.keymap.set [:n :v :o]
                    "<Plug>(slurp-barf-open-paren-forward)"
                    (fn [] (barfForward "(")))
  (vim.keymap.set [:n :v :o]
                    "<Plug>(slurp-barf-close-paren-backward)"
                    (fn [] (barfBackward ")")))

  ;; Default keymaps

  ; element selection
  (vim.keymap.set [:v :o] "<LocalLeader>ee" "<Plug>(slurp-select-element)")
  (vim.keymap.set [:v :o] "<LocalLeader>ie" "<Plug>(slurp-select-inside-element)")
  (vim.keymap.set [:v :o] "<LocalLeader>ae" "<Plug>(slurp-select-outside-element)")
  (vim.keymap.set [:v :o] "<LocalLeader>e)" "<Plug>(slurp-select-(element))")
  (vim.keymap.set [:v :o] "<LocalLeader>e]" "<Plug>(slurp-select-[element])")
  (vim.keymap.set [:v :o] "<LocalLeader>e}" "<Plug>(slurp-select-{element})")
  (vim.keymap.set [:v :o] "<LocalLeader>il" "<Plug>(slurp-inner-list-to)")
  (vim.keymap.set [:v :o] "<LocalLeader>al" "<Plug>(slurp-outer-list-to)")

  ;motion
  (vim.keymap.set [:n :v :o] "w" "<Plug>(slurp-inner-element-forward)")
  (vim.keymap.set [:n :v :o] "W" "<Plug>(slurp-outer-element-forward)")

  ; slurp/barf (move delimiter)
  (vim.keymap.set [:n :v :o]
                  "<LocalLeader>)l"
                  "<Plug>(slurp-slurp-close-paren-forward)")
  (vim.keymap.set [:n :v :o]
                  "<LocalLeader>(h"
                  "<Plug>(slurp-slurp-open-paren-backward)")
  (vim.keymap.set [:n :v :o]
                  "<LocalLeader>(l"
                  "<Plug>(slurp-barf-open-paren-forward)")
  (vim.keymap.set [:n :v :o]
                  "<LocalLeader>)h"
                  "<Plug>(slurp-barf-close-paren-backward)")

  ; TODO: remove me (debugging keybinds)
  (vim.keymap.set [:n]
                  "<LocalLeader>bld"
                  (fn []
                    (vim.cmd "!make build")
                    (set package.loaded.tree nil)
                    (set package.loaded.iter nil)
                    (set package.loaded.slurp nil)
                    (vim.cmd "ConjureEvalBuf")
                    (setup))
                  {}))

; Module
{: setup}


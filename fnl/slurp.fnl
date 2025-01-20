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

(fn id [x] x)

(fn listInnerRange [node]
  (let [range (ts.node_to_lsp_range node)
        l1 (+ 1 (. range :start :line))
        l2 (+ 1 (. range :end :line))
        c1 (+ 2 (. range :start :character))
        c2 (- (. range :end :character) 1)]
    [l1 c1 l2 c2]))

(local textObjects {
       ; https://github.com/alexmozaidze/tree-sitter-fennel/blob/main/grammar.js
       :fennel {
         :element {
           :inner {
             :nodes {
               :string (fn [node] (node:named_child 0))
               :list listInnerRange
               :sequence listInnerRange
               :table listInnerRange
               :fn_form listInnerRange
               :let_form listInnerRange
               :if_form listInnerRange
               :local_form listInnerRange
               :var_form listInnerRange
               :let_vars listInnerRange
               :sequence_arguments listInnerRange
               :symbol_fragment (fn [node] (node:parent))}
             :default id}
           :outer {
             :nodes {
               :string_content (fn [node] (node:parent))
               :symbol_fragment (fn [node] (node:parent))}
             :default id}}
         :list {
           :stopNodes [:table :table_binding :sequence :local_form :fn_form :let_form :list
                       :let_vars :sequence_arguments :set_form :if_form]}}})

(fn getTextObjectNode [tab node]
  (let [f (or (?. tab :nodes (node:type)) (. tab :default))]
    (f node)))

(fn selectElement [tab node]
  (let [node (getTextObjectNode tab node)]
    (if (= :table (type node))
        (let [[l1 c1 l2 c2] node]
          (vim.fn.setpos "'<" [0 l1 c1 0])
          (vim.fn.setpos "'>" [0 l2 c2 0])
          (vim.cmd "normal! gv"))
        (ts.update_selection 0 node))))

(fn listContains [t e]
  (accumulate [bool false i v (ipairs t) &until bool]
    (or (= e v) bool)))

(fn getStopNode [n stopList]
  (if (listContains stopList (n:type))
      n
      (let [p (n:parent)]
        ; In case the list is missing a stop node, return the root node.
        (if p
            (getStopNode p stopList)
            n))))

;; Api

(fn selectElementCmd [tab]
  (selectElement tab (ts.get_node_at_cursor 0)))

(fn selectListCmd [listTab elTab]
  (let [start (ts.get_node_at_cursor 0)
        node (getStopNode start (. listTab :stopNodes))]
    (selectElement elTab node)))

(fn tsNodeRange [node offset]
  (let [offset (or offset [1 0])
        [r c] offset
        {:start {:line l1 :character c1}
         :end   {:line l2 :character c2}} (ts.node_to_lsp_range node)]
    [(+ r l1) (+ c c1) (+ r l2) (+ c c2)]))

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
  ; Plug maps
  (vim.keymap.set [:v :o] "<Plug>(slurp-inner-element-to)"
                  ; TODO: use ftype or something similar to get language table
                  (fn [] (selectElementCmd (. textObjects :fennel :element :inner)))
                  {})
  (vim.keymap.set [:v :o]
                  "<Plug>(slurp-outer-element-to)"
                  (fn [] (selectElementCmd (. textObjects :fennel :element :outer)))
                  {})
  (vim.keymap.set [:v :o]
                  "<Plug>(slurp-inner-list-to)"
                  (fn [] (selectListCmd (. textObjects :fennel :list)
                                        (. textObjects :fennel :element :inner)))
                  {})
  (vim.keymap.set [:v :o]
                  "<Plug>(slurp-outer-list-to)"
                  (fn [] (selectListCmd (. textObjects :fennel :list)
                                        (. textObjects :fennel :element :outer)))
                  {})
  (vim.keymap.set [:n :v :o]
                "<Plug>(slurp-inner-element-forward)"
                (fn [] (innerElementForward))
                {})
  (vim.keymap.set [:n :v :o]
                "<Plug>(slurp-outer-element-forward)"
                (fn [] (outerElementForward))
                {})
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


  ; Default keymaps
  (vim.keymap.set [:v :o] "<LocalLeader>ie" "<Plug>(slurp-inner-element-to)")
  (vim.keymap.set [:v :o] "<LocalLeader>ae" "<Plug>(slurp-outer-element-to)")
  (vim.keymap.set [:v :o] "<LocalLeader>il" "<Plug>(slurp-inner-list-to)")
  (vim.keymap.set [:v :o] "<LocalLeader>al" "<Plug>(slurp-outer-list-to)")
  (vim.keymap.set [:n :v :o] "w" "<Plug>(slurp-inner-element-forward)")
  (vim.keymap.set [:n :v :o] "W" "<Plug>(slurp-outer-element-forward)")
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
                  (fn [] (vim.cmd "!make build")
                    (set package.loaded.tree nil)
                    (set package.loaded.iter nil)
                    (set package.loaded.slurp nil))
                  {})
  (vim.keymap.set [:n] "<LocalLeader>inf"
                  (fn [] (let [node (ts.get_node_at_cursor)
                               range (tsNodeRange node [1 1])
                               children (faccumulate [acc [] i 0 (node:child_count)]
                                          (let [n (node:child i)]
                                            (table.insert acc (if n (n:type)))
                                            acc))]
                           (vim.print [;"cursor:" (vim.fn.getpos ".")
                                       "node:" (node:type)
                                       ;"range:" range
                                       "sexp:" children])))))

(setup)

; Module
{: setup}


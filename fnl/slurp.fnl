(local ts (require "nvim-treesitter.ts_utils"))

; Structured text manipulation using treesitter
;
; We can take advantage of the s-exp tree created by treesitter to very
; accurately manipulate the contents of a file in terms of program structure.
; However, every language has its own grammar with distinct kinds of nodes and
; distinct names for their nodes. For example, strings in fennel consist of
; string node containing two anonymous children and a string_content child,
; wheras the same structure in clojure is just a single string node. Even so,
; with a small set of functions and a lookup table per-language, we can
; implement a lot of vi-sexp/paredit style functions very accurately for a
; variety of languages, and the whole thing can be extended to new languages
; just with new lookup tables.

(fn id [x] x)

(local textObjects {
       ; https://github.com/alexmozaidze/tree-sitter-fennel/blob/main/grammar.js
       :fennel {
               :inner {
                      :string (fn [node] (node:named_child 0))               
                      }
               :outer {
                      :string_content (fn [node] (node:parent))
                      :symbol_fragment (fn [node] (node:parent))
                      }
               }})
(comment :symbol_fragment (fn [node] (node:parent)))

(fn getTextObjectNode [tab node]
  (let [f (or (?. tab (node:type)) id)]
    (f node)))

(fn selectTextObject [tab opts]
  (let [node (getTextObjectNode tab (ts.get_node_at_cursor 0))]
    (ts.update_selection 0 node)))

(fn setup [opts]
  ; Plug maps
  (vim.keymap.set [:v :o] "<Plug>(slurp-inner-element-to)"
                  ; TODO: use ftype or something similar to get language table
                  (fn [] (selectTextObject (. textObjects :fennel :inner)))
                  {:buffer true})
  (vim.keymap.set [:v :o]
                  "<Plug>(slurp-outer-element-to)"
                  (fn [] (selectTextObject (. textObjects :fennel :outer)))
                  {:buffer true})
  ; Default keymaps
  (vim.keymap.set [:v :o] "<LocalLeader>ie" "<Plug>(slurp-inner-element-to)" {:buffer true})
  (vim.keymap.set [:v :o] "<LocalLeader>ae" "<Plug>(slurp-outer-element-to)" {:buffer true}))

; TODO: remove me
(setup {})
(vim.keymap.set [:n] "<LocalLeader>inf" (fn [] (let [node (ts.get_node_at_cursor)] (vim.print (node:type)))))
(vim.keymap.set [:n] "<LocalLeader>rng" (fn [] (let [node (ts.get_node_at_cursor 0)
                                                     range (ts.node_to_lsp_range node)]
                                                   (vim.print range))))

; Preserved for buffer mark manipulation reference
(comment
   (fn stringTextObject [node inner]
     "Set the range marks for a string node. If inner is true, quotes or other
     delimiters are excluded."
     (let [range (ts.node_to_lsp_range node)
                 {:start {:line sline :character sc} :end {:line eline :character ec}} range
                 sl (+ 1 sline)
                 el (+ 1 sline)
                 line (vim.fn.getline sl)
                 sym (line:sub sc sc)
                 sc (if inner (+ 1 sc) sc)]
       (vim.print { :sl sl :el el :sc sc :ec ec :sym sym})
       (vim.fn.setpos "'<" [0 sl sc 0])
       (vim.fn.setpos "'>" [0 el ec 0])
       (vim.cmd "normal! gv")))

   (fn elementTextObject [inner]
     (let [node (ts.get_node_at_cursor 0)
                range (ts.node_to_lsp_range node)
                cursorBackup (vim.fn.getpos :.)
                {:start {:line sline :character schar} :end {:line eline :character echar}} range]
       (vim.print (node:type))
       (vim.print range)
       (case (node:type)
         "string_content" (stringTextObject node inner)
         "number" (ts.update_selection 0 node)))))

; Module
{: setup}

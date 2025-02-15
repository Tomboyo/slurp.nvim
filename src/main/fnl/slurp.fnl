(local ts (require "nvim-treesitter.ts_utils"))
(local vts vim.treesitter)
(local tree (require :slurp/tree))
(local iter (require :slurp/iter))

(lambda typeMatch [node ?typeOpts]
  (let [typeOpts (or ?typeOpts {:not []})
        types (or (. typeOpts :not) typeOpts)
        anyMatch (iter.find #(= $1 (node:type))
                            (iter.iterate types))]
    (if (. typeOpts :not)
        (not anyMatch)
        anyMatch)))

(fn lang [ftype]
  (let [(ok lang) (pcall #(require (.. :slurp/lang/ (or ftype vim.bo.filetype))))]
    (if ok
        lang
        nil)))

(lambda defaultTypeOpts [key]
  (or (?. (lang) key)
      {:not []}))

(fn slurpSelect [nodeOrRange]
  (if (= nil nodeOrRange)
      nil
      (ts.update_selection 0 nodeOrRange)))

(fn find [types root]
  (if (= nil types)
      (vts.get_node)
      (let [root (or root (vts.get_node))]
        (iter.find
          #(typeMatch $1 types)
          (iter.iterate tree.nextParent root)))))

(fn forwardInto [typeOpts]
  (let [typeOpts (or typeOpts (defaultTypeOpts :motionInto))
        [_ row col _] (vim.fn.getpos ".")
        root (vts.get_node)]
    (ts.goto_node (->> (iter.iterate tree.nextDescending root)
                       (iter.filter #(tree.isLexicallyAfter $1 row col))
                       (iter.find #(typeMatch $1 typeOpts))))))

(fn forwardOver [typeOpts]
  (let [typeOpts (or typeOpts (defaultTypeOpts :motionOver))
        [_ row col _] (vim.fn.getpos ".")
        root (vts.get_node)
        target (->> (iter.iterate tree.nextAscending root)
                    (iter.filter #(tree.isLexicallyAfter $1 row col))
                    (iter.find #(typeMatch $1 typeOpts)))]
    (ts.goto_node target)))

(fn backwardOver [typeOpts]
  (let [typeOpts (or typeOpts (defaultTypeOpts :motionOver))
        [_ row col _] (vim.fn.getpos ".")
        root (vts.get_node)]
    (ts.goto_node (->> (iter.iterate tree.prevAscending root)
                       (iter.filter #(tree.isLexicallyBefore $1 row col))
                       (iter.find #(typeMatch $1 typeOpts))))))

; TODO: usage in README
{;util
 :lang lang
 ;manipulation
 ;TODO
 ;motion
 :forwardInto forwardInto
 :forwardOver forwardOver
 :backwardOver backwardOver
 ;text objects
 :select slurpSelect
 :find find}

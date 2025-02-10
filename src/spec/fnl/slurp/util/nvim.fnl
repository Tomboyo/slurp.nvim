(local iter (require :slurp/iter))
(local m {})

(comment
  ; (2 :b true)
  (find (fn [x] (= :b x)) (ipairs [:a :b :c])))

(fn linesAndPosition [lines]
  (let [cursor (->> (iter.iterate lines)
                    (iter.indexed)
                    (iter.map (fn [[i line]]
                                (let [(col) (string.find line "|")]
                                  [i col])))
                    (iter.find (fn [[_ col]] col)))]
    (when (not cursor)
      (error "missing pipe character in lines input"))
    (let [[row col] cursor
          row (+ 1 row)
          col (- col 1)
          lines (icollect [i v (ipairs lines)]
                   (if (= row i)
                      (v:gsub "|" "")
                      v))]
      (values lines [row col]))))

(comment
  ;; ["first line" "second line" "third line"] [2 2]
  (linesAndPosition ["first line" "se|cond line" "third line"])
  (linesAndPosition ["|first" "second" "third"]))

(fn m.setup [buf lines]
  (let [(lines pos) (linesAndPosition lines)]
    (vim.api.nvim_set_current_buf buf)
    (vim.api.nvim_buf_set_lines buf 0 1 false lines)
    (vim.api.nvim_set_option_value :filetype :fennel {})
    (vim.api.nvim_exec2 "lua vim.treesitter.start()" {})
    (vim.api.nvim_win_set_cursor 0 pos))
  buf)

(fn injectCursor [lines [row col]]
  "Splice a '|' character representing the cursor into lines at the 1,0-offset
  position given by [row col]"
  (icollect [r line (ipairs lines)]
      (if (= row r)
          (let [start (line:sub 1 col)
                end (line:sub (+ 1 col))]
            (.. start "|" end))
          line)))

(comment
  (injectCursor ["foo" "bar" "baz"]
                [2 0]) ;=> [... "|bar" ...]
  (injectCursor ["foo" "bar" "baz"]
                [2 1]) ;=> [... "b|ar" ...]
  (injectCursor ["foo" "bar" "baz"]
                [2 2]) ;=> [... "ba|r" ...]
  (injectCursor ["foo" "bar" "baz"]
                [2 3]) ;=> [... "bar|" ...]
  )

(fn m.actual [buf options]
  (if options
    (let [cursor (vim.api.nvim_win_get_cursor 0) ; 1,0-offset
         lines (vim.api.nvim_buf_get_lines buf 0 -1 true)
         lines (if (. options :cursor)
                  (injectCursor lines cursor)
                  lines)]
      lines)
    ;; legacy - TODO remove me
    (. (vim.api.nvim_buf_get_lines buf 0 1 true) 1)))

(fn m.withBuf [f]
  (let [buf (vim.api.nvim_create_buf false true)
        (success result) (pcall f buf)]
    (vim.api.nvim_buf_delete buf {})
    (when (not success) (error result))))

(fn m.actualSelection [buf]
  (let [[_ a b _] (vim.fn.getpos "v")
        [_ c d _] (vim.fn.getpos ".")
        text (vim.api.nvim_buf_get_text buf (- a 1) (- b 1) (- c 1) d {})]
    text))

m

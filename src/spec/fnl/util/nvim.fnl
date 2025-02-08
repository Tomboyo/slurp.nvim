(local iter (require :iter))
(local m {})

;; TODO: move this into :iter, and also rewrite :iter now that I know how
;; iterators actually work in lua
(fn find [pred iterfunc a i]
  (let [(i v) (iterfunc a i)
        x (pred v)]
    (if x
        (values i v x)
        (if (= nil v)
            (values nil nil)
            (find pred iterfunc a i)))))

(comment
  ; (2 :b true)
  (find (fn [x] (= :b x)) (ipairs [:a :b :c])))

(fn linesAndPosition [lines]
  (let [(row _ col) (find (fn [line] (string.find line "|"))
                        (ipairs lines))]
    (when (not row)
      (error "missing pipe character in lines input"))
    (let [lines (icollect [i v (ipairs lines)]
                   (if (= row i)
                      (v:gsub "|" "")
                      v))]
      (values lines [row (- col 1)]))))

(comment
  ;; ["first line" "second line" "third line"] [2 2]
  (linesAndPosition ["first line" "se|cond line" "third line"]))

(fn m.setup [buf lines]
  (let [(lines pos) (linesAndPosition lines)]
    (vim.api.nvim_set_current_buf buf)
    (vim.api.nvim_buf_set_lines buf 0 1 false lines)
    (vim.api.nvim_set_option_value :filetype :fennel {})
    (vim.api.nvim_exec2 "lua vim.treesitter.start()" {})
    (vim.api.nvim_win_set_cursor 0 pos))
  buf)

(fn injectCursor [lines [row col]]
  (icollect [r line (ipairs lines)]
      (if (= row r)
          (let [start (line:sub 1 (- col 1))
                end (line:sub col)]
            (.. start "|" end))
          line)))

(comment
  (icollect [_ v (ipairs [1 2 3 4 5])]
    (injectCursor ["foo" "bar" "baz"] [2 v]))
  )

(fn m.actual [buf options]
  (if options
    (let [cursor (vim.api.nvim_win_get_cursor 0)
         lines (vim.api.nvim_buf_get_lines buf 0 1 true)
         lines (if (. options :cursor)
                  (injectCursor lines cursor)
                  lines)]
      lines)
    ;; legacy - TODO remove me
    (. (vim.api.nvim_buf_get_lines buf 0 1 true) 1)))

(fn m.withBuf [f]
  (let [buf (vim.api.nvim_create_buf false true)
        (err result) (pcall f buf)]
    (vim.api.nvim_buf_delete buf {})
    (when err (error err))))

m

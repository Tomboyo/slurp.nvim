(local m {})

; This is a function that sets the vim operator function.
; nvim_exec2 returns the name of a function that can be indexed via vim.fn.
;
; See https://github.com/neovim/neovim/issues/14157#issuecomment-1320787927
(local setOpfunc
       (let [program (.. "func s:set_opfunc(val)\n"
                         "  let &opfunc = a:val\n"
                         "endfunc\n"
                         "echon get(function('s:set_opfunc'), 'name')")]
         (. vim.fn (. (vim.api.nvim_exec2 program {:output true}) :output))))

(fn m.opfunc [f]
  "Return a function that sets the vim opfunc to f and calls it. f will receive
  the kind, start, and end of the selected region. Kind is always one of char,
  line, or block."
  (fn []
    (setOpfunc (fn [kind]
                 (let [start (vim.fn.getpos "'[")
                       end (vim.fn.getpos "']")]
                   (f kind start end))))
    (vim.api.nvim_feedkeys "g@" :n false)))

(comment
  (vim.keymap.set [:n]
                  "<LocalLeader>deb"
                  (m.opfunc (fn [kind start end] (vim.print [kind start end])))
                  {}))

m


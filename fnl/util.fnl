; Sets the operatorfunc
; See https://github.com/neovim/neovim/issues/14157#issuecomment-1320787927
; Note: multi-line string will compile with escaped newlines in addition to
; actual newlines; it's not the same as a [[ lua bracket string ]].
(local set_opfunc 
       (let [program (.. "func s:set_opfunc(val)\n"
                         "  let &opfunc = a:val\n"
                         "endfunc\n"
                         "echon get(function('s:set_opfunc'), 'name')")]
         (. vim.fn (vim.api.nvim_exec program true))))

(fn debugOpfunc [kind]
  (let [start (vim.fn.getpos "'[")
        end (vim.fn.getpos "']")]
    (vim.print [kind start end])))

(vim.keymap.set [:n]
                "<LocalLeader>deb"
                (fn []
                  (set_opfunc debugOpfunc)
                  (vim.api.nvim_feedkeys "g@" :n false)
                  )
                {})


(local m {})

(fn m.setup [nvim lines pos]
  (vim.rpcrequest nvim :nvim_buf_set_lines 0 0 1 false lines)
  (vim.rpcrequest nvim
                  :nvim_set_option_value
                  :filetype
                  :fennel
                  {})
  (vim.rpcrequest nvim
                  :nvim_exec_lua
                  "vim.treesitter.start()"
                  {})
  (vim.rpcrequest nvim
                  :nvim_win_set_cursor
                  0
                  pos))

(fn m.plug [nvim mapping]
  (vim.rpcrequest
    nvim
    :nvim_feedkeys
    (vim.api.nvim_replace_termcodes mapping true true true)
    :m
    false))

(fn m.actual [nvim]
  (. (vim.rpcrequest nvim :nvim_buf_get_lines 0 0 1 true) 1))

m

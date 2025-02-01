local m = {}
m.setup = function(nvim, lines, pos)
  vim.rpcrequest(nvim, "nvim_buf_set_lines", 0, 0, 1, false, lines)
  vim.rpcrequest(nvim, "nvim_set_option_value", "filetype", "fennel", {})
  vim.rpcrequest(nvim, "nvim_exec_lua", "vim.treesitter.start()", {})
  return vim.rpcrequest(nvim, "nvim_win_set_cursor", 0, pos)
end
m.plug = function(nvim, mapping)
  return vim.rpcrequest(nvim, "nvim_feedkeys", vim.api.nvim_replace_termcodes(mapping, true, true, true), "m", false)
end
m.actual = function(nvim)
  return vim.rpcrequest(nvim, "nvim_buf_get_lines", 0, 0, 1, true)[1]
end
return m

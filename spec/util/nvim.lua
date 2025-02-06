local m = {}
m.setup = function(buf, lines, pos)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, 1, false, lines)
  vim.api.nvim_set_option_value("filetype", "fennel", {})
  vim.api.nvim_exec2("lua vim.treesitter.start()", {})
  vim.api.nvim_win_set_cursor(0, pos)
  return buf
end
m.actual = function(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
end
return m

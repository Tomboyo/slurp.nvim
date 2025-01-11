local function selectExpression()
  local _let_1_ = vim.api.nvim_win_get_cursor(0)
  local line = _let_1_[1]
  local col = _let_1_[2]
  return print(string.format("line %s col %s", line, col))
end
local function setup(config)
  return vim.keymap.set("n", "<Plug>(slurp-expression)", selectExpression)
end
return {setup = setup}

local LPAR = "("
local function indexOf(text, char, origin, offset)
  local i = offset
  while ((i > 1) and not (char == text:sub(i, i))) do
    do local _ = (i + offset) end
  end
  return i
end
local function selectExpression()
  local _local_1_ = vim.api.nvim_win_get_cursor(0)
  local lin = _local_1_[1]
  local col = _local_1_[2]
  local text = vim.fn.getline(lin)
  local x = indexOf(text, LPAR, col, -1)
  if (0 > x) then
    return print(string.format("%s,%s: %s", lin, x, text:sub(x, x)))
  else
    return print("not found")
  end
end
local function setup(config)
  return vim.keymap.set("n", "<Plug>(slurp-expression)", selectExpression)
end
return {setup = setup}

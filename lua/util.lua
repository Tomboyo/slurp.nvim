local set_opfunc
do
  local program = ("func s:set_opfunc(val)\n" .. "  let &opfunc = a:val\n" .. "endfunc\n" .. "echon get(function('s:set_opfunc'), 'name')")
  set_opfunc = vim.fn[vim.api.nvim_exec(program, true)]
end
local function debugOpfunc(kind)
  local start = vim.fn.getpos("'[")
  local _end = vim.fn.getpos("']")
  return vim.print({kind, start, _end})
end
local function _1_()
  set_opfunc(debugOpfunc)
  return vim.api.nvim_feedkeys("g@", "n", false)
end
return vim.keymap.set({"n"}, "<LocalLeader>deb", _1_, {})

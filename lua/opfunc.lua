local m = {}
local setOpfunc
do
  local program = ("func s:set_opfunc(val)\n" .. "  let &opfunc = a:val\n" .. "endfunc\n" .. "echon get(function('s:set_opfunc'), 'name')")
  setOpfunc = vim.fn[vim.api.nvim_exec2(program, {output = true}).output]
end
m.opfunc = function(f)
  local function _1_()
    local function _2_(kind)
      local start = vim.fn.getpos("'[")
      local _end = vim.fn.getpos("']")
      return f(kind, start, _end)
    end
    setOpfunc(_2_)
    return vim.api.nvim_feedkeys("g@", "n", false)
  end
  return _1_
end
--[[ (vim.keymap.set ["n"] "<LocalLeader>deb" (m.opfunc (fn [kind start end] (vim.print [kind start end]))) {}) ]]
return m

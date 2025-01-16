local ts = require("nvim-treesitter.ts_utils")
local function id(x)
  return x
end
local function listInnerRange(node)
  local range = ts.node_to_lsp_range(node)
  local l1 = (1 + range.start.line)
  local l2 = (1 + range["end"].line)
  local c1 = (2 + range.start.character)
  local c2 = (range["end"].character - 1)
  return {l1, c1, l2, c2}
end
local textObjects
local function _1_(node)
  return node:named_child(0)
end
local function _2_(node)
  return node:parent()
end
local function _3_(node)
  return node:parent()
end
local function _4_(node)
  return node:parent()
end
textObjects = {fennel = {element = {inner = {nodes = {string = _1_, list = listInnerRange, sequence = listInnerRange, table = listInnerRange, fn_form = listInnerRange, let_form = listInnerRange, if_form = listInnerRange, local_form = listInnerRange, var_form = listInnerRange, let_vars = listInnerRange, sequence_arguments = listInnerRange, symbol_fragment = _2_}, default = id}, outer = {nodes = {string_content = _3_, symbol_fragment = _4_}, default = id}}, list = {stopNodes = {"table", "table_binding", "sequence", "local_form", "fn_form", "let_form", "list", "let_vars", "sequence_arguments", "set_form", "if_form"}}}}
local function getTextObjectNode(tab, node)
  local f
  local _6_
  do
    local t_5_ = tab
    if (nil ~= t_5_) then
      t_5_ = t_5_.nodes
    else
    end
    if (nil ~= t_5_) then
      t_5_ = t_5_[node:type()]
    else
    end
    _6_ = t_5_
  end
  f = (_6_ or tab.default)
  return f(node)
end
local function selectElement(tab, node)
  local node0 = getTextObjectNode(tab, node)
  if ("table" == type(node0)) then
    local l1 = node0[1]
    local c1 = node0[2]
    local l2 = node0[3]
    local c2 = node0[4]
    vim.fn.setpos("'<", {0, l1, c1, 0})
    vim.fn.setpos("'>", {0, l2, c2, 0})
    return vim.cmd("normal! gv")
  else
    return ts.update_selection(0, node0)
  end
end
local function listContains(t, e)
  local bool = false
  for i, v in ipairs(t) do
    if bool then break end
    bool = ((e == v) or bool)
  end
  return bool
end
local function getStopNode(n, stopList)
  if listContains(stopList, n:type()) then
    return n
  else
    local p = n:parent()
    if p then
      return getStopNode(p, stopList)
    else
      return n
    end
  end
end
local function selectElementCmd(tab)
  return selectElement(tab, ts.get_node_at_cursor(0))
end
local function selectListCmd(listTab, elTab)
  local start = ts.get_node_at_cursor(0)
  local node = getStopNode(start, listTab.stopNodes)
  return selectElement(elTab, node)
end
local function nextNode(node)
  local s = node:next_sibling()
  if s then
    return s
  else
    return nextNode(node:parent())
  end
end
local function tsNodeRange(node, offset)
  local offset0 = (offset or {1, 0})
  local r = offset0[1]
  local c = offset0[2]
  local _let_13_ = ts.node_to_lsp_range(node)
  local _let_14_ = _let_13_["start"]
  local l1 = _let_14_["line"]
  local c1 = _let_14_["character"]
  local _let_15_ = _let_13_["end"]
  local l2 = _let_15_["line"]
  local c2 = _let_15_["character"]
  return {(r + l1), (c + c1), (r + l2), (c + c2)}
end
local function elementMotionStart(listTab, startingPos, el, max)
  local max0 = (max or 10)
  local startingPos0 = (startingPos or vim.fn.getpos("."))
  local _ = startingPos0[1]
  local sLine = startingPos0[2]
  local sChar = startingPos0[3]
  local _0 = startingPos0[4]
  local el0
  local or_16_ = el
  if not or_16_ then
    local list = getStopNode(ts.get_node_at_cursor(0), listTab.stopNodes)
    or_16_ = list:named_child(0)
  end
  el0 = or_16_
  local _let_18_ = tsNodeRange(el0, {1, 1})
  local eSLine = _let_18_[1]
  local eSChar = _let_18_[2]
  local _1 = _let_18_[3]
  local _2 = _let_18_[4]
  if (((sLine == eSLine) and (sChar < eSChar)) or (sLine < eSLine)) then
    return ts.goto_node(el0)
  else
    if (max0 > 1) then
      return elementMotionStart(listTab, startingPos0, nextNode(el0), (max0 - 1))
    else
      return vim.print("Could not find next element within 10 iterations")
    end
  end
end
local function setup(opts)
  local function _21_()
    return selectElementCmd(textObjects.fennel.element.inner)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-inner-element-to)", _21_, {})
  local function _22_()
    return selectElementCmd(textObjects.fennel.element.outer)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-outer-element-to)", _22_, {})
  local function _23_()
    return selectListCmd(textObjects.fennel.list, textObjects.fennel.element.inner)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-inner-list-to)", _23_, {})
  local function _24_()
    return selectListCmd(textObjects.fennel.list, textObjects.fennel.element.outer)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-outer-list-to)", _24_, {})
  local function _25_()
    return elementMotionStart(textObjects.fennel.list)
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-motion-element-forward)", _25_, {})
  vim.keymap.set({"v", "o"}, "<LocalLeader>ie", "<Plug>(slurp-inner-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ae", "<Plug>(slurp-outer-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>il", "<Plug>(slurp-inner-list-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>al", "<Plug>(slurp-outer-list-to)")
  vim.keymap.set({"n", "v", "o"}, "w", "<Plug>(slurp-motion-element-forward)")
  local function _26_()
    local node = ts.get_node_at_cursor()
    local range = tsNodeRange(node, {1, 1})
    return vim.print({vim.fn.getpos("."), node:type(), range})
  end
  return vim.keymap.set({"n"}, "<LocalLeader>inf", _26_)
end
setup()
return {setup = setup}

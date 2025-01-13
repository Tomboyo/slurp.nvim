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
  return listInnerRange(node)
end
local function _3_(node)
  return listInnerRange(node)
end
local function _4_(node)
  return listInnerRange(node)
end
local function _5_(node)
  return listInnerRange(node)
end
local function _6_(node)
  return listInnerRange(node)
end
local function _7_(node)
  return listInnerRange(node)
end
local function _8_(node)
  return listInnerRange(node)
end
local function _9_(node)
  return listInnerRange(node)
end
local function _10_(node)
  return listInnerRange(node)
end
local function _11_(node)
  return listInnerRange(node)
end
local function _12_(node)
  return node:parent()
end
local function _13_(node)
  return node:parent()
end
textObjects = {fennel = {element = {inner = {nodes = {string = _1_, list = _2_, sequence = _3_, table = _4_, fn_form = _5_, let_form = _6_, if_form = _7_, local_form = _8_, var_form = _9_, let_vars = _10_, sequence_arguments = _11_}, default = id}, outer = {nodes = {string_content = _12_, symbol_fragment = _13_}, default = id}}, list = {stopNodes = {"table", "sequence", "local_form", "fn_form", "let_form", "list", "let_vars", "sequence_arguments"}}}}
local function getTextObjectNode(tab, node)
  local f
  local _15_
  do
    local t_14_ = tab
    if (nil ~= t_14_) then
      t_14_ = t_14_.nodes
    else
    end
    if (nil ~= t_14_) then
      t_14_ = t_14_[node:type()]
    else
    end
    _15_ = t_14_
  end
  f = (_15_ or tab.default)
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
local function selectElementCmd(tab)
  return selectElement(tab, ts.get_node_at_cursor(0))
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
local function selectListCmd(listTab, elTab)
  local start = ts.get_node_at_cursor(0)
  local node = getStopNode(start, listTab.stopNodes)
  return selectElement(elTab, node)
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
  vim.keymap.set({"v", "o"}, "<LocalLeader>ie", "<Plug>(slurp-inner-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ae", "<Plug>(slurp-outer-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>il", "<Plug>(slurp-inner-list-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>al", "<Plug>(slurp-outer-list-to)")
  local function _25_()
    local node = ts.get_node_at_cursor()
    return vim.print(node:type())
  end
  vim.keymap.set({"n"}, "<LocalLeader>inf", _25_)
  local function _26_()
    local node = ts.get_node_at_cursor(0)
    local range = ts.node_to_lsp_range(node)
    return vim.print(range)
  end
  return vim.keymap.set({"n"}, "<LocalLeader>rng", _26_)
end
return {setup = setup}

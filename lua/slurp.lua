local ts = require("nvim-treesitter.ts_utils")
local tree = require("tree")
local iter = require("iter")
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
local function tsNodeRange(node, offset)
  local offset0 = (offset or {1, 0})
  local r = offset0[1]
  local c = offset0[2]
  local _let_12_ = ts.node_to_lsp_range(node)
  local _let_13_ = _let_12_["start"]
  local l1 = _let_13_["line"]
  local c1 = _let_13_["character"]
  local _let_14_ = _let_12_["end"]
  local l2 = _let_14_["line"]
  local c2 = _let_14_["character"]
  return {(r + l1), (c + c1), (r + l2), (c + c2)}
end
local function innerElementForward()
  local _let_15_ = vim.fn.getpos(".")
  local _ = _let_15_[1]
  local line = _let_15_[2]
  local col = _let_15_[3]
  local _0 = _let_15_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), line, col))
end
local function outerElementForward()
  local _let_16_ = vim.fn.getpos(".")
  local _ = _let_16_[1]
  local line = _let_16_[2]
  local col = _let_16_[3]
  local _0 = _let_16_[4]
  local node = vim.treesitter.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, line, col))
end
local function slurpForward(ldelim, rdelim)
  local nodes
  local function _17_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_17_)
  local isDelimited
  local function _19_(n)
    local _let_20_ = tree.delimiters(n)
    local a = _let_20_[1]
    local b = _let_20_[2]
    return (a and b and (ldelim == a:type()) and (rdelim == b:type()))
  end
  isDelimited = _19_
  local hasSibling
  local function _21_(n)
    return n:next_named_sibling()
  end
  hasSibling = _21_
  local nodes0 = iter.filter(isDelimited, nodes)
  local nodes1 = iter.filter(hasSibling, nodes0)
  local node = nodes1()
  if node then
    local _let_22_ = tree.delimiters(node)
    local _ = _let_22_[1]
    local _end = _let_22_[2]
    local _0, _1, sl, sc = vim.treesitter.get_node_range(_end)
    local _2, _3, el, ec = vim.treesitter.get_node_range(node:next_named_sibling())
    vim.print({sl, sc})
    return ts.swap_nodes(_end, {sl, sc, el, ec}, 0)
  else
    return nil
  end
end
--[[ ("cats" ("frogs" ("dogs" "skenks")) "birds" "horses") ]]
local function setup(opts)
  local function _24_()
    return selectElementCmd(textObjects.fennel.element.inner)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-inner-element-to)", _24_, {})
  local function _25_()
    return selectElementCmd(textObjects.fennel.element.outer)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-outer-element-to)", _25_, {})
  local function _26_()
    return selectListCmd(textObjects.fennel.list, textObjects.fennel.element.inner)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-inner-list-to)", _26_, {})
  local function _27_()
    return selectListCmd(textObjects.fennel.list, textObjects.fennel.element.outer)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-outer-list-to)", _27_, {})
  local function _28_()
    return innerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-inner-element-forward)", _28_, {})
  local function _29_()
    return outerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-outer-element-forward)", _29_, {})
  local function _30_()
    return slurpForward("(", ")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-close-paren-forward)", _30_)
  vim.keymap.set({"v", "o"}, "<LocalLeader>ie", "<Plug>(slurp-inner-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ae", "<Plug>(slurp-outer-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>il", "<Plug>(slurp-inner-list-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>al", "<Plug>(slurp-outer-list-to)")
  vim.keymap.set({"n", "v", "o"}, "w", "<Plug>(slurp-inner-element-forward)")
  vim.keymap.set({"n", "v", "o"}, "W", "<Plug>(slurp-outer-element-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)", "<Plug>(slurp-slurp-close-paren-forward)")
  local function _31_()
    vim.cmd("!make build")
    package.loaded.tree = nil
    return nil
  end
  vim.keymap.set({"n"}, "<LocalLeader>bld", _31_, {})
  local function _32_()
    local node = ts.get_node_at_cursor()
    local range = tsNodeRange(node, {1, 1})
    local children
    do
      local acc = {}
      for i = 0, node:child_count() do
        local n = node:child(i)
        local function _33_()
          if n then
            return n:type()
          else
            return nil
          end
        end
        table.insert(acc, _33_())
        acc = acc
      end
      children = acc
    end
    return vim.print({"node:", node:type(), "sexp:", children})
  end
  return vim.keymap.set({"n"}, "<LocalLeader>inf", _32_)
end
setup()
return {setup = setup}

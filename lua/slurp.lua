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
local function slurpForward(delim)
  local nodes
  local function _17_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_17_)
  local nodes0
  local function _19_(n)
    local x = tree.child(n, -1)
    return (x and (delim == x:type()))
  end
  nodes0 = iter.filter(_19_, nodes)
  local nodes1
  local function _20_(n)
    return n:next_named_sibling()
  end
  nodes1 = iter.filter(_20_, nodes0)
  local node = nodes1()
  if node then
    local delim0 = tree.child(node, -1)
    local subject = node:next_named_sibling()
    local _, _0, c, d = vim.treesitter.get_node_range(delim0)
    local _1, _2, g, h = vim.treesitter.get_node_range(subject)
    return ts.swap_nodes(delim0, {c, d, g, h}, 0)
  else
    return nil
  end
end
local function slurpBackward(delim)
  local nodes
  local function _22_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_22_)
  local nodes0
  local function _24_(n)
    local x = tree.child(n, 0)
    return (x and (delim == x:type()))
  end
  nodes0 = iter.filter(_24_, nodes)
  local nodes1
  local function _25_(n)
    return n:prev_named_sibling()
  end
  nodes1 = iter.filter(_25_, nodes0)
  local node = nodes1()
  if node then
    local delim0 = tree.child(node, 0)
    local subject = node:prev_named_sibling()
    local a, b, _, _0 = vim.treesitter.get_node_range(delim0)
    local e, f, _1, _2 = vim.treesitter.get_node_range(subject)
    return ts.swap_nodes(delim0, {e, f, a, b}, 0)
  else
    return nil
  end
end
local function barfForward(delim)
  local nodes
  local function _27_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_27_)
  local nodes0
  local function _29_(n)
    local x = tree.child(n, 0)
    return (x and (delim == x:type()))
  end
  nodes0 = iter.filter(_29_, nodes)
  local nodes1
  local function _30_(n)
    return tree.namedChild(n, 0)
  end
  nodes1 = iter.filter(_30_, nodes0)
  local node = nodes1()
  if node then
    local delim0 = tree.child(node, 0)
    local subject = tree.namedChild(node, 0)
    local sibling = subject:next_sibling()
    local a, b, _, _0 = vim.treesitter.get_node_range(subject)
    local e, f, _1, _2 = vim.treesitter.get_node_range(sibling)
    return ts.swap_nodes(delim0, {a, b, e, f}, 0)
  else
    return nil
  end
end
local function barfBackward(delim)
  local nodes
  local function _32_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_32_)
  local nodes0
  local function _34_(n)
    local x = tree.child(n, -1)
    return (x and (delim == x:type()))
  end
  nodes0 = iter.filter(_34_, nodes)
  local nodes1
  local function _35_(n)
    return tree.namedChild(n, -1)
  end
  nodes1 = iter.filter(_35_, nodes0)
  local node = nodes1()
  if node then
    local delim0 = tree.child(node, -1)
    local subject = tree.namedChild(node, -1)
    local sibling = subject:prev_sibling()
    local _, _0, c, d = vim.treesitter.get_node_range(sibling)
    local _1, _2, g, h = vim.treesitter.get_node_range(subject)
    return ts.swap_nodes(delim0, {c, d, g, h}, 0)
  else
    return nil
  end
end
--[[ ("a" ("b") ("c" "d")) ]]
local function setup(opts)
  local function _37_()
    return selectElementCmd(textObjects.fennel.element.inner)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-inner-element-to)", _37_, {})
  local function _38_()
    return selectElementCmd(textObjects.fennel.element.outer)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-outer-element-to)", _38_, {})
  local function _39_()
    return selectListCmd(textObjects.fennel.list, textObjects.fennel.element.inner)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-inner-list-to)", _39_, {})
  local function _40_()
    return selectListCmd(textObjects.fennel.list, textObjects.fennel.element.outer)
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-outer-list-to)", _40_, {})
  local function _41_()
    return innerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-inner-element-forward)", _41_, {})
  local function _42_()
    return outerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-outer-element-forward)", _42_, {})
  local function _43_()
    return slurpForward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-close-paren-forward)", _43_)
  local function _44_()
    return slurpBackward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-open-paren-backward)", _44_)
  local function _45_()
    return barfForward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-open-paren-forward)", _45_)
  local function _46_()
    return barfBackward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-close-paren-backward)", _46_)
  vim.keymap.set({"v", "o"}, "<LocalLeader>ie", "<Plug>(slurp-inner-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ae", "<Plug>(slurp-outer-element-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>il", "<Plug>(slurp-inner-list-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>al", "<Plug>(slurp-outer-list-to)")
  vim.keymap.set({"n", "v", "o"}, "w", "<Plug>(slurp-inner-element-forward)")
  vim.keymap.set({"n", "v", "o"}, "W", "<Plug>(slurp-outer-element-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)l", "<Plug>(slurp-slurp-close-paren-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>(h", "<Plug>(slurp-slurp-open-paren-backward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>(l", "<Plug>(slurp-barf-open-paren-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)h", "<Plug>(slurp-barf-close-paren-backward)")
  local function _47_()
    vim.cmd("!make build")
    package.loaded.tree = nil
    package.loaded.iter = nil
    package.loaded.slurp = nil
    return nil
  end
  vim.keymap.set({"n"}, "<LocalLeader>bld", _47_, {})
  local function _48_()
    local node = ts.get_node_at_cursor()
    local range = tsNodeRange(node, {1, 1})
    local children
    do
      local acc = {}
      for i = 0, node:child_count() do
        local n = node:child(i)
        local function _49_()
          if n then
            return n:type()
          else
            return nil
          end
        end
        table.insert(acc, _49_())
        acc = acc
      end
      children = acc
    end
    return vim.print({"node:", node:type(), "sexp:", children})
  end
  return vim.keymap.set({"n"}, "<LocalLeader>inf", _48_)
end
setup()
return {setup = setup}

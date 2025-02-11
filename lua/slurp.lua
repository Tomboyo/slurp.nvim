local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("slurp/tree")
local iter = require("slurp/iter")
local function selectNode(arg1, arg2)
  local function nth(tab, n)
    if (0 < n) then
      return tab[n]
    else
      return tab[(#tab + n + 1)]
    end
  end
  local function innerRange(n)
    local cs = iter.collect(tree.visualChildren(n))
    local _2_ = #cs
    if (_2_ == 0) then
      return {vts.get_node_range(n)}
    elseif (_2_ == 1) then
      return {vts.get_node_range(n)}
    elseif (_2_ == 2) then
      return tree.rangeBetween(nth(cs, 1), nth(cs, 2), {exclusive = true})
    elseif (_2_ == 3) then
      return {vts.get_node_rage(nth(cs, 2))}
    else
      local _ = _2_
      return tree.rangeBetween(nth(cs, 2), nth(cs, -2))
    end
  end
  local function _5_()
    local _4_ = {arg1, arg2}
    if ((_4_[1] == nil) and (_4_[2] == nil)) then
      return {vts.get_node(), {}}
    else
      local and_6_ = ((_G.type(_4_) == "table") and (nil ~= _4_[1]) and (_4_[2] == nil))
      if and_6_ then
        local arg10 = _4_[1]
        and_6_ = ("table" == type(arg10))
      end
      if and_6_ then
        local arg10 = _4_[1]
        return {vts.get_node(), arg10}
      elseif ((nil ~= _4_[1]) and (_4_[2] == nil)) then
        local arg10 = _4_[1]
        return {arg10, {}}
      else
        local _ = _4_
        return {arg1, arg2}
      end
    end
  end
  local _let_9_ = _5_()
  local node = _let_9_[1]
  local opts = _let_9_[2]
  local range
  if ((_G.type(opts) == "table") and (opts.inner == true)) then
    range = innerRange(node)
  else
    local _ = opts
    range = {vts.get_node_range(node)}
  end
  return ts.update_selection(0, range)
end
local function select(nodeOrRange)
  local nodeOrRange0 = (nodeOrRange or vts.get_node())
  return ts.update_selection(0, (nodeOrRange0 or vts.get_node()))
end
local function innerRange(n)
  if n then
    local s = tree.namedChild(n, 0)
    local e = tree.namedChild(n, -1)
    if s then
      return tree.rangeBetween(s, e)
    else
      return tree.rangeBetween(n, n)
    end
  else
    return nil
  end
end
local function surroundingNode(n)
  local p = (n and tree.nextNamedParent(n))
  return (p or n)
end
local function delimitedRange(ldelim, rdelim, node)
  local nodes = node:iter_children()
  local left
  local function _13_(n)
    return (ldelim == vts.get_node_text(n, 0))
  end
  left = iter.find(_13_, nodes)
  local right
  local function _14_(n)
    return (rdelim == vts.get_node_text(n, 0))
  end
  right = iter.find(_14_, nodes)
  if (left and right) then
    return tree.rangeBetween(left, right)
  else
    return nil
  end
end
local function findDelimitedRange(ldelim, rdelim, node)
  local function _16_(n)
    return delimitedRange(ldelim, rdelim, n)
  end
  return iter.find(_16_, tree.namedParents(node))
end
local function forwardIntoElement()
  local _let_17_ = vim.fn.getpos(".")
  local _ = _let_17_[1]
  local line = _let_17_[2]
  local col = _let_17_[3]
  local _0 = _let_17_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), (line - 1), (col - 1)))
end
local function forwardOverElement()
  local _let_18_ = vim.fn.getpos(".")
  local _ = _let_18_[1]
  local line = _let_18_[2]
  local col = _let_18_[3]
  local _0 = _let_18_[4]
  local node = vts.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, (line - 1), (col - 1)))
end
local function moveDelimiter(symbol, getDelim, getSubject, getSubjectRange)
  local nodes
  local function _19_(n)
    local x = getDelim(n)
    return (x and (symbol == vts.get_node_text(x, 0)))
  end
  nodes = iter.filter(_19_, tree.namedParents(vts.get_node()))
  local nodes0 = iter.filter(getSubject, nodes)
  local node = nodes0()
  if node then
    local delim = getDelim(node)
    local subject = getSubject(node)
    local range = getSubjectRange(delim, subject)
    return ts.swap_nodes(delim, range, 0)
  else
    return nil
  end
end
local function slurpForward(symbol)
  local function _21_(n)
    return tree.child(n, -1)
  end
  local function _22_(n)
    return n:next_named_sibling()
  end
  local function _23_(d, s)
    local _, _0, c, d0 = vts.get_node_range(d)
    local _1, _2, g, h = vts.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _21_, _22_, _23_)
end
local function slurpBackward(symbol)
  local function _24_(n)
    return tree.child(n, 0)
  end
  local function _25_(n)
    return n:prev_named_sibling()
  end
  local function _26_(d, s)
    local a, b, _, _0 = vts.get_node_range(d)
    local e, f, _1, _2 = vts.get_node_range(s)
    return {e, f, a, b}
  end
  return moveDelimiter(symbol, _24_, _25_, _26_)
end
local function barfForward(symbol)
  local function _27_(n)
    return tree.child(n, 0)
  end
  local function _28_(n)
    return tree.namedChild(n, 0)
  end
  local function _29_(_d, s)
    local sibling = s:next_sibling()
    local a, b, _, _0 = vts.get_node_range(s)
    local e, f, _1, _2 = vts.get_node_range(sibling)
    return {a, b, e, f}
  end
  return moveDelimiter(symbol, _27_, _28_, _29_)
end
local function barfBackward(symbol)
  local function _30_(n)
    return tree.child(n, -1)
  end
  local function _31_(n)
    return tree.namedChild(n, -1)
  end
  local function _32_(d, s)
    local sibling = s:prev_sibling()
    local _, _0, c, d0 = vts.get_node_range(sibling)
    local _1, _2, g, h = vts.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _30_, _31_, _32_)
end
local function replaceParent()
  local n = vts.get_node()
  local p = tree.nextNamedParent(n)
  if p then
    local a, b, c, d = vts.get_node_range(n)
    local e, f, g, h = vts.get_node_range(p)
    local lines = vim.api.nvim_buf_get_text(0, a, b, c, d, {})
    return vim.api.nvim_buf_set_text(0, e, f, g, h, lines)
  else
    return nil
  end
end
local function unwrap(ldelim, rdelim)
  local p = findDelimitedRange(ldelim, rdelim, vts.get_node())
  local _let_34_ = innerRange(p)
  local a = _let_34_[1]
  local b = _let_34_[2]
  local c = _let_34_[3]
  local d = _let_34_[4]
  local lines = vim.api.nvim_buf_get_text(0, a, b, c, d, {})
  local e, f, g, h = vts.get_node_range(p)
  return vim.api.nvim_buf_set_text(0, e, f, g, h, lines)
end
local function _35_()
  return select(vts.get_node())
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-element)", _35_)
local function _36_()
  return select(innerRange(vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-element)", _36_)
local function _37_()
  return select(surroundingNode(vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-element)", _37_)
local function _38_()
  return select(findDelimitedRange("(", ")", vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-(element))", _38_)
local function _39_()
  return select(findDelimitedRange("[", "]", vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-[element])", _39_)
local function _40_()
  return select(findDelimitedRange("{", "}", vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-{element})", _40_)
local function _41_()
  return select(innerRange(findDelimitedRange("(", ")", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-(element))", _41_)
local function _42_()
  return select(innerRange(findDelimitedRange("[", "]", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-[element])", _42_)
local function _43_()
  return select(innerRange(findDelimitedRange("{", "}", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-{element})", _43_)
local function _44_()
  return select(surroundingNode(findDelimitedRange("(", ")", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-(element))", _44_)
local function _45_()
  return select(surroundingNode(findDelimitedRange("[", "]", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-[element])", _45_)
local function _46_()
  return select(surroundingNode(findDelimitedRange("{", "}", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-{element})", _46_)
vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-forward-into-element)", forwardIntoElement, {})
vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-forward-over-element)", forwardOverElement, {})
local function _47_()
  return slurpForward(")")
end
vim.keymap.set({"n"}, "<Plug>(slurp-slurp-close-paren-forward)", _47_)
local function _48_()
  return slurpBackward("(")
end
vim.keymap.set({"n"}, "<Plug>(slurp-slurp-open-paren-backward)", _48_)
local function _49_()
  return barfForward("(")
end
vim.keymap.set({"n"}, "<Plug>(slurp-barf-open-paren-forward)", _49_)
local function _50_()
  return barfBackward(")")
end
vim.keymap.set({"n"}, "<Plug>(slurp-barf-close-paren-backward)", _50_)
vim.keymap.set({"n"}, "<Plug>(slurp-replace-parent)", replaceParent)
local function _51_()
  return unwrap("(", ")")
end
vim.keymap.set({"n"}, "<Plug>(slurp-delete-surrounding-())", _51_)
return {slurpForward = slurpForward, slurpBackward = slurpBackward, barfForward = barfForward, barfBackward = barfBackward, replaceParent = replaceParent, unwrap = unwrap, forwardIntoElement = forwardIntoElement, forwardOverElement = forwardOverElement, selectNode = selectNode}

local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("slurp/tree")
local iter = require("slurp/iter")
local function slurpSelect(nodeOrRange)
  vim.print(nodeOrRange)
  if (nil == nodeOrRange) then
    return nil
  else
    return ts.update_selection(0, nodeOrRange)
  end
end
local function find(types, root)
  local root0 = (root or vts.get_node())
  return root0
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
  local function _4_(n)
    return (ldelim == vts.get_node_text(n, 0))
  end
  left = iter.find(_4_, nodes)
  local right
  local function _5_(n)
    return (rdelim == vts.get_node_text(n, 0))
  end
  right = iter.find(_5_, nodes)
  if (left and right) then
    return tree.rangeBetween(left, right)
  else
    return nil
  end
end
local function findDelimitedRange(ldelim, rdelim, node)
  local function _7_(n)
    return delimitedRange(ldelim, rdelim, n)
  end
  return iter.find(_7_, tree.namedParents(node))
end
local function forwardIntoElement()
  local _let_8_ = vim.fn.getpos(".")
  local _ = _let_8_[1]
  local line = _let_8_[2]
  local col = _let_8_[3]
  local _0 = _let_8_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), (line - 1), (col - 1)))
end
local function forwardOverElement()
  local _let_9_ = vim.fn.getpos(".")
  local _ = _let_9_[1]
  local line = _let_9_[2]
  local col = _let_9_[3]
  local _0 = _let_9_[4]
  local node = vts.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, (line - 1), (col - 1)))
end
local function moveDelimiter(symbol, getDelim, getSubject, getSubjectRange)
  local nodes
  local function _10_(n)
    local x = getDelim(n)
    return (x and (symbol == vts.get_node_text(x, 0)))
  end
  nodes = iter.filter(_10_, tree.namedParents(vts.get_node()))
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
  local function _12_(n)
    return tree.child(n, -1)
  end
  local function _13_(n)
    return n:next_named_sibling()
  end
  local function _14_(d, s)
    local _, _0, c, d0 = vts.get_node_range(d)
    local _1, _2, g, h = vts.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _12_, _13_, _14_)
end
local function slurpBackward(symbol)
  local function _15_(n)
    return tree.child(n, 0)
  end
  local function _16_(n)
    return n:prev_named_sibling()
  end
  local function _17_(d, s)
    local a, b, _, _0 = vts.get_node_range(d)
    local e, f, _1, _2 = vts.get_node_range(s)
    return {e, f, a, b}
  end
  return moveDelimiter(symbol, _15_, _16_, _17_)
end
local function barfForward(symbol)
  local function _18_(n)
    return tree.child(n, 0)
  end
  local function _19_(n)
    return tree.namedChild(n, 0)
  end
  local function _20_(_d, s)
    local sibling = s:next_sibling()
    local a, b, _, _0 = vts.get_node_range(s)
    local e, f, _1, _2 = vts.get_node_range(sibling)
    return {a, b, e, f}
  end
  return moveDelimiter(symbol, _18_, _19_, _20_)
end
local function barfBackward(symbol)
  local function _21_(n)
    return tree.child(n, -1)
  end
  local function _22_(n)
    return tree.namedChild(n, -1)
  end
  local function _23_(d, s)
    local sibling = s:prev_sibling()
    local _, _0, c, d0 = vts.get_node_range(sibling)
    local _1, _2, g, h = vts.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _21_, _22_, _23_)
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
  local _let_25_ = innerRange(p)
  local a = _let_25_[1]
  local b = _let_25_[2]
  local c = _let_25_[3]
  local d = _let_25_[4]
  local lines = vim.api.nvim_buf_get_text(0, a, b, c, d, {})
  local e, f, g, h = vts.get_node_range(p)
  return vim.api.nvim_buf_set_text(0, e, f, g, h, lines)
end
local function _26_()
  return select(vts.get_node())
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-element)", _26_)
local function _27_()
  return select(innerRange(vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-element)", _27_)
local function _28_()
  return select(surroundingNode(vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-element)", _28_)
local function _29_()
  return select(findDelimitedRange("(", ")", vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-(element))", _29_)
local function _30_()
  return select(findDelimitedRange("[", "]", vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-[element])", _30_)
local function _31_()
  return select(findDelimitedRange("{", "}", vts.get_node()))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-{element})", _31_)
local function _32_()
  return select(innerRange(findDelimitedRange("(", ")", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-(element))", _32_)
local function _33_()
  return select(innerRange(findDelimitedRange("[", "]", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-[element])", _33_)
local function _34_()
  return select(innerRange(findDelimitedRange("{", "}", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-{element})", _34_)
local function _35_()
  return select(surroundingNode(findDelimitedRange("(", ")", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-(element))", _35_)
local function _36_()
  return select(surroundingNode(findDelimitedRange("[", "]", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-[element])", _36_)
local function _37_()
  return select(surroundingNode(findDelimitedRange("{", "}", vts.get_node())))
end
vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-{element})", _37_)
vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-forward-into-element)", forwardIntoElement, {})
vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-forward-over-element)", forwardOverElement, {})
local function _38_()
  return slurpForward(")")
end
vim.keymap.set({"n"}, "<Plug>(slurp-slurp-close-paren-forward)", _38_)
local function _39_()
  return slurpBackward("(")
end
vim.keymap.set({"n"}, "<Plug>(slurp-slurp-open-paren-backward)", _39_)
local function _40_()
  return barfForward("(")
end
vim.keymap.set({"n"}, "<Plug>(slurp-barf-open-paren-forward)", _40_)
local function _41_()
  return barfBackward(")")
end
vim.keymap.set({"n"}, "<Plug>(slurp-barf-close-paren-backward)", _41_)
vim.keymap.set({"n"}, "<Plug>(slurp-replace-parent)", replaceParent)
local function _42_()
  return unwrap("(", ")")
end
vim.keymap.set({"n"}, "<Plug>(slurp-delete-surrounding-())", _42_)
return {slurpForward = slurpForward, slurpBackward = slurpBackward, barfForward = barfForward, barfBackward = barfBackward, replaceParent = replaceParent, unwrap = unwrap, forwardIntoElement = forwardIntoElement, forwardOverElement = forwardOverElement, select = slurpSelect}

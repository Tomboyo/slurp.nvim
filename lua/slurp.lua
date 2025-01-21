local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("tree")
local iter = require("iter")
local function select(nodeOrRange)
  if nodeOrRange then
    return ts.update_selection(0, nodeOrRange)
  else
    return nil
  end
end
local function innerRange(n)
  if n then
    local s = tree.namedChild(n, 0)
    local e = tree.namedChild(n, -1)
    if s then
      return tree.rangeBetween(s, e)
    else
      return n
    end
  else
    return nil
  end
end
local function namedParents(node)
  local function _4_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return node
    end
  end
  return iter.iterator(_4_)
end
local function surroundingNode(n)
  local p = (n and tree.nextNamedParent(n))
  return (p or n)
end
local function delimitedRange(ldelim, rdelim, node)
  local nodes = node:iter_children()
  local left
  local function _6_(n)
    return (ldelim == vts.get_node_text(n, 0))
  end
  left = iter.find(_6_, nodes)
  local right
  local function _7_(n)
    return (rdelim == vts.get_node_text(n, 0))
  end
  right = iter.find(_7_, nodes)
  if (left and right) then
    return tree.rangeBetween(left, right)
  else
    return nil
  end
end
local function findDelimitedRange(ldelim, rdelim, node)
  local function _9_(n)
    return delimitedRange(ldelim, rdelim, n)
  end
  return iter.find(_9_, namedParents(node))
end
local function forwardIntoElement()
  local _let_10_ = vim.fn.getpos(".")
  local _ = _let_10_[1]
  local line = _let_10_[2]
  local col = _let_10_[3]
  local _0 = _let_10_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), line, col))
end
local function forwardOverElement()
  local _let_11_ = vim.fn.getpos(".")
  local _ = _let_11_[1]
  local line = _let_11_[2]
  local col = _let_11_[3]
  local _0 = _let_11_[4]
  local node = vts.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, line, col))
end
local function moveDelimiter(symbol, getDelim, getSubject, getSubjectRange)
  local nodes
  local function _12_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vts.get_node()
    end
  end
  nodes = iter.iterator(_12_)
  local nodes0
  local function _14_(n)
    local x = getDelim(n)
    return (x and (symbol == vts.get_node_text(x, 0)))
  end
  nodes0 = iter.filter(_14_, nodes)
  local nodes1 = iter.filter(getSubject, nodes0)
  local node = nodes1()
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
  local function _16_(n)
    return tree.child(n, -1)
  end
  local function _17_(n)
    return n:next_named_sibling()
  end
  local function _18_(d, s)
    local _, _0, c, d0 = vts.get_node_range(d)
    local _1, _2, g, h = vts.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _16_, _17_, _18_)
end
local function slurpBackward(symbol)
  local function _19_(n)
    return tree.child(n, 0)
  end
  local function _20_(n)
    return n:prev_named_sibling()
  end
  local function _21_(d, s)
    local a, b, _, _0 = vts.get_node_range(d)
    local e, f, _1, _2 = vts.get_node_range(s)
    return {e, f, a, b}
  end
  return moveDelimiter(symbol, _19_, _20_, _21_)
end
local function barfForward(symbol)
  local function _22_(n)
    return tree.child(n, 0)
  end
  local function _23_(n)
    return tree.namedChild(n, 0)
  end
  local function _24_(_d, s)
    local sibling = s:next_sibling()
    local a, b, _, _0 = vts.get_node_range(s)
    local e, f, _1, _2 = vts.get_node_range(sibling)
    return {a, b, e, f}
  end
  return moveDelimiter(symbol, _22_, _23_, _24_)
end
local function barfBackward(symbol)
  local function _25_(n)
    return tree.child(n, -1)
  end
  local function _26_(n)
    return tree.namedChild(n, -1)
  end
  local function _27_(d, s)
    local sibling = s:prev_sibling()
    local _, _0, c, d0 = vts.get_node_range(sibling)
    local _1, _2, g, h = vts.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _25_, _26_, _27_)
end
local function setup(opts)
  local function _28_()
    return select(vts.get_node())
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-element)", _28_)
  local function _29_()
    return select(innerRange(vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-element)", _29_)
  local function _30_()
    return select(surroundingNode(vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-element)", _30_)
  local function _31_()
    return select(findDelimitedRange("(", ")", vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-(element))", _31_)
  local function _32_()
    return select(findDelimitedRange("[", "]", vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-[element])", _32_)
  local function _33_()
    return select(findDelimitedRange("{", "}", vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-{element})", _33_)
  local function _34_()
    return select(innerRange(findDelimitedRange("(", ")", vts.get_node())))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-(element))", _34_)
  local function _35_()
    return select(innerRange(findDelimitedRange("[", "]", vts.get_node())))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-[element])", _35_)
  local function _36_()
    return select(innerRange(findDelimitedRange("{", "}", vts.get_node())))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-{element})", _36_)
  local function _37_()
    return select(surroundingNode(findDelimitedRange("(", ")", vts.get_node())))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-(element))", _37_)
  local function _38_()
    return select(surroundingNode(findDelimitedRange("[", "]", vts.get_node())))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-[element])", _38_)
  local function _39_()
    return select(surroundingNode(findDelimitedRange("{", "}", vts.get_node())))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-{element})", _39_)
  local function _40_()
    return forwardIntoElement()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-forward-into-element)", _40_, {})
  local function _41_()
    return forwardOverElement()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-forward-over-element)", _41_, {})
  local function _42_()
    return slurpForward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-close-paren-forward)", _42_)
  local function _43_()
    return slurpBackward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-open-paren-backward)", _43_)
  local function _44_()
    return barfForward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-open-paren-forward)", _44_)
  local function _45_()
    return barfBackward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-close-paren-backward)", _45_)
  vim.keymap.set({"v", "o"}, "<LocalLeader>ee", "<Plug>(slurp-select-element)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ie", "<Plug>(slurp-select-inside-element)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ae", "<Plug>(slurp-select-outside-element)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>e)", "<Plug>(slurp-select-(element))")
  vim.keymap.set({"v", "o"}, "<LocalLeader>e]", "<Plug>(slurp-select-[element])")
  vim.keymap.set({"v", "o"}, "<LocalLeader>e}", "<Plug>(slurp-select-{element})")
  vim.keymap.set({"v", "o"}, "<LocalLeader>i)", "<Plug>(slurp-select-inside-(element))")
  vim.keymap.set({"v", "o"}, "<LocalLeader>i]", "<Plug>(slurp-select-inside-[element])")
  vim.keymap.set({"v", "o"}, "<LocalLeader>i}", "<Plug>(slurp-select-inside-{element})")
  vim.keymap.set({"v", "o"}, "<LocalLeader>a)", "<Plug>(slurp-select-outside-(element))")
  vim.keymap.set({"v", "o"}, "<LocalLeader>a]", "<Plug>(slurp-select-outside-[element])")
  vim.keymap.set({"v", "o"}, "<LocalLeader>a}", "<Plug>(slurp-select-outside-{element})")
  vim.keymap.set({"v", "o"}, "<LocalLeader>il", "<Plug>(slurp-inner-list-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>al", "<Plug>(slurp-outer-list-to)")
  vim.keymap.set({"n", "v", "o"}, "w", "<Plug>(slurp-forward-into-element)")
  vim.keymap.set({"n", "v", "o"}, "W", "<Plug>(slurp-forward-over-element)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)l", "<Plug>(slurp-slurp-close-paren-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>(h", "<Plug>(slurp-slurp-open-paren-backward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>(l", "<Plug>(slurp-barf-open-paren-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)h", "<Plug>(slurp-barf-close-paren-backward)")
  local function _46_()
    vim.cmd("!make build")
    package.loaded.tree = nil
    package.loaded.iter = nil
    package.loaded.slurp = nil
    return vim.cmd("ConjureEvalBuf")
  end
  return vim.keymap.set({"n"}, "<LocalLeader>bld", _46_, {})
end
return {setup = setup}

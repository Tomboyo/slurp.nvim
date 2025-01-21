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
  local s = tree.namedChild(n, 0)
  local e = tree.namedChild(n, -1)
  if s then
    return tree.rangeBetween(s, e)
  else
    return n
  end
end
local function namedParents(node)
  local function _3_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  return iter.iterator(_3_)
end
local function surroundingNode(n)
  local p = (n and tree.nextNamedParent(n))
  return (p or n)
end
local function delimitedRange(ldelim, rdelim, node)
  local nodes = node:iter_children()
  local left
  local function _5_(n)
    return (ldelim == vts.get_node_text(n, 0))
  end
  left = iter.find(_5_, nodes)
  local right
  local function _6_(n)
    return (rdelim == vts.get_node_text(n, 0))
  end
  right = iter.find(_6_, nodes)
  if (left and right) then
    return tree.rangeBetween(left, right)
  else
    return nil
  end
end
local function findDelimitedRange(ldelim, rdelim, node)
  local function _8_(n)
    return delimitedRange(ldelim, rdelim, n)
  end
  return iter.find(_8_, namedParents(node))
end
local function innerElementForward()
  local _let_9_ = vim.fn.getpos(".")
  local _ = _let_9_[1]
  local line = _let_9_[2]
  local col = _let_9_[3]
  local _0 = _let_9_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), line, col))
end
local function outerElementForward()
  local _let_10_ = vim.fn.getpos(".")
  local _ = _let_10_[1]
  local line = _let_10_[2]
  local col = _let_10_[3]
  local _0 = _let_10_[4]
  local node = vim.treesitter.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, line, col))
end
local function moveDelimiter(symbol, getDelim, getSubject, getSubjectRange)
  local nodes
  local function _11_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_11_)
  local nodes0
  local function _13_(n)
    local x = getDelim(n)
    return (x and (symbol == vim.treesitter.get_node_text(x, 0)))
  end
  nodes0 = iter.filter(_13_, nodes)
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
  local function _15_(n)
    return tree.child(n, -1)
  end
  local function _16_(n)
    return n:next_named_sibling()
  end
  local function _17_(d, s)
    local _, _0, c, d0 = vim.treesitter.get_node_range(d)
    local _1, _2, g, h = vim.treesitter.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _15_, _16_, _17_)
end
local function slurpBackward(symbol)
  local function _18_(n)
    return tree.child(n, 0)
  end
  local function _19_(n)
    return n:prev_named_sibling()
  end
  local function _20_(d, s)
    local a, b, _, _0 = vim.treesitter.get_node_range(d)
    local e, f, _1, _2 = vim.treesitter.get_node_range(s)
    return {e, f, a, b}
  end
  return moveDelimiter(symbol, _18_, _19_, _20_)
end
local function barfForward(symbol)
  local function _21_(n)
    return tree.child(n, 0)
  end
  local function _22_(n)
    return tree.namedChild(n, 0)
  end
  local function _23_(d, s)
    local sibling = s:next_sibling()
    local a, b, _, _0 = vim.treesitter.get_node_range(s)
    local e, f, _1, _2 = vim.treesitter.get_node_range(sibling)
    return {a, b, e, f}
  end
  return moveDelimiter(symbol, _21_, _22_, _23_)
end
local function barfBackward(symbol)
  local function _24_(n)
    return tree.child(n, -1)
  end
  local function _25_(n)
    return tree.namedChild(n, -1)
  end
  local function _26_(d, s)
    local sibling = s:prev_sibling()
    local _, _0, c, d0 = vim.treesitter.get_node_range(sibling)
    local _1, _2, g, h = vim.treesitter.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _24_, _25_, _26_)
end
local function setup(opts)
  local function _27_()
    return select(vts.get_node())
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-element)", _27_)
  local function _28_()
    return select(innerRange(vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-element)", _28_)
  local function _29_()
    return select(surroundingNode(vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-element)", _29_)
  local function _30_()
    return select(findDelimitedRange("(", ")", vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-(element))", _30_)
  local function _31_()
    return select(findDelimitedRange("[", "]", vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-[element])", _31_)
  local function _32_()
    return select(findDelimitedRange("{", "}", vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-{element})", _32_)
  local function _33_()
    return innerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-inner-element-forward)", _33_, {})
  local function _34_()
    return outerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-outer-element-forward)", _34_, {})
  local function _35_()
    return slurpForward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-close-paren-forward)", _35_)
  local function _36_()
    return slurpBackward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-open-paren-backward)", _36_)
  local function _37_()
    return barfForward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-open-paren-forward)", _37_)
  local function _38_()
    return barfBackward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-close-paren-backward)", _38_)
  vim.keymap.set({"v", "o"}, "<LocalLeader>ee", "<Plug>(slurp-select-element)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ie", "<Plug>(slurp-select-inside-element)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>ae", "<Plug>(slurp-select-outside-element)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>e)", "<Plug>(slurp-select-(element))")
  vim.keymap.set({"v", "o"}, "<LocalLeader>e]", "<Plug>(slurp-select-[element])")
  vim.keymap.set({"v", "o"}, "<LocalLeader>e}", "<Plug>(slurp-select-{element})")
  vim.keymap.set({"v", "o"}, "<LocalLeader>il", "<Plug>(slurp-inner-list-to)")
  vim.keymap.set({"v", "o"}, "<LocalLeader>al", "<Plug>(slurp-outer-list-to)")
  vim.keymap.set({"n", "v", "o"}, "w", "<Plug>(slurp-inner-element-forward)")
  vim.keymap.set({"n", "v", "o"}, "W", "<Plug>(slurp-outer-element-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)l", "<Plug>(slurp-slurp-close-paren-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>(h", "<Plug>(slurp-slurp-open-paren-backward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>(l", "<Plug>(slurp-barf-open-paren-forward)")
  vim.keymap.set({"n", "v", "o"}, "<LocalLeader>)h", "<Plug>(slurp-barf-close-paren-backward)")
  local function _39_()
    vim.cmd("!make build")
    package.loaded.tree = nil
    package.loaded.iter = nil
    package.loaded.slurp = nil
    vim.cmd("ConjureEvalBuf")
    return setup()
  end
  return vim.keymap.set({"n"}, "<LocalLeader>bld", _39_, {})
end
return {setup = setup}

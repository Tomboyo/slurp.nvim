local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("tree")
local iter = require("iter")
local function select(nodeOrRange)
  return ts.update_selection(0, nodeOrRange)
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
local function surroundingNode(n)
  local p = (n and tree.nextNamedParent(n))
  return (p or n)
end
local function selectDelimitedElement(open, close, n)
  local n0 = (n or vim.treesitter.get_node())
  local start = tree.child(n0, 0)
  local start0 = (start and vim.treesitter.get_node_text(start, 0))
  local _end = tree.child(n0, -1)
  local _end0 = (_end and vim.treesitter.get_node_text(_end, 0))
  if ((open == start0) and (close == _end0)) then
    return ts.update_selection(0, n0)
  else
    local p = tree.nextNamedParent(n0)
    if p then
      return selectDelimitedElement(open, close, p)
    else
      return nil
    end
  end
end
local function innerElementForward()
  local _let_4_ = vim.fn.getpos(".")
  local _ = _let_4_[1]
  local line = _let_4_[2]
  local col = _let_4_[3]
  local _0 = _let_4_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), line, col))
end
local function outerElementForward()
  local _let_5_ = vim.fn.getpos(".")
  local _ = _let_5_[1]
  local line = _let_5_[2]
  local col = _let_5_[3]
  local _0 = _let_5_[4]
  local node = vim.treesitter.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, line, col))
end
local function moveDelimiter(symbol, getDelim, getSubject, getSubjectRange)
  local nodes
  local function _6_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_6_)
  local nodes0
  local function _8_(n)
    local x = getDelim(n)
    return (x and (symbol == vim.treesitter.get_node_text(x, 0)))
  end
  nodes0 = iter.filter(_8_, nodes)
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
  local function _10_(n)
    return tree.child(n, -1)
  end
  local function _11_(n)
    return n:next_named_sibling()
  end
  local function _12_(d, s)
    local _, _0, c, d0 = vim.treesitter.get_node_range(d)
    local _1, _2, g, h = vim.treesitter.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _10_, _11_, _12_)
end
local function slurpBackward(symbol)
  local function _13_(n)
    return tree.child(n, 0)
  end
  local function _14_(n)
    return n:prev_named_sibling()
  end
  local function _15_(d, s)
    local a, b, _, _0 = vim.treesitter.get_node_range(d)
    local e, f, _1, _2 = vim.treesitter.get_node_range(s)
    return {e, f, a, b}
  end
  return moveDelimiter(symbol, _13_, _14_, _15_)
end
local function barfForward(symbol)
  local function _16_(n)
    return tree.child(n, 0)
  end
  local function _17_(n)
    return tree.namedChild(n, 0)
  end
  local function _18_(d, s)
    local sibling = s:next_sibling()
    local a, b, _, _0 = vim.treesitter.get_node_range(s)
    local e, f, _1, _2 = vim.treesitter.get_node_range(sibling)
    return {a, b, e, f}
  end
  return moveDelimiter(symbol, _16_, _17_, _18_)
end
local function barfBackward(symbol)
  local function _19_(n)
    return tree.child(n, -1)
  end
  local function _20_(n)
    return tree.namedChild(n, -1)
  end
  local function _21_(d, s)
    local sibling = s:prev_sibling()
    local _, _0, c, d0 = vim.treesitter.get_node_range(sibling)
    local _1, _2, g, h = vim.treesitter.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _19_, _20_, _21_)
end
local function setup(opts)
  local function _22_()
    return select(vts.get_node())
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-element)", _22_)
  local function _23_()
    return select(innerRange(vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-element)", _23_)
  local function _24_()
    return select(surroundingNode(vts.get_node()))
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-element)", _24_)
  local function _25_()
    return selectDelimitedElement("(", ")")
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-(element))", _25_)
  local function _26_()
    return selectDelimitedElement("[", "]")
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-[element])", _26_)
  local function _27_()
    return selectDelimitedElement("{", "}")
  end
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-{element})", _27_)
  local function _28_()
    return innerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-inner-element-forward)", _28_, {})
  local function _29_()
    return outerElementForward()
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-outer-element-forward)", _29_, {})
  local function _30_()
    return slurpForward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-close-paren-forward)", _30_)
  local function _31_()
    return slurpBackward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-slurp-open-paren-backward)", _31_)
  local function _32_()
    return barfForward("(")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-open-paren-forward)", _32_)
  local function _33_()
    return barfBackward(")")
  end
  vim.keymap.set({"n", "v", "o"}, "<Plug>(slurp-barf-close-paren-backward)", _33_)
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
  local function _34_()
    vim.cmd("!make build")
    package.loaded.tree = nil
    package.loaded.iter = nil
    package.loaded.slurp = nil
    vim.cmd("ConjureEvalBuf")
    return setup()
  end
  return vim.keymap.set({"n"}, "<LocalLeader>bld", _34_, {})
end
return {setup = setup}

local ts = require("nvim-treesitter.ts_utils")
local tree = require("tree")
local iter = require("iter")
local function selectElementAtCursor()
  return ts.update_selection(0, vim.treesitter.get_node())
end
local function selectInsideElementAtCursor()
  local n = vim.treesitter.get_node()
  local s = tree.namedChild(n, 0)
  local e = tree.namedChild(n, -1)
  local function _1_()
    if s then
      return tree.rangeBetween(s, e)
    else
      return n
    end
  end
  return ts.update_selection(0, _1_())
end
local function selectSurroundingElementAtCursor()
  local n = vim.treesitter.get_node()
  local p = (n and tree.nextNamedParent(n))
  return ts.update_selection(0, (p or n))
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
local function tsNodeRange(node, offset)
  local offset0 = (offset or {1, 0})
  local r = offset0[1]
  local c = offset0[2]
  local _let_4_ = ts.node_to_lsp_range(node)
  local _let_5_ = _let_4_["start"]
  local l1 = _let_5_["line"]
  local c1 = _let_5_["character"]
  local _let_6_ = _let_4_["end"]
  local l2 = _let_6_["line"]
  local c2 = _let_6_["character"]
  return {(r + l1), (c + c1), (r + l2), (c + c2)}
end
local function innerElementForward()
  local _let_7_ = vim.fn.getpos(".")
  local _ = _let_7_[1]
  local line = _let_7_[2]
  local col = _let_7_[3]
  local _0 = _let_7_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), line, col))
end
local function outerElementForward()
  local _let_8_ = vim.fn.getpos(".")
  local _ = _let_8_[1]
  local line = _let_8_[2]
  local col = _let_8_[3]
  local _0 = _let_8_[4]
  local node = vim.treesitter.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, line, col))
end
local function moveDelimiter(symbol, getDelim, getSubject, getSubjectRange)
  local nodes
  local function _9_(n)
    if n then
      return tree.nextNamedParent(n)
    else
      return vim.treesitter.get_node()
    end
  end
  nodes = iter.iterator(_9_)
  local nodes0
  local function _11_(n)
    local x = getDelim(n)
    return (x and (symbol == vim.treesitter.get_node_text(x, 0)))
  end
  nodes0 = iter.filter(_11_, nodes)
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
  local function _13_(n)
    return tree.child(n, -1)
  end
  local function _14_(n)
    return n:next_named_sibling()
  end
  local function _15_(d, s)
    local _, _0, c, d0 = vim.treesitter.get_node_range(d)
    local _1, _2, g, h = vim.treesitter.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _13_, _14_, _15_)
end
local function slurpBackward(symbol)
  local function _16_(n)
    return tree.child(n, 0)
  end
  local function _17_(n)
    return n:prev_named_sibling()
  end
  local function _18_(d, s)
    local a, b, _, _0 = vim.treesitter.get_node_range(d)
    local e, f, _1, _2 = vim.treesitter.get_node_range(s)
    return {e, f, a, b}
  end
  return moveDelimiter(symbol, _16_, _17_, _18_)
end
local function barfForward(symbol)
  local function _19_(n)
    return tree.child(n, 0)
  end
  local function _20_(n)
    return tree.namedChild(n, 0)
  end
  local function _21_(d, s)
    local sibling = s:next_sibling()
    local a, b, _, _0 = vim.treesitter.get_node_range(s)
    local e, f, _1, _2 = vim.treesitter.get_node_range(sibling)
    return {a, b, e, f}
  end
  return moveDelimiter(symbol, _19_, _20_, _21_)
end
local function barfBackward(symbol)
  local function _22_(n)
    return tree.child(n, -1)
  end
  local function _23_(n)
    return tree.namedChild(n, -1)
  end
  local function _24_(d, s)
    local sibling = s:prev_sibling()
    local _, _0, c, d0 = vim.treesitter.get_node_range(sibling)
    local _1, _2, g, h = vim.treesitter.get_node_range(s)
    return {c, d0, g, h}
  end
  return moveDelimiter(symbol, _22_, _23_, _24_)
end
local function setup(opts)
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-element)", selectElementAtCursor)
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-inside-element)", selectInsideElementAtCursor)
  vim.keymap.set({"v", "o"}, "<Plug>(slurp-select-outside-element)", selectSurroundingElementAtCursor)
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

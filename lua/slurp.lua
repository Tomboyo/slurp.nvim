local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("slurp/tree")
local iter = require("slurp/iter")
local function typeMatch(node, opts)
  local types = (opts["not"] or opts)
  local f
  if opts["not"] then
    local function _1_(_241)
      return not (_241 == node:type())
    end
    f = _1_
  else
    local function _2_(_241)
      return (_241 == node:type())
    end
    f = _2_
  end
  return iter.find(f, iter.iterate(types))
end
local function slurpSelect(nodeOrRange)
  if (nil == nodeOrRange) then
    return nil
  else
    return ts.update_selection(0, nodeOrRange)
  end
end
local function find(types, root)
  if (nil == types) then
    return vts.get_node()
  else
    local root0 = (root or vts.get_node())
    local function _5_(_241)
      return typeMatch(_241, types)
    end
    return iter.find(_5_, iter.iterate(tree.nextParent, root0))
  end
end
local function forwardInto()
  local _let_7_ = vim.fn.getpos(".")
  local _ = _let_7_[1]
  local row = _let_7_[2]
  local col = _let_7_[3]
  local _0 = _let_7_[4]
  local root = vts.get_node()
  local function _8_(_241)
    return tree.isLexicallyAfter(_241, row, col)
  end
  return ts.goto_node(iter.find(_8_, iter.iterate(tree.nextDescending, root)))
end
local function forwardOver(lang)
  local _let_9_ = vim.fn.getpos(".")
  local _ = _let_9_[1]
  local row = _let_9_[2]
  local col = _let_9_[3]
  local _0 = _let_9_[4]
  local root = vts.get_node()
  local target
  local function _10_(_241)
    return typeMatch(_241, lang.forwardOver)
  end
  local function _11_(_241)
    return tree.isLexicallyAfter(_241, row, col)
  end
  target = iter.find(_10_, iter.filter(_11_, iter.iterate(tree.nextAscending, root)))
  return ts.goto_node(target)
end
local function backwardOver(lang)
  local _let_12_ = vim.fn.getpos(".")
  local _ = _let_12_[1]
  local row = _let_12_[2]
  local col = _let_12_[3]
  local _0 = _let_12_[4]
  local root = vts.get_node()
  local function _13_(_241)
    return typeMatch(_241, lang.forwardOver)
  end
  local function _14_(_241)
    return tree.isLexicallyBefore(_241, row, col)
  end
  return ts.goto_node(iter.find(_13_, iter.filter(_14_, iter.iterate(tree.prevAscending, root))))
end
return {forwardInto = forwardInto, forwardOver = forwardOver, backwardOver = backwardOver, select = slurpSelect, find = find}

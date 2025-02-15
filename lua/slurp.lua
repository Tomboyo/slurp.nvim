local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("slurp/tree")
local iter = require("slurp/iter")
local function typeMatch(node, opts)
  local types = (opts["not"] or opts)
  local f
  if opts["not"] then
    local function _1_(t)
      return not (t == node:type())
    end
    f = _1_
  else
    local function _2_(t)
      return (t == node:type())
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
    local function _5_(n)
      local function _6_(type)
        return (type == n:type())
      end
      return iter.find(_6_, iter.stateful(ipairs(types)))
    end
    return iter.find(_5_, tree.namedParents(root0))
  end
end
local function forwardInto()
  local _let_8_ = vim.fn.getpos(".")
  local _ = _let_8_[1]
  local row = _let_8_[2]
  local col = _let_8_[3]
  local _0 = _let_8_[4]
  local node = vts.get_node()
  local function _9_(n)
    return tree.isLexicallyAfter(n, row, col)
  end
  return ts.goto_node(iter.find(_9_, tree.nodesBelowLevel(node)))
end
local function forwardOver(lang)
  local _let_10_ = vim.fn.getpos(".")
  local _ = _let_10_[1]
  local row = _let_10_[2]
  local col = _let_10_[3]
  local _0 = _let_10_[4]
  local node = vts.get_node()
  local target
  local function _11_(n)
    return typeMatch(n, lang.forwardOver)
  end
  local function _12_(n)
    return tree.isLexicallyAfter(n, row, col)
  end
  target = iter.find(_11_, iter.filter(_12_, tree.nodesOnLevel(node)))
  return ts.goto_node(target)
end
return {forwardInto = forwardInto, forwardOver = forwardOver, select = slurpSelect, find = find}

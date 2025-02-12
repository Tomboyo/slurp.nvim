local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("slurp/tree")
local iter = require("slurp/iter")
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
    local function _2_(n)
      local function _3_(type)
        return (type == n:type())
      end
      return iter.find(_3_, iter.stateful(ipairs(types)))
    end
    return iter.find(_2_, tree.namedParents(root0))
  end
end
local function forwardIntoElement()
  local _let_5_ = vim.fn.getpos(".")
  local _ = _let_5_[1]
  local line = _let_5_[2]
  local col = _let_5_[3]
  local _0 = _let_5_[4]
  return ts.goto_node(tree.nextLexicalInnerNode(ts.get_node_at_cursor(), (line - 1), (col - 1)))
end
local function forwardOverElement()
  local _let_6_ = vim.fn.getpos(".")
  local _ = _let_6_[1]
  local line = _let_6_[2]
  local col = _let_6_[3]
  local _0 = _let_6_[4]
  local node = vts.get_node()
  return ts.goto_node(tree.nextLexicalOuterNode(node, (line - 1), (col - 1)))
end
return {forwardIntoElement = forwardIntoElement, forwardOverElement = forwardOverElement, select = slurpSelect, find = find}

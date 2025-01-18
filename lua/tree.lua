local ts = require("nvim-treesitter.ts_utils")
local m = {}
local function nextNamedParent(node)
  local p = node:parent()
  if p:named() then
    return p
  else
    return nextNamedParent(p)
  end
end
local function nextNamedIbling(node)
  if node:next_named_sibling() then
    return node:next_named_sibling()
  else
    return nextNamedIbling(nextNamedParent(node))
  end
end
local function nextNamedInnerNode(node)
  if (node:named_child_count() > 0) then
    return node:named_child(0)
  else
    return nextNamedIbling(node)
  end
end
m.range = function(node, offset)
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
m.nextLexicalInnerNode = function(node, line, char)
  local _let_7_ = m.range(node, {1, 1})
  local l = _let_7_[1]
  local c = _let_7_[2]
  local _ = _let_7_[3]
  local _0 = _let_7_[4]
  if (((l == line) and (c <= char)) or (l < line)) then
    return m.nextLexicalInnerNode(nextNamedInnerNode(node), line, char)
  else
    return node
  end
end
m.nextLexicalOuterNode = function(node, line, char)
  local _let_9_ = m.range(node, {1, 1})
  local l = _let_9_[1]
  local c = _let_9_[2]
  local _ = _let_9_[3]
  local _0 = _let_9_[4]
  if (((l == line) and (c <= char)) or (l < line)) then
    return m.nextLexicalOuterNode(nextNamedIbling(node), line, char)
  else
    return node
  end
end
m.firstSurroundingNode = function(ldelim, rdelim, node)
  local node0 = (node or vim.treesitter.get_node())
  local len = node0:child_count()
  local function _11_()
    if (len >= 2) then
      return {node0:child(0), node0:child((len - 1))}
    else
      return {nil, nil}
    end
  end
  local _let_12_ = _11_()
  local open = _let_12_[1]
  local close = _let_12_[2]
  if (open and close and (ldelim == vim.treesitter.get_node_text(open, 0)) and (rdelim == vim.treesitter.get_node_text(close, 0))) then
    return {node0, open, close}
  else
    return m.firstSurroundingNode(ldelim, rdelim, nextNamedParent(node0))
  end
end
vim.print("required tree")
return m

local ts = require("nvim-treesitter.ts_utils")
local m = {}
local function nextNamedParent(node)
  local p = node:parent()
  if p then
    if p:named() then
      return p
    else
      return nextNamedParent(p)
    end
  else
    return nil
  end
end
m.nextNamedParent = nextNamedParent
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
  local _let_5_ = ts.node_to_lsp_range(node)
  local _let_6_ = _let_5_["start"]
  local l1 = _let_6_["line"]
  local c1 = _let_6_["character"]
  local _let_7_ = _let_5_["end"]
  local l2 = _let_7_["line"]
  local c2 = _let_7_["character"]
  return {(r + l1), (c + c1), (r + l2), (c + c2)}
end
m.nextLexicalInnerNode = function(node, line, char)
  local _let_8_ = m.range(node, {1, 1})
  local l = _let_8_[1]
  local c = _let_8_[2]
  local _ = _let_8_[3]
  local _0 = _let_8_[4]
  if (((l == line) and (c <= char)) or (l < line)) then
    return m.nextLexicalInnerNode(nextNamedInnerNode(node), line, char)
  else
    return node
  end
end
m.nextLexicalOuterNode = function(node, line, char)
  local _let_10_ = m.range(node, {1, 1})
  local l = _let_10_[1]
  local c = _let_10_[2]
  local _ = _let_10_[3]
  local _0 = _let_10_[4]
  if (((l == line) and (c <= char)) or (l < line)) then
    return m.nextLexicalOuterNode(nextNamedIbling(node), line, char)
  else
    return node
  end
end
m.delimiters = function(node)
  local len = node:child_count()
  if (len >= 1) then
    return {node:child(0), node:child((len - 1))}
  else
    return {nil, nil}
  end
end
m.firstSurroundingNode = function(ldelim, rdelim, node)
  local node0 = (node or vim.treesitter.get_node())
  local _let_13_ = m.delimiters(node0)
  local open = _let_13_[1]
  local close = _let_13_[2]
  if (open and close and (ldelim == vim.treesitter.get_node_text(open, 0)) and (rdelim == vim.treesitter.get_node_text(close, 0))) then
    return {node0, open, close}
  else
    return m.firstSurroundingNode(ldelim, rdelim, nextNamedParent(node0))
  end
end
m.child = function(node, offset)
  local index
  if (offset < 0) then
    index = (node:child_count() + offset)
  else
    index = offset
  end
  return node:child(index)
end
m.namedChild = function(node, offset)
  local index
  if (offset < 0) then
    index = (node:named_child_count() + offset)
  else
    index = offset
  end
  return node:named_child(index)
end
return m

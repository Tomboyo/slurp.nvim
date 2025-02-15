local ts = require("nvim-treesitter.ts_utils")
local iter = require("slurp/iter")
local m = {}
m.namedParents = function(root)
  if (nil == root) then
    error("missing root node")
  else
  end
  return iter.iterator(m.nextNamedParent, root)
end
m.nodesOnLevel = function(root)
  if (nil == root) then
    error("missing root node")
  else
  end
  return iter.iterator(m.nextNamedNodeOnLevel, root)
end
m.nodesBelowLevel = function(root)
  if (nil == root) then
    error("missing root node")
  else
  end
  return iter.iterator(m.nextNamedInnerNode, root)
end
m.isLexicallyAfter = function(root, row, col)
  local l, c = vim.treesitter.get_node_range(root)
  local l0 = (1 + l)
  local c0 = (1 + c)
  return ((l0 > row) or ((l0 == row) and (c0 > col)))
end
m.nextNamedParent = function(node)
  local p = node:parent()
  if p then
    if p:named() then
      return p
    else
      return m.nextNamedParent(p)
    end
  else
    return nil
  end
end
m.nextNamedNodeOnLevel = function(node)
  if (nil == node) then
    error("nil node")
  else
  end
  if node:next_named_sibling() then
    return node:next_named_sibling()
  else
    local p = m.nextNamedParent(node)
    if p then
      return m.nextNamedNodeOnLevel(p)
    else
      return nil
    end
  end
end
m.nextNamedInnerNode = function(node)
  if (node:named_child_count() > 0) then
    return node:named_child(0)
  else
    return m.nextNamedNodeOnLevel(node)
  end
end
m.nextLexicalInnerNode = function(node, line, char)
  local l, c, _, _0 = vim.treesitter.get_node_range(node)
  if (((l == line) and (c <= char)) or (l < line)) then
    return m.nextLexicalInnerNode(nextNamedInnerNode(node), line, char)
  else
    return node
  end
end
m.firstSurroundingNode = function(ldelim, rdelim, node)
  local node0 = (node or vim.treesitter.get_node())
  local _let_11_ = m.delimiters(node0)
  local open = _let_11_[1]
  local close = _let_11_[2]
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
m.visualChildren = function(node)
  local function notBlank_3f(s)
    return not ((nil == s) or ("" == s))
  end
  local function _16_(_15_)
    local c = _15_[1]
    local _ = _15_[2]
    return c
  end
  local function _18_(_17_)
    local _ = _17_[1]
    local t = _17_[2]
    return notBlank_3f(t)
  end
  local function _19_(c)
    return {c, vim.treesitter.get_node_text(c, 0)}
  end
  return iter.map(_16_, iter.filter(_18_, iter.map(_19_, node:iter_children())))
end
m.rangeBetween = function(s, e, opt)
  local opt0 = (opt or {})
  local a, b, c, d = vim.treesitter.get_node_range(s)
  local e0, f, g, h = vim.treesitter.get_node_range(e)
  if opt0.exclusive then
    return {c, d, e0, f}
  else
    return {a, b, g, h}
  end
end
return m

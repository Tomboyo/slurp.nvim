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
local function nextNamedIbling(node)
  if node:next_named_sibling() then
    return node:next_named_sibling()
  else
    return nextNamedIbling(m.nextNamedParent(node))
  end
end
local function nextNamedInnerNode(node)
  if (node:named_child_count() > 0) then
    return node:named_child(0)
  else
    return nextNamedIbling(node)
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
m.nextLexicalOuterNode = function(node, line, char)
  local l, c, _, _0 = vim.treesitter.get_node_range(node)
  if (((l == line) and (c <= char)) or (l < line)) then
    return m.nextLexicalOuterNode(nextNamedIbling(node), line, char)
  else
    return node
  end
end
m.firstSurroundingNode = function(ldelim, rdelim, node)
  local node0 = (node or vim.treesitter.get_node())
  local _let_8_ = m.delimiters(node0)
  local open = _let_8_[1]
  local close = _let_8_[2]
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
  local function _13_(_12_)
    local c = _12_[1]
    local _ = _12_[2]
    return c
  end
  local function _15_(_14_)
    local _ = _14_[1]
    local t = _14_[2]
    return notBlank_3f(t)
  end
  local function _16_(c)
    return {c, vim.treesitter.get_node_text(c, 0)}
  end
  return iter.map(_13_, iter.filter(_15_, iter.map(_16_, node:iter_children())))
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

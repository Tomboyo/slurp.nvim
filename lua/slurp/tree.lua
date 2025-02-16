local ts = require("nvim-treesitter.ts_utils")
local iter = require("slurp/iter")
local m = {}
m.isLexicallyAfter = function(root, row, col)
  local l, c = vim.treesitter.get_node_range(root)
  local l0 = (1 + l)
  local c0 = (1 + c)
  return ((l0 > row) or ((l0 == row) and (c0 > col)))
end
m.isLexicallyBefore = function(root, row, col)
  _G.assert((nil ~= col), "Missing argument col on src/main/fnl/slurp/tree.fnl:14")
  _G.assert((nil ~= row), "Missing argument row on src/main/fnl/slurp/tree.fnl:14")
  _G.assert((nil ~= root), "Missing argument root on src/main/fnl/slurp/tree.fnl:14")
  local l, c = vim.treesitter.get_node_range(root)
  local l0 = (1 + l)
  local c0 = (1 + c)
  return ((l0 < row) or ((l0 == row) and (c0 < col)))
end
m.nextParent = function(node)
  local p = node:parent()
  if p then
    if p:named() then
      return p
    else
      return m.nextParent(p)
    end
  else
    return nil
  end
end
m.nextAscending = function(node)
  if (nil == node) then
    error("nil node")
  else
  end
  if node:next_named_sibling() then
    return node:next_named_sibling()
  else
    local p = m.nextParent(node)
    if p then
      return m.nextAscending(p)
    else
      return nil
    end
  end
end
m.prevAscending = function(node)
  _G.assert((nil ~= node), "Missing argument node on src/main/fnl/slurp/tree.fnl:38")
  if node:prev_named_sibling() then
    return node:prev_named_sibling()
  else
    local p = m.nextParent(node)
    if p then
      return m.prevAscending(p)
    else
      return nil
    end
  end
end
m.nextDescending = function(node)
  if (node:named_child_count() > 0) then
    return node:named_child(0)
  else
    return m.nextAscending(node)
  end
end
m.prevDescending = function(node)
  local prev = node:prev_named_sibling()
  if prev then
    local c = prev:named_child_count()
    if (c > 0) then
      return prev:named_child((c - 1))
    else
      return prev
    end
  else
    return m.nextParent(node)
  end
end
return m

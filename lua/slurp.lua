local ts = require("nvim-treesitter.ts_utils")
local vts = vim.treesitter
local tree = require("slurp/tree")
local iter = require("slurp/iter")
local function typeMatch(node, _3ftypeOpts)
  _G.assert((nil ~= node), "Missing argument node on src/main/fnl/slurp.fnl:6")
  local typeOpts = (_3ftypeOpts or {["not"] = {}})
  local types = (typeOpts["not"] or typeOpts)
  local anyMatch
  local function _1_(_241)
    return (_241 == node:type())
  end
  anyMatch = iter.find(_1_, iter.iterate(types))
  if typeOpts["not"] then
    return not anyMatch
  else
    return anyMatch
  end
end
local function lang(ftype)
  local ok, lang0 = nil, nil
  local function _3_()
    return require(("slurp/lang/" .. (ftype or vim.bo.filetype)))
  end
  ok, lang0 = pcall(_3_)
  if ok then
    return lang0
  else
    return nil
  end
end
local function defaultTypeOpts(key)
  _G.assert((nil ~= key), "Missing argument key on src/main/fnl/slurp.fnl:21")
  local _6_
  do
    local t_5_ = lang()
    if (nil ~= t_5_) then
      t_5_ = t_5_[key]
    else
    end
    _6_ = t_5_
  end
  return (_6_ or {["not"] = {}})
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
    local function _9_(_241)
      return typeMatch(_241, types)
    end
    return iter.find(_9_, iter.iterate(tree.nextParent, root0))
  end
end
local function forwardInto(typeOpts)
  local typeOpts0 = (typeOpts or defaultTypeOpts("motionInto"))
  local _let_11_ = vim.fn.getpos(".")
  local _ = _let_11_[1]
  local row = _let_11_[2]
  local col = _let_11_[3]
  local _0 = _let_11_[4]
  local root = vts.get_node()
  local function _12_(_241)
    return typeMatch(_241, typeOpts0)
  end
  local function _13_(_241)
    return tree.isLexicallyAfter(_241, row, col)
  end
  return ts.goto_node(iter.find(_12_, iter.filter(_13_, iter.iterate(tree.nextDescending, root))))
end
local function forwardOver(typeOpts)
  local typeOpts0 = (typeOpts or defaultTypeOpts("motionOver"))
  local _let_14_ = vim.fn.getpos(".")
  local _ = _let_14_[1]
  local row = _let_14_[2]
  local col = _let_14_[3]
  local _0 = _let_14_[4]
  local root = vts.get_node()
  local target
  local function _15_(_241)
    return typeMatch(_241, typeOpts0)
  end
  local function _16_(_241)
    return tree.isLexicallyAfter(_241, row, col)
  end
  target = iter.find(_15_, iter.filter(_16_, iter.iterate(tree.nextAscending, root)))
  return ts.goto_node(target)
end
local function backwardInto(typeOpts)
  local typeOpts0 = (typeOpts or defaultTypeOpts("motionInto"))
  local _let_17_ = vim.fn.getpos(".")
  local _ = _let_17_[1]
  local row = _let_17_[2]
  local col = _let_17_[3]
  local _0 = _let_17_[4]
  local root = vts.get_node()
  local function _18_(_241)
    return typeMatch(_241, typeOpts0)
  end
  local function _19_(_241)
    return tree.isLexicallyBefore(_241, row, col)
  end
  return ts.goto_node(iter.find(_18_, iter.filter(_19_, iter.iterate(tree.prevDescending, root))))
end
local function backwardOver(typeOpts)
  local typeOpts0 = (typeOpts or defaultTypeOpts("motionOver"))
  local _let_20_ = vim.fn.getpos(".")
  local _ = _let_20_[1]
  local row = _let_20_[2]
  local col = _let_20_[3]
  local _0 = _let_20_[4]
  local root = vts.get_node()
  local function _21_(_241)
    return typeMatch(_241, typeOpts0)
  end
  local function _22_(_241)
    return tree.isLexicallyBefore(_241, row, col)
  end
  return ts.goto_node(iter.find(_21_, iter.filter(_22_, iter.iterate(tree.prevAscending, root))))
end
return {lang = lang, forwardInto = forwardInto, forwardOver = forwardOver, backwardOver = backwardOver, backwardInto = backwardInto, select = slurpSelect, find = find}

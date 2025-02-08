local iter = require("iter")
local m = {}
local function find(pred, iterfunc, a, i)
  local i0, v = iterfunc(a, i)
  local x = pred(v)
  if x then
    return i0, v, x
  else
    if (nil == v) then
      return nil, nil
    else
      return find(pred, iterfunc, a, i0)
    end
  end
end
--[[ (find (fn [x] (= "b" x)) (ipairs ["a" "b" "c"])) ]]
local function linesAndPosition(lines)
  local row, _, col = nil, nil, nil
  local function _3_(line)
    return string.find(line, "|")
  end
  row, _, col = find(_3_, ipairs(lines))
  if not row then
    error("missing pipe character in lines input")
  else
  end
  local lines0
  do
    local tbl_21_auto = {}
    local i_22_auto = 0
    for i, v in ipairs(lines) do
      local val_23_auto
      if (row == i) then
        val_23_auto = v:gsub("|", "")
      else
        val_23_auto = v
      end
      if (nil ~= val_23_auto) then
        i_22_auto = (i_22_auto + 1)
        tbl_21_auto[i_22_auto] = val_23_auto
      else
      end
    end
    lines0 = tbl_21_auto
  end
  return lines0, {row, (col - 1)}
end
--[[ (linesAndPosition ["first line" "se|cond line" "third line"]) ]]
m.setup = function(buf, lines)
  do
    local lines0, pos = linesAndPosition(lines)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, lines0)
    vim.api.nvim_set_option_value("filetype", "fennel", {})
    vim.api.nvim_exec2("lua vim.treesitter.start()", {})
    vim.api.nvim_win_set_cursor(0, pos)
  end
  return buf
end
local function injectCursor(lines, _7_)
  local row = _7_[1]
  local col = _7_[2]
  local tbl_21_auto = {}
  local i_22_auto = 0
  for r, line in ipairs(lines) do
    local val_23_auto
    if (row == r) then
      local start = line:sub(1, (col - 1))
      local _end = line:sub(col)
      val_23_auto = (start .. "|" .. _end)
    else
      val_23_auto = line
    end
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
--[[ (icollect [_ v (ipairs [1 2 3 4 5])] (injectCursor ["foo" "bar" "baz"] [2 v])) ]]
m.actual = function(buf, options)
  if options then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, true)
    local lines0
    if options.cursor then
      lines0 = injectCursor(lines, cursor)
    else
      lines0 = lines
    end
    return lines0
  else
    return vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
  end
end
m.withBuf = function(f)
  local buf = vim.api.nvim_create_buf(false, true)
  local err, result = pcall(f, buf)
  vim.api.nvim_buf_delete(buf, {})
  if err then
    return error(err)
  else
    return nil
  end
end
return m

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
m.actual = function(buf)
  return vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
end
return m

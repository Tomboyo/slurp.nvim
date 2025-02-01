local function setup(nvim, lines, pos)
  vim.rpcrequest(nvim, "nvim_buf_set_lines", 0, 0, 1, false, lines)
  vim.rpcrequest(nvim, "nvim_set_option_value", "filetype", "fennel", {})
  vim.rpcrequest(nvim, "nvim_exec_lua", "vim.treesitter.start()", {})
  return vim.rpcrequest(nvim, "nvim_win_set_cursor", 0, pos)
end
local function plug(nvim, mapping)
  return vim.rpcrequest(nvim, "nvim_feedkeys", vim.api.nvim_replace_termcodes(mapping, true, true, true), "m", false)
end
local function actual(nvim)
  return vim.rpcrequest(nvim, "nvim_buf_get_lines", 0, 0, 1, true)[1]
end
local function _1_()
  local nvim = nil
  local function _2_()
    nvim = vim.fn.jobstart({"nvim", "--embed", "--headless"}, {rpc = true, width = 80, height = 24})
    return nil
  end
  before_each(_2_)
  local function _3_()
    return vim.fn.jobstop(nvim)
  end
  after_each(_3_)
  local function _4_()
    setup(nvim, {"(foo (bar (baz) bang) whizz)"}, {1, 12})
    plug(nvim, "<Plug>(slurp-slurp-close-paren-forward)")
    return assert.is.equal("(foo (bar (baz bang)) whizz)", actual(nvim))
  end
  local function _5_()
    setup(nvim, {"(foo (bar ((baz)) bang) whizz)"}, {1, 13})
    plug(nvim, "<Plug>(slurp-slurp-close-paren-forward)")
    return assert.is.equal("(foo (bar ((baz) bang)) whizz)", actual(nvim))
  end
  describe("slurp close paren forward", it("swaps the closing paren with the node's sibling", _4_), it("applies to the smallest node around the cursor with a sibling", _5_))
  local function _6_()
    local function _7_()
      setup(nvim, {"(foo (bar (baz) bang) whizz)"}, {1, 12})
      plug(nvim, "<Plug>(slurp-slurp-open-paren-backward)")
      return assert.is.equal("(foo ((bar baz) bang) whizz)", actual(nvim))
    end
    it("swaps the opening paren with the preceding element", _7_)
    local function _8_()
      setup(nvim, {"(foo (bar ((baz)) bang) whizz)"}, {1, 13})
      plug(nvim, "<Plug>(slurp-slurp-open-paren-backward)")
      return assert.is.equal("(foo ((bar (baz)) bang) whizz)", actual(nvim))
    end
    return it("applies to the smallest node around the cursor with a sibling", _8_)
  end
  return describe("slurp open paren backward", _6_)
end
return describe("slurping", _1_)

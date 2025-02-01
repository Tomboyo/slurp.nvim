local n = require("util.nvim")
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
    n.setup(nvim, {"(foo (bar (baz) bang) whizz)"}, {1, 12})
    n.plug(nvim, "<Plug>(slurp-slurp-close-paren-forward)")
    return assert.is.equal("(foo (bar (baz bang)) whizz)", n.actual(nvim))
  end
  local function _5_()
    n.setup(nvim, {"(foo (bar ((baz)) bang) whizz)"}, {1, 13})
    n.plug(nvim, "<Plug>(slurp-slurp-close-paren-forward)")
    return assert.is.equal("(foo (bar ((baz) bang)) whizz)", n.actual(nvim))
  end
  describe("slurp close paren forward", it("swaps the closing paren with the node's sibling", _4_), it("applies to the smallest node around the cursor with a sibling", _5_))
  local function _6_()
    local function _7_()
      n.setup(nvim, {"(foo (bar (baz) bang) whizz)"}, {1, 12})
      n.plug(nvim, "<Plug>(slurp-slurp-open-paren-backward)")
      return assert.is.equal("(foo ((bar baz) bang) whizz)", n.actual(nvim))
    end
    it("swaps the opening paren with the preceding element", _7_)
    local function _8_()
      n.setup(nvim, {"(foo (bar ((baz)) bang) whizz)"}, {1, 13})
      n.plug(nvim, "<Plug>(slurp-slurp-open-paren-backward)")
      return assert.is.equal("(foo ((bar (baz)) bang) whizz)", n.actual(nvim))
    end
    return it("applies to the smallest node around the cursor with a sibling", _8_)
  end
  return describe("slurp open paren backward", _6_)
end
return describe("slurping", _1_)

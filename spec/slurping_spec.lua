local nvim = require("slurp/util/nvim")
local slurp = require("slurp")
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    local buf = nil
    do
      local b_2_auto0 = require("plenary.busted")
      local function _2_()
        buf = vim.api.nvim_create_buf(false, true)
        return nil
      end
      b_2_auto0.before_each(_2_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _3_()
        return vim.api.nvim_buf_delete(buf, {})
      end
      b_2_auto0.after_each(_3_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _4_()
        nvim.setup(buf, {"(foo (bar (b|az) bang) whizz)"})
        slurp.slurpForward(")")
        return assert.is.equal("(foo (bar (baz bang)) whizz)", nvim.actual(buf))
      end
      b_2_auto0.it("swaps the closing delimiter with the sibling to the right", _4_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _5_()
      nvim.setup(buf, {"(foo (bar (b|az)) bang)"})
      slurp.slurpForward(")")
      return assert.is.equal("(foo (bar (baz) bang))", nvim.actual(buf))
    end
    return b_2_auto0.it("is recursive", _5_)
  end
  b_2_auto.describe("slurpForward", _1_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _6_()
    local buf = nil
    do
      local b_2_auto0 = require("plenary.busted")
      local function _7_()
        buf = vim.api.nvim_create_buf(false, true)
        return nil
      end
      b_2_auto0.before_each(_7_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _8_()
        return vim.api.nvim_buf_delete(buf, {})
      end
      b_2_auto0.after_each(_8_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _9_()
        nvim.setup(buf, {"(foo (bar (b|az) bang) whizz)"})
        slurp.slurpBackward("(")
        return assert.is.equal("(foo ((bar baz) bang) whizz)", nvim.actual(buf))
      end
      b_2_auto0.it("swaps the opening delimiter with the sibling to the left", _9_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _10_()
      nvim.setup(buf, {"(foo ((b|ar) baz) bang)"})
      slurp.slurpBackward("(")
      return assert.is.equal("((foo (bar) baz) bang)", nvim.actual(buf))
    end
    return b_2_auto0.it("is recursive", _10_)
  end
  b_2_auto.describe("slurpBackward", _6_)
end
return nil

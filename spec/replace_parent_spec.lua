local nvim = require("util/nvim")
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
        nvim.setup(buf, {"(foo bar baz)"}, {1, 6})
        slurp.replaceParent()
        return assert.is.equal("bar", nvim.actual(buf))
      end
      b_2_auto0.it("replaces the parent element with the one under the cursor", _4_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _5_()
      nvim.setup(buf, {"(foo", "bar", "baz)"}, {2, 1})
      slurp.replaceParent()
      return assert.is.equal("bar", nvim.actual(buf))
    end
    return b_2_auto0.it("works across lines", _5_)
  end
  b_2_auto.describe("replaceParent", _1_)
end
return nil

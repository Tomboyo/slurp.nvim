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
        nvim.setup(buf, {"(foo (bar baz) baz)"}, {1, 7})
        slurp.unwrap("(", ")")
        return assert.is.equal("(foo bar baz baz)", nvim.actual(buf))
      end
      b_2_auto0.it("splices the content of a node into its parent", _4_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _5_()
      nvim.setup(buf, {"(foo [bar baz] bang)"}, {1, 7})
      slurp.unwrap("[", "]")
      return assert.is.equal("(foo bar baz bang)", nvim.actual(buf))
    end
    return b_2_auto0.it("works with arbitrary delimiters (that are grammatically correct)", _5_)
  end
  b_2_auto.describe("unwrap", _1_)
end
return nil

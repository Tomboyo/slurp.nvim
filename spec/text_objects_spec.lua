local nvim = require("slurp/util/nvim")
local slurp = require("slurp")
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _2_()
        local function _3_(buf)
          nvim.setup(buf, {"(foo b|ar baz)"})
          slurp.select(vim.treesitter.get_node())
          return assert.is.same({"bar"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_3_)
      end
      b_2_auto0.it("selects nodes", _2_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _4_()
        local function _5_(buf)
          nvim.setup(buf, {"|(foo", "bar", "baz)"})
          slurp.select(vim.treesitter.get_node())
          return assert.is.same({"(foo", "bar", "baz)"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_5_)
      end
      b_2_auto0.it("selects multiline nodes", _4_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _6_()
        local function _7_(buf)
          nvim.setup(buf, {"|(foo bar baz)"})
          slurp.select({0, 5, 0, 8})
          return assert.is.same({"bar"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_7_)
      end
      b_2_auto0.it("selects 0,0-offset end-exclusive ranges", _6_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _8_()
      local function _9_(buf)
        nvim.setup(buf, {"|(foo", "bar", "baz)"})
        slurp.select({0, 0, 2, 4})
        return assert.is.same({"(foo", "bar", "baz)"}, nvim.actualSelection(buf))
      end
      return nvim.withBuf(_9_)
    end
    return b_2_auto0.it("selects multiline ranges", _8_)
  end
  b_2_auto.describe("select", _1_)
end
return nil

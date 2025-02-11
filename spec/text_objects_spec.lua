local busted = require("plenary.busted")
local nvim = require("slurp/util/nvim")
local slurp = require("slurp")
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _2_()
        local function _3_(buf)
          nvim.setup(buf, {"(foo |bar baz)"})
          do
            local n = vim.treesitter.get_node()
            local p = n:parent()
            slurp.select(p)
          end
          return assert.is.same({"(foo bar baz)"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_3_)
      end
      b_2_auto0.it("selects a given node", _2_)
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
    local b_2_auto0 = require("plenary.busted")
    local function _6_()
      local function _7_(buf)
        nvim.setup(buf, {"|(foo bar baz)"})
        slurp.select()
        return assert.is.same({"("}, nvim.actualSelection(buf))
      end
      return nvim.withBuf(_7_)
    end
    return b_2_auto0.it("selects nothing when given nil", _6_)
  end
  b_2_auto.describe("select", _1_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _8_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _9_()
        local function _10_(buf)
          nvim.setup(buf, {"(:foo :b|ar :baz)"})
          slurp.select(slurp.find({"list", "string_content", "symbol"}))
          return assert.is.same({"bar"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_10_)
      end
      b_2_auto0.it("gets a node of any matching type", _9_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _11_()
      local function _12_(buf)
        nvim.setup(buf, {"(:foo :b|ar :baz)"})
        slurp.select(slurp.find({"symbol", "list"}))
        return assert.is.same({"(:foo :bar :baz)"}, nvim.actualSelection(buf))
      end
      return nvim.withBuf(_12_)
    end
    return b_2_auto0.it("gets the closest node of any matching type", _11_)
  end
  b_2_auto.describe("find", _8_)
end
return nil

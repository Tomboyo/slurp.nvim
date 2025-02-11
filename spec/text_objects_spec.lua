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
          slurp.selectNode()
          return assert.is.same({"bar"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_3_)
      end
      b_2_auto0.it("selects the node under the cursor by default", _2_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _4_()
        local function _5_(buf)
          nvim.setup(buf, {"|(foo", "bar", "baz)"})
          slurp.selectNode()
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
          slurp.selectNode({0, 5, 0, 8})
          return assert.is.same({"bar"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_7_)
      end
      b_2_auto0.it("selects 0,0-offset end-exclusive ranges", _6_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _8_()
        local function _9_(buf)
          nvim.setup(buf, {"|(foo", "bar", "baz)"})
          slurp.selectNode({0, 0, 2, 4})
          return assert.is.same({"(foo", "bar", "baz)"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_9_)
      end
      b_2_auto0.it("selects multiline ranges", _8_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _10_()
        local b_2_auto1 = require("plenary.busted")
        local function _11_()
          local function _12_(buf)
            nvim.setup(buf, {"|(foo", "bar", "baz)"})
            slurp.selectNode(nil, {inner = true})
            return assert.is.same({"foo", "bar", "baz"}, nvim.actualSelection(buf))
          end
          return nvim.withBuf(_12_)
        end
        return b_2_auto1.it("selects the contents of a node, excluding its first and last children", _11_)
      end
      b_2_auto0.describe("when {:inner true}", _10_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _13_()
      local function _14_(buf)
        nvim.setup(buf, {"|(   )"})
        slurp.selectNode(nil, {inner = true})
        return assert.is.same({"   "}, nvim.actualSelection(buf))
      end
      return nvim.withBuf(_14_)
    end
    return b_2_auto0.it("selects the whitespace content of a node with only unnamed children", _13_)
  end
  b_2_auto.describe("select", _1_)
end
return nil

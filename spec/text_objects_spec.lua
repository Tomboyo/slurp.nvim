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
      b_2_auto0.it("selects the node under the cursor when given no args", _2_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _4_()
        local function _5_(buf)
          nvim.setup(buf, {"(foo |bar baz)"})
          do
            local n = vim.treesitter.get_node()
            local p = n:parent()
            slurp.selectNode(p)
          end
          return assert.is.same({"(foo bar baz)"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_5_)
      end
      b_2_auto0.it("selects a given node", _4_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _6_()
        local function _7_(buf)
          nvim.setup(buf, {"|(foo", "bar", "baz)"})
          slurp.selectNode()
          return assert.is.same({"(foo", "bar", "baz)"}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_7_)
      end
      b_2_auto0.it("selects multiline nodes", _6_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _8_()
      do
        local b_2_auto1 = require("plenary.busted")
        local function _9_()
          local function _10_(buf)
            nvim.setup(buf, {"|(foo bar baz)"})
            slurp.selectNode({inner = true})
            return assert.is.same({"foo bar baz"}, nvim.actualSelection(buf))
          end
          return nvim.withBuf(_10_)
        end
        b_2_auto1.it("selects the contents of the node under the cursor", _9_)
      end
      do
        local b_2_auto1 = require("plenary.busted")
        local function _11_()
          local function _12_(buf)
            nvim.setup(buf, {"(foo |bar baz)"})
            do
              local n = vim.treesitter.get_node()
              slurp.selectNode(n:parent(), {inner = true})
            end
            return assert.is.same({"foo bar baz"}, nvim.actualSelection(buf))
          end
          return nvim.withBuf(_12_)
        end
        b_2_auto1.it("selects the contents of a given node", _11_)
      end
      do
        local b_2_auto1 = require("plenary.busted")
        local function _13_()
          local function _14_(buf)
            nvim.setup(buf, {"|foo"})
            slurp.selectNode({inner = true})
            return assert.is.same({"foo"}, nvim.actualSelection(buf))
          end
          return nvim.withBuf(_14_)
        end
        b_2_auto1.it("selects an entire atomic node", _13_)
      end
      local b_2_auto1 = require("plenary.busted")
      local function _15_()
        local function _16_(buf)
          nvim.setup(buf, {"|(   )"})
          slurp.selectNode({inner = true})
          return assert.is.same({"   "}, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_16_)
      end
      return b_2_auto1.it("selects the whitespace content of an empty node", _15_)
    end
    return b_2_auto0.describe("when {:inner true}", _8_)
  end
  b_2_auto.describe("select", _1_)
end
return nil

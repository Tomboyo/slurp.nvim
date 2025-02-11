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
return nil

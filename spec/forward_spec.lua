local nvim = require("slurp/util/nvim")
local slurp = require("slurp")
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _2_()
        local function _3_(buf)
          nvim.setup(buf, {"(|foo (bar baz) bang)"})
          slurp.forwardInto()
          return assert.is.same({"(foo |(bar baz) bang)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_3_)
      end
      b_2_auto0.it("moves the cursor to the start of the next element", _2_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _4_()
        local function _5_(buf)
          nvim.setup(buf, {"(foo |(bar baz) bang)"})
          slurp.forwardInto()
          return assert.is.same({"(foo (|bar baz) bang)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_5_)
      end
      b_2_auto0.it("moves to child elements before sibling elements", _4_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _6_()
      local function _7_(buf)
        nvim.setup(buf, {"(|foo", "bar", "baz)"})
        slurp.forwardInto()
        return assert.is.same({"(foo", "|bar", "baz)"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_7_)
    end
    return b_2_auto0.it("will move to subsequent lines", _6_)
  end
  b_2_auto.describe("forwardInto fennel", _1_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _8_()
    local b_2_auto0 = require("plenary.busted")
    local function _9_()
      local function _10_(buf)
        nvim.setup(buf, {"(|a.b.c :arg :arg)"})
        slurp.forwardOver(require("slurp/lang/fennel"))
        return assert.is.same({"(a.b.c |:arg :arg)"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_10_)
    end
    return b_2_auto0.it("skips over symbol fragments", _9_)
  end
  b_2_auto.describe("forwardOver fennel", _8_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _11_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _12_()
        local function _13_(buf)
          nvim.setup(buf, {"(a.b.c |:arg)"})
          slurp.backwardOver(require("slurp/lang/fennel"))
          return assert.is.same({"(|a.b.c :arg)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_13_)
      end
      b_2_auto0.it("skips over symbol fragments", _12_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _14_()
      local function _15_(buf)
        nvim.setup(buf, {"(foo", "(|bar))"})
        slurp.backwardOver(require("slurp/lang/fennel"))
        return assert.is.same({"(|foo", "(bar))"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_15_)
    end
    return b_2_auto0.it("does not stop on the parent node", _14_)
  end
  b_2_auto.describe("backwardOver fennel", _11_)
end
return nil

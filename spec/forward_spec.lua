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
          slurp.forwardIntoElement()
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
          slurp.forwardIntoElement()
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
        slurp.forwardIntoElement()
        return assert.is.same({"(foo", "|bar", "baz)"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_7_)
    end
    return b_2_auto0.it("will move to subsequent lines", _6_)
  end
  b_2_auto.describe("Forward into element", _1_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _8_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _9_()
        local function _10_(buf)
          nvim.setup(buf, {"(|foo (bar baz) bang)"})
          slurp.forwardOverElement()
          return assert.is.same({"(foo |(bar baz) bang)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_10_)
      end
      b_2_auto0.it("moves the cursor to the start of the next element", _9_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _11_()
        local function _12_(buf)
          nvim.setup(buf, {"(foo |(bar baz) bang)"})
          slurp.forwardOverElement()
          return assert.is.same({"(foo (bar baz) |bang)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_12_)
      end
      b_2_auto0.it("moves the cursor by sibling element only", _11_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _13_()
      local function _14_(buf)
        nvim.setup(buf, {"(|foo", "(bar baz)", "bang)"})
        slurp.forwardOverElement()
        return assert.is.same({"(foo", "|(bar baz)", "bang)"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_14_)
    end
    return b_2_auto0.it("will move to subsequent lines", _13_)
  end
  b_2_auto.describe("Forward over element", _8_)
end
return nil

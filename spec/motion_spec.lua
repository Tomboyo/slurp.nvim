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
    do
      local b_2_auto0 = require("plenary.busted")
      local function _6_()
        local function _7_(buf)
          nvim.setup(buf, {"(|foo", "bar", "baz)"})
          slurp.forwardInto()
          return assert.is.same({"(foo", "|bar", "baz)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_7_)
      end
      b_2_auto0.it("will move to subsequent lines", _6_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _8_()
      local function _9_(_241)
        nvim.setup(_241, {"(|foo :bar baz)"})
        slurp.forwardInto({["not"] = {"string", "string_content"}})
        return assert.is.same({"(foo :bar |baz)"}, nvim.actual(_241, {cursor = true}))
      end
      return nvim.withBuf(_9_)
    end
    return b_2_auto0.it("accepts custom typeOpts", _8_)
  end
  b_2_auto.describe("forwardInto fennel", _1_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _10_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _11_()
        local function _12_(buf)
          nvim.setup(buf, {"(|a.b.c :arg :arg)"})
          slurp.forwardOver()
          return assert.is.same({"(a.b.c |:arg :arg)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_12_)
      end
      b_2_auto0.it("skips over symbol fragments", _11_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _13_()
      local function _14_(buf)
        nvim.setup(buf, {"(|foo :bar baz)"})
        slurp.forwardOver({["not"] = {"string", "string_content"}})
        return assert.is.same({"(foo :bar |baz)"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_14_)
    end
    return b_2_auto0.it("accepts custom typeOpts", _13_)
  end
  b_2_auto.describe("forwardOver fennel", _10_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _15_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _16_()
        local function _17_(buf)
          nvim.setup(buf, {"(a.b.c |:arg)"})
          slurp.backwardOver()
          return assert.is.same({"(|a.b.c :arg)"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_17_)
      end
      b_2_auto0.it("skips over symbol fragments", _16_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _18_()
        local function _19_(buf)
          nvim.setup(buf, {"(foo", "(|bar))"})
          slurp.backwardOver()
          return assert.is.same({"(|foo", "(bar))"}, nvim.actual(buf, {cursor = true}))
        end
        return nvim.withBuf(_19_)
      end
      b_2_auto0.it("does not stop on the parent node", _18_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _20_()
      local function _21_(buf)
        nvim.setup(buf, {"(foo :bar |baz)"})
        slurp.backwardOver({["not"] = {"string", "string_content"}})
        return assert.is.same({"(|foo :bar baz)"}, nvim.actual(buf, {cursor = true}))
      end
      return nvim.withBuf(_21_)
    end
    return b_2_auto0.it("accepts custom typeOpts", _20_)
  end
  b_2_auto.describe("backwardOver fennel", _15_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _22_()
    do
      local b_2_auto0 = require("plenary.busted")
      local function _23_()
        local function _24_(_241)
          nvim.setup(_241, {"(foo (bar ((baz))) |bang)"})
          slurp.backwardInto()
          return assert.is.same({"(foo (bar ((|baz))) bang)"}, nvim.actual(_241, {cursor = true}))
        end
        return nvim.withBuf(_24_)
      end
      b_2_auto0.it("stops on the deepest child of the previous sibling", _23_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _25_()
        local function _26_(_241)
          nvim.setup(_241, {"(foo (|bar) baz)"})
          slurp.backwardInto()
          return assert.is.same({"(foo |(bar) baz)"}, nvim.actual(_241, {cursor = true}))
        end
        return nvim.withBuf(_26_)
      end
      b_2_auto0.it("stops on parent elements", _25_)
    end
    do
      local b_2_auto0 = require("plenary.busted")
      local function _27_()
        local function _28_(_241)
          nvim.setup(_241, {"a.b.|c"})
          slurp.backwardInto()
          return assert.is.same({"a.|b.c"}, nvim.actual(_241, {cursor = true}))
        end
        return nvim.withBuf(_28_)
      end
      b_2_auto0.it("stops on symbol fragments", _27_)
    end
    local b_2_auto0 = require("plenary.busted")
    local function _29_()
      local function _30_(_241)
        nvim.setup(_241, {"(drink (more :glurp) |slurm)"})
        slurp.backwardInto({["not"] = {"string", "string_content"}})
        return assert.is.same({"(drink (|more :glurp) slurm)"}, nvim.actual(_241, {cursor = true}))
      end
      return nvim.withBuf(_30_)
    end
    return b_2_auto0.it("accepts custom typeOpts", _29_)
  end
  b_2_auto.describe("backwardInto fennel", _22_)
end
return nil

local nvim = require("slurp/util/nvim")
local iter = require("slurp/iter")
local slurp = require("slurp")
local fen = require("slurp.lang.fennel")
local roundLists = {{{"(case |:in :left :right)"}, {"(case :in :left :right)"}}, {{"(fn [] f|oo)"}, {"(fn [] foo)"}}, {{"(let [foo :bar] |foo)"}, {"(let [foo :bar] foo)"}}, {{"(:a :b |:c)"}, {"(:a :b :c)"}}, {{"(match |:in", ":left :right", ")"}, {"(match :in", ":left :right", ")"}}}
local curlyLists = {{{"(local |{foo} {:foo})"}, {"{foo}"}}, {{"{:a :|b :c}"}, {"{:a :b :c}"}}}
local squareLists = {{{"(let [foo :bar", "baz :bang]|", "foo)"}, {"[foo :bar", "baz :bang]"}}, {{"[:a :b |:c]"}, {"[:a :b :c]"}}, {{"(fn [a b |c] nil)"}, {"[a b c]"}}}
local allLists = iter.collect(iter.concat(iter.iterate(roundLists), iter.iterate(curlyLists), iter.iterate(squareLists)))
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    for i, _2_ in ipairs(roundLists) do
      local given = _2_[1]
      local expected = _2_[2]
      local b_2_auto0 = require("plenary.busted")
      local function _3_()
        local function _4_(buf)
          nvim.setup(buf, given)
          slurp.select(slurp.find(fen.roundList))
          return assert.is.same(expected, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_4_)
      end
      b_2_auto0.it(string.format("%2d: %s", i, vim.inspect(given)), _3_)
    end
    return nil
  end
  b_2_auto.describe("select a fennel.roundList", _1_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _5_()
    for i, _6_ in ipairs(squareLists) do
      local given = _6_[1]
      local expected = _6_[2]
      local b_2_auto0 = require("plenary.busted")
      local function _7_()
        local function _8_(buf)
          nvim.setup(buf, given)
          slurp.select(slurp.find(fen.squareList))
          return assert.is.same(expected, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_8_)
      end
      b_2_auto0.it(string.format("%2d: %s", i, vim.inspect(given)), _7_)
    end
    return nil
  end
  b_2_auto.describe("select a fennel.squareList", _5_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _9_()
    for i, _10_ in ipairs(curlyLists) do
      local given = _10_[1]
      local expected = _10_[2]
      local b_2_auto0 = require("plenary.busted")
      local function _11_()
        local function _12_(buf)
          nvim.setup(buf, given)
          slurp.select(slurp.find(fen.curlyList))
          return assert.is.same(expected, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_12_)
      end
      b_2_auto0.it(string.format("%2d: %s", i, vim.inspect(given)), _11_)
    end
    return nil
  end
  b_2_auto.describe("select a fennel.curlyList", _9_)
end
do
  local b_2_auto = require("plenary.busted")
  local function _13_()
    for i, _14_ in ipairs(allLists) do
      local given = _14_[1]
      local expected = _14_[2]
      local b_2_auto0 = require("plenary.busted")
      local function _15_()
        local function _16_(buf)
          nvim.setup(buf, given)
          slurp.select(slurp.find(fen.anyList))
          return assert.is.same(expected, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_16_)
      end
      b_2_auto0.it(string.format("%2d: %s", i, vim.inspect(given)), _15_)
    end
    return nil
  end
  b_2_auto.describe("select a fennel.anyList", _13_)
end
return nil

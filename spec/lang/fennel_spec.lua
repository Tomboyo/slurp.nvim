local nvim = require("slurp/util/nvim")
local slurp = require("slurp")
local fen = require("slurp.lang.fennel")
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    for i, _2_ in ipairs({{{"(case |:in :left :right)"}, {"(case :in :left :right)"}}, {{"(fn [] f|oo)"}, {"(fn [] foo)"}}, {{"(let [foo :bar", "baz :bang]|", "foo)"}, {"[foo :bar", "baz :bang]"}}, {{"(let [foo :bar] |foo)"}, {"(let [foo :bar] foo)"}}, {{"(:a :b |:c)"}, {"(:a :b :c)"}}, {{"(match |:in", ":left :right", ")"}, {"(match :in", ":left :right", ")"}}, {{"[:a :b |:c]"}, {"[:a :b :c]"}}, {{"(fn [a b |c] nil)"}, {"[a b c]"}}, {{"{:a :|b :c}"}, {"{:a :b :c}"}}, {{"(local |{foo} {:foo})"}, {"{foo}"}}}) do
      local given = _2_[1]
      local expected = _2_[2]
      local b_2_auto0 = require("plenary.busted")
      local function _3_()
        local function _4_(buf)
          nvim.setup(buf, given)
          slurp.select(slurp.find(fen.anyList))
          return assert.is.same(expected, nvim.actualSelection(buf))
        end
        return nvim.withBuf(_4_)
      end
      b_2_auto0.it(string.format("%2d: %s", i, vim.inspect(given)), _3_)
    end
    return nil
  end
  b_2_auto.describe("select any list", _1_)
end
return nil

local nvim = require("slurp/util/nvim")
local slurp = require("slurp")
local fen = require("slurp.lang.fennel")
do
  local b_2_auto = require("plenary.busted")
  local function _1_()
    for _, _2_ in ipairs({{"binding_pair", {"(local foo |:bar)"}, {"foo :bar"}}, {"case_form", {"(case |:in :left :right)"}, {"(case :in :left :right)"}}, {"case_pair", {"(case {:in}", "{:pattern} |nil", ")"}, {"{:pattern} nil"}}, {"fn_form", {"(fn [] f|oo)"}, {"(fn [] foo)"}}, {"binding_pair", {"(let [foo :ba|r] foo)"}, {"foo :bar"}}, {"let_vars", {"(let [foo :bar", "baz :bang]|", "foo)"}, {"[foo :bar", "baz :bang]"}}, {"let_form", {"(let [foo :bar] |foo)"}, {"(let [foo :bar] foo)"}}, {"list", {"(:a :b |:c)"}, {"(:a :b :c)"}}, {"match_form", {"(match |:in", ":left :right", ")"}, {"(match :in", ":left :right", ")"}}, {"sequence", {"[:a :b |:c]"}, {"[:a :b :c]"}}, {"sequence_arguments", {"(fn [a b |c] nil)"}, {"[a b c]"}}, {"table", {"{:a :|b :c}"}, {"{:a :b :c}"}}, {"table_binding", {"(let [{foo} | {:cats}] foo)"}, {"{foo}  {:cats}"}}}) do
      local name = _2_[1]
      local given = _2_[2]
      local expected = _2_[3]
      local b_2_auto0 = require("plenary.busted")
      local function _3_()
        local b_2_auto1 = require("plenary.busted")
        local function _4_()
          local function _5_(buf)
            nvim.setup(buf, given)
            slurp.select(slurp.find(fen.listLike))
            return assert.is.same(expected, nvim.actualSelection(buf))
          end
          return nvim.withBuf(_5_)
        end
        return b_2_auto1.it(string.format("selects %s", vim.inspect(expected)), _4_)
      end
      b_2_auto0.describe(string.format("%s: given %s", name, vim.inspect(given)), _3_)
    end
    return nil
  end
  b_2_auto.describe("selecting list-like elements", _1_)
end
return nil

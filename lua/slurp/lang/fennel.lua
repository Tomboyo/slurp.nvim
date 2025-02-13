local iter = require("slurp/iter")
local m = {}
m.squareList = {"let_vars", "sequence", "sequence_arguments"}
m.roundList = {"case_form", "let_form", "fn_form", "list", "local_form", "match_form", "var_form"}
m.curlyList = {"table", "table_binding"}
m.anyList = iter.collect(iter.concat(iter.iterate(m.squareList), iter.iterate(m.roundList), iter.iterate(m.curlyList)))
m.forwardOver = {["not"] = {"symbol_fragment"}}
return m

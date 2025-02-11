local iter = require("slurp/iter")
local m = {}
m.listLike = {"binding_pair", "case_form", "case_pair", "fn_form", "let_form", "let_vars", "list", "match_form", "sequence", "sequence_arguments", "table", "table_binding"}
m.squareList = {"let_vars", "sequence", "sequence_arguments"}
m.roundList = {"list"}
m.curlyList = {"table"}
return m

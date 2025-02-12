(local iter (require :slurp/iter))

(local m {})

(set m.squareList [:let_vars
                  :sequence
                  :sequence_arguments])

(set m.roundList [:case_form
                  :let_form
                  :fn_form
                  :list
                  :local_form
                  :match_form
                  :var_form])

(set m.curlyList [:table
                  :table_binding])

(set m.anyList (iter.collect
                 (iter.concat (iter.iterate m.squareList)
                              (iter.iterate m.roundList)
                              (iter.iterate m.curlyList))))

m

(local m {})

(fn m.iterator [f x]
  "Produce an iterator from the function f. The iterator will yield x as its
  first value, f(x) as the second, f(f(x)) as the third, and so on until the
  application of f returns nil."
  (var state x)
  (fn []
    (if (= nil state)
        nil
        (let [tmp state]
          (set state (f state))
          tmp))))

(comment
  (let [it (m.iterator (fn [x] (if (< x 5) (+ 1 x))) 0)]
    (accumulate [acc [] v it]
      (do (table.insert acc v) acc))))

(fn m.stateful [iter a i]
  "Given a stateless iter (like ipairs), return a stateful iter that yields each
  successive value of the iter, but not the state. E.g.
  (stateful (ipairs [:a :b :c])) yields :a, :b, and :c, not
  [1 :a], [2 :b], [3 :c]"
  (var state i)
  (fn []
    (let [(s v) (iter a state)]
      (if (= nil v)
          nil
          (do
            (set state s)
            v)))))

(comment
  (let [it (m.stateful (ipairs [:a :b :c]))]
    (accumulate [acc [] v it]
      (do (table.insert acc v) acc))))

(fn m.indexed [f]
  "Given a stateful iterator f, return a new stateful iterator that returns each
  value of f along with its index in the form [index f()]. Indexing is 0-based.
  The iterator returns nil when f returns nil (not [index, nil])."
  (var state 0)
  (fn []
    (let [n (f)
          tmp state]
      (if (= nil n)
          nil
          (do 
            (set state (+ 1 state))
            [tmp n])))))

(comment
  (let [it (m.stateful (ipairs [:a :b :c]))
        it (m.indexed it)]
    (accumulate [acc [] v it]
      (do (table.insert acc v) acc)))
  )

(fn m.filter [pred iter]
  "Return an iterator over successive values v of iter for which (pred v) is
  truthy."
  (fn f []
    (let [tmp (iter)]
      (if (= nil tmp)
          nil
          (if (pred tmp)
              tmp
              (f))))))

(comment
  (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0)
        three (m.filter (fn [i] (< i 3)) ints)]
    (accumulate [acc [] v three]
      (do (table.insert acc v) acc))))
  

(fn m.find [pred iter]
  "Return the first value v of iter for which (pred v) is truthy."
  ((m.filter pred iter)))

(comment
  (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0)]
    (m.find (fn [x] (= x 3)) ints))
  )

m

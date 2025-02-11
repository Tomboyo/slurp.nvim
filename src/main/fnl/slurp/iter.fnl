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
    (icollect [v it] v))
  )

(fn m.iterate [arr]
  "Return an iterator over successive elements of the given array table"
  (m.stateful (ipairs arr)))

(comment
  (let [it (m.iterate [:a :b :c])]
    (icollect [v it] v))
  )

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
    (icollect [v it] v))
  )

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
    (icollect [v it] v))
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
    (icollect [v three] v))
  )

(fn m.map [f iter]
  "Returns an iterator which yields (f v) for each v yielded by iter until iter
  yields nil."
  (fn []
    (let [v (iter)]
      (if (= nil v)
          nil
          (f v)))))
 
(comment
  (let [it (m.stateful (ipairs [1 2 3 4]))
        it (m.map (fn [x] (* x x)) it)]
    (icollect [v it] v))
  )

(fn m.find [pred iter]
  "Return the first value v of iter for which (pred v) is truthy."
  ((m.filter pred iter)))

(comment
  (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0)]
    (m.find (fn [x] (= x 3)) ints))
  (let [it (m.iterator (fn [] nil) nil)]
    (m.find (fn [x] (error "I am never called")) it))
  )

(fn m.nth [n iter]
  "Get the nth element of iter, 0-based."
  (let [el (iter)]
    (case [n el]
          [_ nil] nil
          [0 _] el
          _ (m.nth (- n 1) iter))))

(comment
  (let [iter (m.stateful (ipairs [:a :b :c :d]))]
    (m.nth 2 iter))
  )

(fn m.collect [iter]
  "Collect the iter to a table"
  (icollect [v iter]
    v))

(comment
  (let [iter (m.stateful (ipairs [:a :b :c]))]
    (m.collect iter))
  )

m

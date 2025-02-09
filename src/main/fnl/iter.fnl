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

(fn m.filter [pred iter]
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
  (let [x (iter)]
    (if (= nil x)
        nil
        (if (pred x)
            x
            (m.find pred iter)))))

(comment
  (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0)]
    (m.find (fn [x] (= x 3)) ints))
  )

m

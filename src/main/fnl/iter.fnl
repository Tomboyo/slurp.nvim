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
  (local it (m.iterator (fn [x] (+ 1 x)) 0))
  (it)
  (let [it (m.iterator (fn [x] (if (< x 5) (+ 1 x))) 0)]
    (accumulate [acc [] v it]
      (do (table.insert acc v) acc)))
  (it)
    
  ; Counts to 4, then returns nil forever.
  (local iter (m.iterator
                (fn [x]
                  (if x
                      (if (> x 3) nil (+ 1 x))
                      1))))
  (iter))

(fn m.filter [pred iter]
  (fn f []
    (let [tmp (iter)]
      (if (= nil tmp)
          nil
          (if (pred tmp)
              tmp
              (f))))))

(comment
  ; An iterator over positive integers
  (local ints (m.iterator (fn [i] (if i (+ i 1) 1))))
  ; An iterator of only positive even integers
  (local evens (m.filter (fn [i] (= 0 (% i 2))) ints))
  (evens)

  (local iter (m.iterator (fn [x] (if x
                                      (if (> x 3) nil (+ 1 x))
                                      1))))
  (local evens (m.filter (fn [i] (= 0 (% i 2))) iter))
  (evens))

(fn m.find [pred iter]
  (let [x (iter)]
    (if (= nil x)
        nil
        (if (pred x)
            x
            (m.find pred iter)))))

m

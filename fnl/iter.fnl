(local m {})

(fn m.iterator [f]
  "Produce an iterator from the function f. f is called with no arguments to
  get the first value, and is called with the previous value to generate each
  subsequent value. Iteration stops when f returns nil."
  (var state (f))
  (fn []
    (if (= nil state)
        state
        (let [tmp state]
          (set state (f tmp))
          tmp))))

(comment
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

local m = {}
m.iterator = function(f, x)
  local state = x
  local function _1_()
    if (nil == state) then
      return nil
    else
      local tmp = state
      state = f(state)
      return tmp
    end
  end
  return _1_
end
--[[ (local it (m.iterator (fn [x] (+ 1 x)) 0)) (it) (let [it (m.iterator (fn [x] (if (< x 5) (+ 1 x))) 0)] (accumulate [acc [] v it] (do (table.insert acc v) acc))) (it) (local iter (m.iterator (fn [x] (if x (if (> x 3) nil (+ 1 x)) 1)))) (iter) ]]
m.filter = function(pred, iter)
  local function f()
    local tmp = iter()
    if (nil == tmp) then
      return nil
    else
      if pred(tmp) then
        return tmp
      else
        return f()
      end
    end
  end
  return f
end
--[[ (local ints (m.iterator (fn [i] (if i (+ i 1) 1)))) (local evens (m.filter (fn [i] (= 0 (% i 2))) ints)) (evens) (local iter (m.iterator (fn [x] (if x (if (> x 3) nil (+ 1 x)) 1)))) (local evens (m.filter (fn [i] (= 0 (% i 2))) iter)) (evens) ]]
m.find = function(pred, iter)
  local x = iter()
  if (nil == x) then
    return nil
  else
    if pred(x) then
      return x
    else
      return m.find(pred, iter)
    end
  end
end
return m

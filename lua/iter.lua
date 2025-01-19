local m = {}
m.iterator = function(f)
  local state = f()
  local function _1_()
    if (nil == state) then
      return state
    else
      local tmp = state
      state = f(tmp)
      return tmp
    end
  end
  return _1_
end
--[[ (local iter (m.iterator (fn [x] (if x (if (> x 3) nil (+ 1 x)) 1)))) (iter) ]]
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
return m

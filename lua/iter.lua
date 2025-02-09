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
--[[ (let [it (m.iterator (fn [x] (if (< x 5) (+ 1 x))) 0)] (accumulate [acc [] v it] (do (table.insert acc v) acc))) ]]
m.stateful = function(iter, a, i)
  local state = i
  local function _3_()
    local s, v = iter(a, state)
    if (nil == v) then
      return nil
    else
      state = s
      return v
    end
  end
  return _3_
end
--[[ (let [it (m.stateful (ipairs ["a" "b" "c"]))] (accumulate [acc [] v it] (do (table.insert acc v) acc))) ]]
m.indexed = function(f)
  local state = 0
  local function _5_()
    local n = f()
    local tmp = state
    if (nil == n) then
      return nil
    else
      state = (1 + state)
      return {tmp, n}
    end
  end
  return _5_
end
--[[ (let [it (m.stateful (ipairs ["a" "b" "c"])) it (m.indexed it)] (accumulate [acc [] v it] (do (table.insert acc v) acc))) ]]
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
--[[ (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0) three (m.filter (fn [i] (< i 3)) ints)] (accumulate [acc [] v three] (do (table.insert acc v) acc))) ]]
m.find = function(pred, iter)
  return m.filter(pred, iter)()
end
--[[ (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0)] (m.find (fn [x] (= x 3)) ints)) ]]
return m

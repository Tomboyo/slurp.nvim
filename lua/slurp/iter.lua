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
--[[ (let [it (m.iterator (fn [x] (if (< x 5) (+ 1 x))) 0)] (icollect [v it] v)) ]]
m.iterate = function(arr)
  return m.stateful(ipairs(arr))
end
--[[ (let [it (m.iterate ["a" "b" "c"])] (icollect [v it] v)) ]]
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
--[[ (let [it (m.stateful (ipairs ["a" "b" "c"]))] (icollect [v it] v)) ]]
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
--[[ (let [it (m.stateful (ipairs ["a" "b" "c"])) it (m.indexed it)] (icollect [v it] v)) ]]
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
--[[ (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0) three (m.filter (fn [i] (< i 3)) ints)] (icollect [v three] v)) ]]
m.map = function(f, iter)
  local function _9_()
    local v = iter()
    if (nil == v) then
      return nil
    else
      return f(v)
    end
  end
  return _9_
end
--[[ (let [it (m.stateful (ipairs [1 2 3 4])) it (m.map (fn [x] (* x x)) it)] (icollect [v it] v)) ]]
m.find = function(pred, iter)
  return m.filter(pred, iter)()
end
--[[ (let [ints (m.iterator (fn [i] (if (< i 10) (+ i 1))) 0)] (m.find (fn [x] (= x 3)) ints)) (let [it (m.iterator (fn [] nil) nil)] (m.find (fn [x] (error "I am never called")) it)) ]]
local function _12_(_11_)
  local i = _11_[1]
  local line = _11_[2]
  return string.find(line, "|")
end
m.find(_12_, m.indexed(m.iterate({"cats", "dog|s", "skunks"})))
return m

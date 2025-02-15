local m = {}
m.iterate = function(a, _3fb)
  _G.assert((nil ~= a), "Missing argument a on src/main/fnl/slurp/iter.fnl:3")
  local _1_, _2_, _3_ = type(a), a, _3fb
  if ((_1_ == "table") and (nil ~= _2_)) then
    local t = _2_
    return m.stateful(ipairs(t))
  elseif ((_1_ == "function") and (nil ~= _2_) and (nil ~= _3_)) then
    local f = _2_
    local x = _3_
    local state = x
    local function _4_()
      if (nil == state) then
        return nil
      else
        local tmp = state
        state = f(state)
        return tmp
      end
    end
    return _4_
  else
    return nil
  end
end
--[[ (let [it (m.iterate (fn [x] (if (< x 5) (+ 1 x))) 0)] (icollect [v it] v)) (let [it (m.iterate ["a" "b" "c"])] (icollect [v it] v)) ]]
m.concat = function(...)
  local iters = {...}
  local i = 1
  local function f()
    local iter = iters[i]
    if (nil == iter) then
      return nil
    else
      local x = iter()
      if (nil == x) then
        i = (1 + i)
        return f()
      else
        return x
      end
    end
  end
  return f
end
--[[ (let [a (m.iterate ["a" "b" "c"]) b (m.iterate [1 2 3]) c (m.concat a b)] (m.collect c)) (m.collect (m.concat)) ]]
m.stateful = function(iter, a, i)
  local state = i
  local function _9_()
    local s, v = iter(a, state)
    if (nil == v) then
      return nil
    else
      state = s
      return v
    end
  end
  return _9_
end
--[[ (let [it (m.stateful (ipairs ["a" "b" "c"]))] (icollect [v it] v)) ]]
m.indexed = function(f)
  local state = 0
  local function _11_()
    local n = f()
    local tmp = state
    if (nil == n) then
      return nil
    else
      state = (1 + state)
      return {tmp, n}
    end
  end
  return _11_
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
--[[ (let [ints (m.iterate (fn [i] (if (< i 10) (+ i 1))) 0) three (m.filter (fn [i] (< i 3)) ints)] (icollect [v three] v)) ]]
m.map = function(f, iter)
  local function _15_()
    local v = iter()
    if (nil == v) then
      return nil
    else
      return f(v)
    end
  end
  return _15_
end
--[[ (let [it (m.stateful (ipairs [1 2 3 4])) it (m.map (fn [x] (* x x)) it)] (icollect [v it] v)) ]]
m.find = function(pred, iter)
  return m.filter(pred, iter)()
end
--[[ (let [ints (m.iterate (fn [i] (if (< i 10) (+ i 1))) 0)] (m.find (fn [x] (= x 3)) ints)) (let [it (m.iterate (fn [] nil) nil)] (m.find (fn [x] (error "I am never called")) it)) ]]
m.nth = function(n, iter)
  local el = iter()
  local _17_ = {n, el}
  if (true and (_17_[2] == nil)) then
    local _ = _17_[1]
    return nil
  elseif ((_17_[1] == 0) and true) then
    local _ = _17_[2]
    return el
  else
    local _ = _17_
    return m.nth((n - 1), iter)
  end
end
--[[ (let [iter (m.stateful (ipairs ["a" "b" "c" "d"]))] (m.nth 2 iter)) ]]
m.collect = function(iter)
  local tbl_21_auto = {}
  local i_22_auto = 0
  for v in iter do
    local val_23_auto = v
    if (nil ~= val_23_auto) then
      i_22_auto = (i_22_auto + 1)
      tbl_21_auto[i_22_auto] = val_23_auto
    else
    end
  end
  return tbl_21_auto
end
--[[ (let [iter (m.stateful (ipairs ["a" "b" "c"]))] (m.collect iter)) ]]
return m

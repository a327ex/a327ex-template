function table.copy(t)
  local t_type = type(t)
  local copy
  if t_type == "table" then
    copy = {}
    for k, v in next, t, nil do
      copy[table.copy(k)] = table.copy(v)
    end
    setmetatable(copy, table.copy(getmetatable(t)))
  else
    copy = t
  end
  return copy
end


-- t = {}
-- table.array(t, 5) -> {1, 2, 3, 4, 5}
function table.array(t, n)
  for i = 1, n do
    table.push(t, i)
  end
  return t
end

-- t = {"a", "b", "c", "d"}
-- table.get(t, 1) -> "a"
-- table.get(t, 1, 3) -> {"a", "b", "c"}
-- table.get(t, 2, -1) -> {"b", "c", "d"}
function table.get(t, i, j)
  if i < 0 then i = #t + i + 1 end
  if not j then return t[i] end
  if j < 0 then j = #t + j + 1 end
  if i == j then return t[i] end
  local out = {}
  for k = i, j, math.sign(j-i) do table.push(out, t[k]) end
  return out
end


-- t = {"a", "b", "c", "d"}
-- table.set(t, 1, 1) -> {1, "b", "c", "d"}
-- table.set(t, 1, 3, 2) -> {2, 2, 2, "d"}
-- table.set(t, 2, -1, 3) -> {"a", 3, 3, 3}
function table.set(t, i, j, v)
  if i < 0 then i = #t + i + 1 end
  if not v then
    t[i] = j
    return t
  end
  if j < 0 then j = #t + j + 1 end
  if i == j then t[i] = v; return t end
  for k = i, j, math.sign(j-i) do t[k] = v end
  return t
end


-- Returns the index of the first instance of value v
-- t = {4, 3, 2, 4, "a", 1, "a"}
-- table.index(t, 4) -> 1
-- table.index(t, "a") -> 5
function table.index(t, v)
  for i, u in ipairs(t) do
    if u == v then return i end
  end
end


function table.back(t)
  return t[#t]
end


-- Same as table.get, except that for single values return them also in a table
-- t = {1, 2, 3}
-- table.slice(t, 1, 1) -> {1}
function table.slice(t, i, j)
  if i < 0 then i = #t + i + 1 end
  if j < 0 then j = #t + j + 1 end
  if i == j then return {t[i]} end
  local out = {}
  for k = i, j, math.sign(j-i) do table.push(out, t[k]) end
  return out
end


-- Returns the first n values
-- t = {4, 3, 2, 1}
-- table.take(t, 2) -> {4, 3}
function table.take(t, n)
  local out = {}
  for i = 1, n do table.push(t, t[i]) end
  return out
end


-- Returns the last n values
-- t = {4, 3, 2, 1}
-- table.drop(t, 2) -> {2, 1}
function table.drop(t, n)
  local out = {}
  for i = n+1, #t do table.push(out, t[i]) end
  return out
end


-- Inserts value v at the end of the table
-- t = {}
-- table.push(t, "a") -> {"a"}
function table.push(t, v)
  table.insert(t, v)
  return t
end


-- Removes the first n values
-- t = {4, 3, 2, 1}
-- table.shift(t, 3) -> {1}
function table.shift(t, n)
  for i = 1, (n or 1) do table.remove(t, 1) end
  return t
end


-- Inserts values at the start of the table
-- t = {3, 4}
-- table.unshift(t, 1, 2) -> {1, 2, 3, 4}
function table.unshift(t, ...)
  for j, v in ipairs({...}) do table.insert(t, 1+j-1, v) end
  return t
end


function table.pop(t)
  return table.remove(t, #t)
end


-- Deletes all instances of value v
function table.delete(t, v)
  for i = #t, 1, -1 do
    if v == t[i] then table.remove(t, i) end
  end
  return t
end


-- t = {"a", "b", "c", "d"}
-- table.remove(t, 1) -> {"b", "c", "d"}
-- table.remove(t, 2, 3) -> {"a", "d"}
-- table.remove(t, 3, -1) -> {"a", "b"}
function table.remove_range(t, i, j)
  if i < 0 then i = #t + i + 1 end
  if not j then
    table.remove(t, i)
    return t
  end
  if j < 0 then j = #t + j + 1 end
  if i == j then table.remove(t, i); return t end
  for k = j, i, -math.sign(j-i) do table.remove(t, k) end
  return t
end


-- Removes duplicates
-- t = {1, 1, 2, 2, 3, 3}
-- table.unify(t) -> {1, 2, 3}
-- t = {{id = 1}, {id = 1}, {id = 2}}
-- table.unify(t, function(v) return v.id end) -> {{id = 1}, {id = 2}}
function table.unify(t, f)
  if not f then f = function(v) return v end end
  local seen = {}
  for i = #t, 1, -1 do
    if not seen[f(t[i])] then seen[f(t[i])] = true
    else table.remove(t, i) end
  end
  return t
end


-- Applies function f to all table elements and replaces each element for the value returned by f
function table.map(t, f, ...)
  for k, v in ipairs(t) do t[k] = f(v, k, ...) end
  return t
end


-- Applies function f to all table elements resulting in a single output value
-- t = {1, 2, 3}
-- table.reduce(t, function(memo, v) return memo + v end) -> 6
function table.reduce(t, f, ...)
  local memo = t[1]
  for i = 2, #t do memo = f(memo, t[i], i, ...) end
  return memo
end


function table.reduce_range(t, i, j, f, ...)
  if i < 0 then i = #t + i + 1 end
  if j < 0 then j = #t + j + 1 end
  if i == j then return t[i] end
  local memo = t[i]
  for k = i+math.sign(j-i), j, math.sign(j-i) do memo = f(memo, t[k], k, ...) end
  return memo
end


-- Applies function f to all array elements without changing the array
function table.each(t, f, ...)
  for k, v in ipairs(t) do f(v, k, ...) end
  return t
end


function table.reverse_each(t, f, ...)
  for i = #t, 1, -1 do f(t[i], i, ...) end
  return t
end


-- Applies filter function f with selects all elements that pass the filter
-- t = {1, 2, 3, 4}
-- table.select(t, function(v) return v >= 3 end) -> {3, 4}
function table.select(t, f, ...)
  for i = #t, 1, -1 do
    if not f(t[i], i, ...) then table.remove(t, i) end
  end
  return t
end


-- Same as filter but reverse
function table.reject(t, f, ...)
  for i = #t, 1, -1 do
    if f(t[i], i, ...) then table.remove(t, i) end
  end
  return t
end


-- Check if table contains value v and return its index
-- If value v is a function instead then it checks according to the check performed by that function
-- t = {4, 3, 2, 1}
-- table.contains(t, 4) -> 1
-- t = {{id = 4}, {id = 3}, {id = 2}, {id = 1}}
-- table.contains(t, function(v) return v.id == 3 end) -> 2
function table.contains(t, v)
  if type(v) == "function" then
    for i, u in ipairs(t) do
      if v(u) then return i end
    end
  else
    for i, u in ipairs(t) do
      if u == v then return i end
    end
  end
end


function table.flatten(t, n)
  for k = 1, (n or 1) do
    for i = #t, 1, -1 do
      local v = t[i]
      if type(v) == "table" then
        self:insert(i, v:unpack())
        table.remove(t, i+#v)
      elseif type(v) == "table" then
        self:insert(i, unpack(v))
        table.remove(t, i+#v)
      end
    end
  end
  return t
end


local function copy(t)
  local out = {}
  for k, v in ipairs(t) do out[k] = v end
  return out
end


local function print_table(t)
  if type(t) == "table" then
    local str = "{"
    for k, v in ipairs(t) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      str = str .. "[" .. k .. "] = " .. print_table(v) .. ", "
    end
    return str:sub(1, -3) .. "}"
  else return tostring(t) end
end


function table.tostring(t)
  return print_table(t)
end


-- Gets the first n values from the array, same as take
function table.first(t, n)
  if n == 1 then return t[1] end
  local out = {}
  for i = 1, (n or 1) do table.push(out, t[i]) end
  return out
end


-- Gets the last n values from the array, same as drop
function table.last(t, n)
  if n == 1 then return t[#t] end
  local out = {}
  for i = #t-n, #t do table.push(out, t[i]) end
  return out
end


-- t = {"a", "b", "c", "d"}
-- table.reverse(t) -> {"d", "c", "b", "a"}
-- table.reverse(t, 2, 3) -> {"a", "c", "b", "d"}
-- table.reverse(t, 2, -1) -> {"a", "d", "c", "b"}
function table.reverse(t, i, j)
  if not i then i = 1 end
  if i < 0 then i = #t + i + 1 end
  if not j then j = #t end
  if j < 0 then j = #t + j + 1 end
  if i == j then return t end
  for k = 0, (j-i+1)/2-1, math.sign(j-i) do t[i+k], t[j-k] = t[j-k], t[i+k] end
  return t
end


function table.rotate(t, n)
  if not n then n = 1 end
  if n < 0 then n = #t + n end
  t = table.reverse(t, 1, #t)
  t = table.reverse(t, 1, #t-n)
  t = table.reverse(t, #t-n+1, #t)
  return t
end


function table.random(t)
  return t[love.math.random(1, #t)]
end


function table.shuffle(t)
  for i = #t, 2, -1 do
    local j = love.math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function string:left_back(p)
  for k = -1, -(#self), -1 do
    local s = self:sub(k)
    local i = s:find(p)
    if i then
      local out = s:sub(1, #self+k)
      return out ~= "" and out
    end
  end
end


function string:right_back(p)
  for i = -1, -(#self), -1 do
    local s = self:sub(i)
    local _, j = s:find(p)
    if j then
      local out = s:sub(j+1)
      return out ~= "" and out
    end
  end
end


function string:left(p)
  local i = self:find(p)
  if i then
    local out = self:sub(1, i-1)
    return out ~= "" and out
  end
end


function string:right(p)
  local _, j = self:find(p)
  if j then
    local out = self:sub(j+1)
    return out ~= "" and out
  end
end


function string:split(s)
  if not s then s = "%s" end
  local out = {}
  for str in self:gmatch("([^" .. s .. "]+)") do
    table.insert(out, str)
  end
  return out
end

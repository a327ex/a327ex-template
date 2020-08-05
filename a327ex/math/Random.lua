Random = Object:extend()


function Random:new(seed)
  seed = seed or os.time()
  self.generator = love.math.newRandomGenerator(seed)
end


function Random:bool(chance)
  if self.generator:random(1, 1000) < 10*(chance or 50) then
    return true
  end
end


function Random:float(min, max)
  min = min or 0
  max = max or 1
  return (min > max and (self.generator:random()*(min - max) + max)) or (self.generator:random()*(max - min) + min)
end


function Random:int(min, max)
  return self.generator:random(min or 0, max or 1)
end


function Random:table(t)
  return t[self.generator:random(1, #t)]
end


function Random:sign(chance)
  if self.generator:random(1, 1000) < 10*(chance or 50) then return 1
  else return -1 end
end


function Random:weighted_pick(...)
  local weights = {...}
  local total_weight = 0
  local pick = 0
  for _, weight in ipairs(weights) do total_weight = total_weight + weight end

  total_weight = self:float(0, total_weight)
  for i = 1, #weights do
    if total_weight < weights[i] then
      pick = i
      break
    end
    total_weight = total_weight - weights[i]
  end
  return pick
end


function Random:uid()
  local fn = function(x)
    local r = self:int(1, 16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
  end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

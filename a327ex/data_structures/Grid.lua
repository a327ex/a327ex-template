Grid = Object:extend()


function Grid:new(w, h, v)
  self.grid = {}
  self.w, self.h = w, h
  if type(v) ~= 'table' then
    for j = 1, h do
      for i = 1, w do
        self.grid[w*(j-1) + i] = v or 0
      end
    end
  else
    for j = 1, h do
      for i = 1, w do
        self.grid[w*(j-1) + i] = v[w*(j-1) + i]
      end
    end
  end
end


function Grid:is_outside_bounds(x, y)
  if x > self.w then return true end
  if x < 1 then return true end
  if y > self.h then return true end
  if y < 1 then return true end
end


function Grid:set(x, y, v)
  if not self:is_outside_bounds(x, y) then
    self.grid[self.w*(y-1) + x] = v
  end
end

function Grid:get(x, y)
  if not self:is_outside_bounds(x, y) then
    return self.grid[self.w*(y-1) + x]
  end
end


function Grid:clone()
  local new_grid = Grid(self.w, self.h, 0)
  new_grid.grid = table.copy(self.grid)
  return new_grid
end


function Grid:rotate_clockwise()
  local new_grid = Grid(self.h, self.w, 0)
  for i = 1, self.w do
    for j = 1, self.h do
      new_grid:set(j, i, self:get(i, j))
    end
  end

  for j = 1, new_grid.h do
    for k = 0, math.floor(new_grid.w/2) do
      local v1, v2 = new_grid:get(1+k, j), new_grid:get(new_grid.w-k, j)
      new_grid:set(1+k, j, v2)
      new_grid:set(new_grid.w-k, j, v1)
    end
  end

  return new_grid
end


function Grid:rotate_anticlockwise()
  local new_grid = Grid(self.h, self.w, 0)
  for i = 1, self.w do
    for j = 1, self.h do
      new_grid:set(j, i, self:get(i, j))
    end
  end

  for i = 1, new_grid.w do
    for k = 0, math.floor(new_grid.h/2) do
      local v1, v2 = new_grid:get(i, 1+k), new_grid:get(i, new_grid.h-k)
      new_grid:set(i, 1+k, v2)
      new_grid:set(i, new_grid.h-k, v1)
    end
  end

  return new_grid
end


function Grid:print()
  for j = 1, self.h do
    local str = '['
    for i = 1, self.w do
      str = str .. self:get(i, j) .. ', '
    end
    str = str:sub(1, -3) .. ']'
    print(str)
  end
end


function Grid:flood_fill(v)
  local islands = {}
  local marked_grid = Grid(self.w, self.h, 0)

  local flood_fill = function(i, j, color)
    local queue = {}
    table.insert(queue, {i, j})
    while #queue > 0 do
      local x, y = unpack(table.remove(queue, 1))
      marked_grid:set(x, y, color)
      table.insert(islands[color], {x, y})

      if self:get(x, y-1) == v and marked_grid:get(x, y-1) == 0 then table.insert(queue, {x, y-1}) end
      if self:get(x, y+1) == v and marked_grid:get(x, y+1) == 0 then table.insert(queue, {x, y+1}) end
      if self:get(x-1, y) == v and marked_grid:get(x-1, y) == 0 then table.insert(queue, {x-1, y}) end
      if self:get(x+1, y) == v and marked_grid:get(x+1, y) == 0 then table.insert(queue, {x+1, y}) end
    end
  end

  local color = 1
  islands[color] = {}
  for i = 1, self.w do
    for j = 1, self.h do
      if self:get(i, j) == v and marked_grid:get(i, j) == 0 then
        flood_fill(i, j, color)
        color = color + 1
        islands[color] = {}
      end
    end
  end

  islands[color] = nil
  return islands, marked_grid
end

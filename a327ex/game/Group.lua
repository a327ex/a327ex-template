Group = Object:extend()


function Group:new(camera)
  self.timer = Timer()
  self.camera = camera
  self.objects = {}
  self.objects.by_id = {}
  self.cells = {}
  self.cell_size = 128
  return self
end


function Group:update(dt)
  for _, object in ipairs(self.objects) do object:update(dt) end
  if self.world then self.world:update(dt) end

  self.cells = {}
  for _, object in ipairs(self.objects) do
    local cx, cy = math.floor(object.x/self.cell_size), math.floor(object.y/self.cell_size)
    if not self.cells[cx] then self.cells[cx] = {} end
    if not self.cells[cx][cy] then self.cells[cx][cy] = {} end
    table.insert(self.cells[cx][cy], object)
  end

  for i = #self.objects, 1, -1 do
    if self.objects[i].dead then
      if self.objects[i].destroy then self.objects[i]:destroy() end
      self.objects.by_id[self.objects[i].id] = nil
      table.remove(self.objects, i)
    end
  end
end


function Group:draw()
  if self.camera then
    self.camera:attach()
    for _, object in ipairs(self.objects) do object:draw() end
    self.camera:detach()
  else
    for _, object in ipairs(self.objects) do object:draw() end
  end
end


function Group:draw_range(i, j)
  if self.camera then
    self.camera:attach()
    for k = i, j do self.objects[k]:draw() end
    self.camera:detach()
  else
    for k = i, j do self.objects[k]:draw() end
  end
end


function Group:get_mouse_position()
  if self.camera then
    return self.camera.mouse.x, self.camera.mouse.y
  else
    local mx, my = love.mouse.getPosition()
    return mx/config.game_sx, my/config.game_sy
  end
end


function Group:destroy()
  for _, object in ipairs(self.objects) do object:destroy() end
  self.objects = {}
  self.objects.by_id = {}
  if self.world then
    self.world:destroy()
    self.world = nil
  end
  return self
end


function Group:add_object(object)
  object.group = self
  if not object.id then object.id = random:uid() end
  self.objects.by_id[object.id] = object
  table.insert(self.objects, object)
  return object
end


function Group:create_object(class, x, y, opts)
  local opts = opts or {}
  opts.group = self
  local object = _G[class](x, y, opts)
  if not object.id then object.id = random:uid() end
  self.objects.by_id[object.id] = object
  table.insert(self.objects, object)
  return object
end


function Group:get_object_by_id(id)
  return self.objects.by_id[id]
end


function Group:get_objects_in_rectangle(x, y, w, h)
  local out = {}
  local cx1, cy1 = math.floor((x-w)/self.cell_size), math.floor((y-h)/self.cell_size)
  local cx2, cy2 = math.floor((x+w)/self.cell_size), math.floor((y+h)/self.cell_size)
  for i = cx1, cx2 do
    for j = cy1, cy2 do
      local cx, cy = i, j
      if self.cells[cx] then
        local cell_objects = self.cells[cx][cy]
        if cell_objects then
          for _, object in ipairs(cell_objects) do
            if math.is_rectangle_in_rectangle(object.x, object.y, object.w, object.h, x, y, w, h) then
              table.insert(out, object)
            end
          end
        end
      end
    end
  end
  return out
end


function Group:get_closest_object(object, exclude_function)
  local min_distance, min_index = 100000, 0
  for i, o in ipairs(self.objects) do
    if not exclude_function(o) then
      local d = math.distance(o.x, o.y, object.x, object.y)
      if d < min_distance then
        min_distance = d
        min_index = i
      end
    end
  end
  return self.objects[min_index]
end


function Group:set_as_physics_world(meter, xg, yg)
  love.physics.setMeter(meter or 192)
  self.world = love.physics.newWorld(xg or 0, yg or 0)
  self.world:setCallbacks(
    function(fa, fb, c)
      local oa, ob = self:get_object_by_id(fa:getUserData()), self:get_object_by_id(fb:getUserData())
      if oa.on_collision_enter then oa:on_collision_enter(ob, c) end
      if ob.on_collision_enter then ob:on_collision_enter(oa, c) end
    end,
    function(fa, fb, c)
      local oa, ob = self:get_object_by_id(fa:getUserData()), self:get_object_by_id(fb:getUserData())
      if oa.on_collision_exit then oa:on_collision_exit(ob, c) end
      if ob.on_collision_exit then ob:on_collision_exit(oa, c) end
    end
  )
  return self
end


function Group:raycast(x1, y1, x2, y2)
  if not self.world then return end

  self.raycast_hitlist = {}
  self.world:rayCast(x1, y1, x2, y2, function(fixture, x, y, nx, ny, fraction)
    local hit = {}
    hit.fixture = fixture
    hit.x, hit.y = x, y
    hit.nx, hit.ny = nx, ny
    hit.fraction = fraction
    table.insert(self.raycast_hitlist, hit)
    return 1
  end)

  local hits = {}
  for _, hit in ipairs(self.raycast_hitlist) do
    local obj = self:get_object_by_id(hit.fixture:getUserData())
    hit.fixture = nil
    hit.other = obj
    table.insert(hits, hit)
  end

  return hits
end

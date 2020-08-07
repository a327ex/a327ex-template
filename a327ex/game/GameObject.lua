GameObject = Object:extend()


function GameObject:new_game_object(x, y, opts) 
  self.r = 0
  self.sx, self.sy = 1, 1
  for k, v in pairs(opts or {}) do self[k] = v end
  self.x, self.y = x, y
  self.id = random:uid()
  self.timer = Timer()
  return self
end


function GameObject:set_as_arena_mover()
  self.arena_movement = true
  self.v = Vector(0, 0)
  self.a = Vector(0, 0)
  self.p = Vector(0, 0)
  self.max_v = max_v or 1000
  self.max_a = max_a or 1000
  self.heading = Vector(0, 0)
  self.side = Vector(0, 0)
  return self
end


function GameObject:update_game_object(dt)
  self.timer:update(dt)
  self:update_position()

  if not self.body and self.arena_movement then
    self.v.x = self.v.x + self.a.x*dt
    self.v.y = self.v.y + self.a.y*dt
    self.x = self.x + self.v.x*dt
    self.y = self.y + self.v.y*dt
    if self.v:length_squared() > 0.00001 then
      self.heading:set(self.v:clone():normalize())
      self.side:set(self.heading:clone():perpendicular())
    end
    if self.angular_v then self.r = self.r + self.angular_v*dt end
    if self.angular_damping then self.angular_v = self.angular_v*self.angular_damping*dt end
    if self.damping then self.v:mul(self.damping*dt) end
  end
end


function GameObject:update_position()
  if self.body then self.x, self.y = self.body:getPosition() end
  return self
end


function GameObject:set_position(x, y)
  if self.body then self.body:setPosition(x, y) end
  return self:update_position()
end


function GameObject:get_position()
  self:update_position()
  if self.body then return self.body:getPosition()
  else return self.x, self.y end
end


function GameObject:set_bullet(v)
  if self.body then self.body:setBullet(v) end
  return self
end


function GameObject:set_fixed_rotation(v)
  self.fixed_rotation = v
  if self.body then self.body:setFixedRotation(v) end
  return self
end


function GameObject:set_velocity(vx, vy)
  if self.body then
    self.body:setLinearVelocity(vx, vy)
  else
    self.v.x = vx
    self.v.y = vy
  end
  return self
end


function GameObject:get_velocity()
  if self.body then return self.body:getLinearVelocity()
  else return self.v.x, self.v.y end
end


function GameObject:set_damping(v)
  if self.body then
    self.body:setLinearDamping(v)
  else
    self.damping = v
  end
  return self
end


function GameObject:set_angular_velocity(v)
  if self.body then
    self.body:setAngularVelocity(v)
  else
    self.angular_v = v
  end
  return self
end


function GameObject:set_angular_damping(v)
  if self.body then
    self.body:setAngularDamping(v)
  else
    self.angular_damping = v
  end
  return self
end


function GameObject:get_angle()
  if self.body then return self.body:getAngle()
  else return self.r end
end


function GameObject:set_angle(v)
  self.r = v
  if self.body then self.body:setAngle(v) end
  return self
end


function GameObject:set_restitution(v)
  if self.fixture then
    self.fixture:setRestitution(v)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setRestitution(v)
    end
  end
  return self
end


function GameObject:set_friction(v)
  if self.fixture then
    self.fixture:setFriction(v)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setFriction(v)
    end
  end
  return self
end


function GameObject:apply_impulse(fx, fy)
  self.body:applyLinearImpulse(fx, fy)
  return self
end


function GameObject:apply_force(fx, fy)
  if self.body then
    self.body:applyForce(fx, fy)
  else
    self.a.x = self.a.x + fx
    self.a.y = self.a.y + fy
  end
  return self
end


function GameObject:apply_torque(t)
  self.body:applyTorque(t)
  return self
end


function GameObject:set_mass(mass)
  self.body:setMass(mass)
  return self
end


function GameObject:set_collision_sensors(v)
  self.create_collision_sensors = v
  return self
end


function GameObject:set_category(...)
  if self.fixture then
    self.fixture:setCategory(...)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setCategory(...)
    end
  end
  return self
end


function GameObject:set_sensor_category(...)
  if self.sensor then
    self.sensor:setCategory(...)
  elseif self.sensors then
    for _, sensor in ipairs(self.sensors) do
      sensor:setCategory(...)
    end
  end
  return self
end


function GameObject:set_mask(...)
  if self.fixture then
    self.fixture:setMask(...)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setMask(...)
    end
  end
  return self
end


function GameObject:set_sensor_mask(...)
  if self.sensor then
    self.sensor:setMask(...)
  elseif self.sensors then
    for _, sensor in ipairs(self.sensors) do
      sensor:setMask(...)
    end
  end
  return self
end


function GameObject:set_sensor(v)
  if self.fixture then
    self.fixture:setSensor(v)
  elseif self.fixtures then
    for _, fixture in ipairs(self.fixtures) do
      fixture:setSensor(v)
    end
  end
  return self
end


function GameObject:set_gravity_scale(v)
  self.body:setGravityScale(v)
  return self
end


function GameObject:move_towards_object(object, speed, max_time)
  if max_time then speed = self:distance_to_point(object.x, object.y)/max_time end
  local r = self:angle_to_point(object.x, object.y)
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


function GameObject:move_towards_point(x, y, speed, max_time)
  if max_time then speed = self:distance_to_point(x, y)/max_time end
  local r = self:angle_to_point(x, y)
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


function GameObject:move_towards_mouse(speed, max_time)
  if max_time then speed = self:distance_to_mouse()/max_time end
  local r = self:angle_to_mouse()
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


function GameObject:move_along_angle(speed, r)
  self:set_velocity(speed*math.cos(r), speed*math.sin(r))
  return self
end


function GameObject:rotate_towards_object(object, lerp_value)
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_point(object.x, object.y)))
  return self
end


function GameObject:rotate_towards_point(x, y, lerp_value)
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_point(x, y)))
  return self
end


function GameObject:rotate_towards_mouse(lerp_value)
  self:set_angle(math.lerp_angle(lerp_value, self:get_angle(), self:angle_to_mouse()))
  return self
end


function GameObject:accelerate_towards_point(x, y, max_speed, deceleration, turn_coefficient)
  local tx, ty = x - self.x, y - self.y
  local d = math.length(tx, ty)
  if d > 0 then
    local speed = d/((deceleration or 1)*0.08)
    speed = math.min(speed, max_speed)
    local current_vx, current_vy = speed*tx/d, speed*ty/d
    local vx, vy = self:get_velocity()
    self:apply_force((current_vx - vx)*(turn_coefficient or 1), (current_vy - vy)*(turn_coefficient or 1))
  end
  return self
end


function GameObject:accelerate_towards_object(object, max_speed, deceleration, turn_coefficient)
  return self:accelerate_towards_point(object.x, object.y, max_speed, deceleration, turn_coefficient)
end


function GameObject:accelerate_towards_mouse(max_speed, deceleration, turn_coefficient)
  local mx, my = camera:get_mouse_position()
  return self:accelerate_towards_point(mx, my)
end


function GameObject:separate(rs, class_avoid_list)
  local fx, fy = 0, 0
  local objects = table.flatten(table.map(class_avoid_list, function(v) return self.group:get_objects_by_class(v) end))
  for _, object in ipairs(objects) do
    if object.id ~= self.id and math.distance(object.x, object.y, self.x, self.y) < 2*rs then
      local tx, ty = self.x - object.x, self.y - object.y
      local n = Vector(tx, ty):normalize()
      local l = n:length()
      fx = fx + rs*(n.x/l)
      fy = fy + rs*(n.y/l)
    end
  end
  self:apply_force(fx, fy)
  return self
end


function GameObject:angle_to_point(x, y)
  return math.atan2(y - self.y, x - self.x)
end


function GameObject:angle_from_point(x, y)
  return math.atan2(self.y - y, self.x - x)
end


function GameObject:angle_to_object(object)
  return self:angle_to_point(object.x, object.y)
end


function GameObject:angle_from_object(object)
  return self:angle_from_point(object.x, object.y)
end


function GameObject:angle_to_mouse()
  local mx, my = camera:get_mouse_position()
  return math.atan2(my - self.y, mx - self.x)
end


function GameObject:distance_to_point(x, y)
  return math.distance(self.x, self.y, x, y)
end


function GameObject:distance_to_mouse()
  local mx, my = camera:get_mouse_position()
  return math.distance(self.x, self.y, mx, my)
end


function GameObject:set_as_rectangle(w, h, body_type)
  self.w, self.h = w, h
  self.shape = "rectangle"
  self.body = love.physics.newBody(self.group.world, self.x, self.y, body_type or "dynamic")
  self.fixture = love.physics.newFixture(self.body, love.physics.newRectangleShape(self.w, self.h))
  self.fixture:setUserData(self.id)
  if self.create_collision_sensors then
    self.sensor = love.physics.newFixture(self.body, love.physics.newRectangleShape(self.w, self.h))
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


function GameObject:set_as_edge(x1, y1, x2, y2, body_type)
  self.x1, self.y1, self.x2, self.y2 = x1, y1, x2, y2
  self.shape = "edge"
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  self.fixture = love.physics.newFixture(self.body, love.physics.newEdgeShape(self.x1, self.y1, self.x2, self.y2))
  self.fixture:setUserData(self.id)
  if self.create_collision_sensors then
    self.sensor = love.physics.newFixture(self.body, love.physics.newEdgeShape(self.x1, self.y1, self.x2, self.y2))
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(self.id)
  end
  return self
end


function GameObject:set_as_chain(loop, vertices, body_type)
  self.loop = loop
  self.vertices = vertices
  self.w, self.h = math.get_polygon_size(self.vertices)
  self.shape = "chain"
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  self.fixture = love.physics.newFixture(self.body, love.physics.newChainShape(self.loop, self.vertices))
  self.fixture:setUserData(self.id)
  if self.create_collision_sensors then
    self.sensor = love.physics.newFixture(self.body, love.physics.newChainShape(self.loop, self.vertices))
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


function GameObject:set_as_polygon(vertices, body_type)
  self.vertices = vertices
  self.w, self.h = get_polygon_size(self.vertices)
  self.shape = "polygon"
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  self.body:setPosition(self.x, self.y)
  self.fixture = love.physics.newFixture(self.body, love.physics.newPolygonShape(self.vertices))
  self.fixture:setUserData(self.id)
  if self.create_collision_sensors then
    self.sensor = love.physics.newFixture(self.body, love.physics.newPolygonShape(self.vertices))
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


function GameObject:set_as_triangles(vertices, w, h, body_type)
  self.w, self.h = w, h
  self.vertices = vertices
  self.triangles = love.math.triangulate(self.vertices)
  self.shape = "triangles"
  self.body = love.physics.newBody(self.group.world, 0, 0, body_type or "dynamic")
  self.body:setPosition(self.x, self.y)
  self.fixtures = {}
  if self.create_collision_sensors then self.sensors = {} end
  for _, triangle in ipairs(self.triangles) do
    local fixture = love.physics.newFixture(self.body, love.physics.newPolygonShape(triangle))
    fixture:setUserData(self.id)
    table.insert(self.fixtures, fixture)
    if self.create_collision_sensors then
      local sensor = love.physics.newFixture(self.body, love.physics.newPolygonShape(triangle))
      sensor:setUserData(self.id)
      sensor:setSensor(true)
      table.insert(self.sensors, sensor)
    end
  end
  return self
end


function GameObject:set_as_circle(rs, body_type)
  self.rs = rs
  self.w, self.h = 2*rs, 2*rs
  self.shape = "circle"
  self.body = love.physics.newBody(self.group.world, self.x, self.y, body_type or "dynamic")
  self.fixture = love.physics.newFixture(self.body, love.physics.newCircleShape(self.rs))
  self.fixture:setUserData(self.id)
  if self.create_collision_sensors then
    self.sensor = love.physics.newFixture(self.body, love.physics.newCircleShape(self.rs))
    self.sensor:setUserData(self.id)
    self.sensor:setSensor(true)
  end
  return self
end


function GameObject:destroy()
  if self.body then
    if self.fixtures then for _, fixture in ipairs(self.fixtures) do fixture:destroy() end end
    if self.sensors then for _, sensor in ipairs(self.sensors) do sensor:destroy() end end
    if self.sensor then self.sensor:destroy(); self.sensor = nil end
    self.fixture:destroy()
    self.body:destroy()
    self.fixture, self.body = nil, nil
    if self.fixtures then self.fixtures = nil end
    if self.sensors then self.sensors = nil end
  end
end


function GameObject:draw_game_object(color)
  if self.body then
    if self.shape == "rectangle" then
      graphics.polygon({self.body:getWorldPoints(self.fixture:getShape():getPoints())}, color)
    elseif self.shape == "edge" then
      graphics.line(self.x + self.x1, self.y + self.y1, self.x + self.x2, self.y + self.y2, color)
    elseif self.shape == "chain" then
      local points = {self.body:getWorldPoints(self.fixture:getShape():getPoints())}
      for i = 1, #points-2, 2 do
        graphics.line(points[i], points[i+1], points[i+2], points[i+3])
        if self.loop and i == #points-2 then
          graphics.line(points[i], points[i+1], points[1], points[2])
        end
      end
    elseif self.shape == "polygon" then
      graphics.polygon({self.body:getWorldPoints(self.fixture:getShape():getPoints())}, color)
    elseif self.shape == "circle" then
      graphics.circle(self.x, self.y, self.rs, color)
    elseif self.shape == "triangles" then
      for _, fixture in ipairs(self.fixtures) do
        local points = {self.body:getWorldPoints(self.fixture:getShape():getPoints())}
        for i = 1, #points-2, 2 do
          graphics.line(points[i], points[i+1], points[i+2], points[i+3], color)
          if self.loop and i == #points-2 then
            graphics.line(points[i], points[i+1], points[1], points[2], color)
          end
        end
      end
    end
  end
end

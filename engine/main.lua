require 'engine'

function init()
  black = Color(0, 0, 0, 1)
  white = Color(1, 1, 1, 1)

  bg1 = Color('#303030')
  bg2 = Color('#272727')
  fg1 = Color('#dadada')
  fg2 = Color('#b0a89f')
  error1 = Color('#7a4d4e')
  river = Color('#7badc4')
  yellow = Color('#facf00')
  orange = Color('#f07021')
  blue = Color('#019bd6')
  green1 = Color('#8bbf40')
  green2 = Color('#017866')
  red = Color('#e91d39')
  purple = Color('#8e559e')

  pop1 = Sound('260614__kwahmah-02__pop.wav')
  print(pop1)

  -- graphics.debug_draw = true
  graphics.set_background_color(bg1)
  graphics.set_color(fg1)
  m5x7 = Font('m5x7', 16)

  game_canvas = Canvas(gw, gh)
  shadow_canvas = Canvas(gw, gh)
  shadow_shader = Shader(nil, 'shadow.frag')

  main = Group(camera):set_as_physics_world(32, 0, 0, {'player', 'projectile', 'enemy'})
  effects = Group(camera)
  ui = Group()

  enemies = {Seeker}

  main:disable_collision_between('player', 'projectile')
  main:enable_trigger_between('player', 'projectile')

  ax1, ay1, ax2, ay2 = gw/2 - gw*0.75*0.5, gh/2 - gh*0.9*0.5, gw/2 + gw*0.75*0.5, gh/2 + gh*0.9*0.5
  Wall(main, 0, 0, {vertices = {-40, -40, ax1, -40, ax1, gh + 40, -40, gh + 40}})
  Wall(main, 0, 0, {vertices = {ax1, -40, ax2, -40, ax2, ay1, ax1, ay1}})
  Wall(main, 0, 0, {vertices = {ax2, -40, gw + 40, -40, gw + 40, gh + 40, ax2, gh + 40}})
  Wall(main, 0, 0, {vertices = {ax1, ay2, ax2, ay2, ax2, gh + 40, ax1, gh + 40}})
  player = Player(main, gw/2, gh/2)
end


function update(dt)
  main:update(dt)
  effects:update(dt)
  ui:update(dt)

  if input.k.pressed then
    Seeker(main, gw/2, gh/2)
  end
end


function draw()
  game_canvas:draw_to(function()
    main:draw()
    effects:draw()
    ui:draw()
  end)

  shadow_canvas:draw_to(function()
    graphics.set_color(white)
    shadow_shader:set()
    game_canvas:draw2(0, 0, 0, 1, 1)
    shadow_shader:unset()
  end)

  shadow_canvas:draw(6, 6, 0, sx, sy)
  game_canvas:draw(0, 0, 0, sx, sy)
end




Player = Object:extend()
Player:implement(GameObject)
function Player:new(group, x, y, opts)
  self:new_game_object(group, x, y, opts)
  self:set_as_rectangle(8, 8, 'dynamic', 'player')

  self.max_v = 100
  self.v = self.max_v
  self.visual_r = 0
  self.movement_spring = Spring(1)
  self.shoot_spring = Spring(1)

  self.primary_cd = 0.2
  self.primary_timer = 0
  self.can_use_primary = true
end


function Player:update(dt)
  self:update_game_object(dt)
  self.movement_spring:update(dt)
  self.shoot_spring:update(dt)

  -- Movement
  local move_left, move_right, move_up, move_down = input.move_left.down, input.move_right.down, input.move_up.down, input.move_down.down
  local move_r
  local vx, vy = self:get_velocity()
  if not self.dashing then
    if move_left then move_r = math.pi end
    if move_right then move_r = 0 end
    if move_up then move_r = -math.pi/2 end
    if move_down then move_r = math.pi/2 end
    if move_left and move_up then move_r = -3*math.pi/4 end
    if move_left and move_down then move_r = 3*math.pi/4 end
    if move_right and move_up then move_r = -math.pi/4 end
    if move_right and move_down then move_r = math.pi/4 end
    if move_left or move_right or move_up or move_down then self.moving = true else self.moving = false end

    if input.move_right.pressed then self.timer:tween(0.2, self, {visual_r = self.visual_r + math.pi}, math.linear, nil, 'visual_r_movement_start') end
    if input.move_left.pressed then self.timer:tween(0.2, self, {visual_r = self.visual_r - math.pi}, math.linear, nil, 'visual_r_movement_start') end
    if input.move_right.pressed or input.move_left.pressed then
      self.timer:tween(0.05, self, {sx = 0.8, sy = 0.8}, math.linear, function()
        self.timer:tween(0.6, self, {sx = 1, sy = 1}, math.linear, nil, 'scale_movement_start_2')
      end, 'scale_movement_start_1')
    end
    if not self.moving and self.previous_moving then
      self.movement_spring:pull(0.35)
    end
  end
  -- dash update <-
  if move_r then vx, vy = self.v*math.cos(move_r), self.v*math.sin(move_r) end
  if not move_left and not move_right then vx = vx*0.5 end
  if not move_up and not move_down then vy = vy*0.5 end
  self:set_velocity(vx, vy)
  self.r = self:angle_to_mouse()
  self.previous_moving = self.moving

  local hd = math.remap(math.abs(self.x - gw/2), 0, 180, 1, 0) -- camera dampener from center
  local vd = math.remap(math.abs(self.y - gh/2), 0, 120 , 1, 0)
  camera.x = camera.x + math.remap(vx, -100, 100, -24*hd, 24*hd)*dt
  camera.y = camera.y + math.remap(vy, -100, 100, -8*vd, 8*vd)*dt
  if move_right then camera.r = math.lerp_angle(0.1, camera.r, math.pi/256)
  elseif move_left then camera.r = math.lerp_angle(0.1, camera.r, -math.pi/256)
  elseif move_down then camera.r = math.lerp_angle(0.1, camera.r, math.pi/256)
  elseif move_up then camera.r = math.lerp_angle(0.1, camera.r, -math.pi/256)
  else camera.r = math.lerp_angle(0.05, camera.r, 0) end

  -- Shooting
  self.primary_timer = self.primary_timer + dt
  if self.primary_timer > self.primary_cd then
    self.can_use_primary = true
    self.primary_timer = 0
  end

  if input.primary.down and self.can_use_primary then
    self.can_use_primary = false
    self.primary_timer = 0

    pop1:play()
    camera:spring_shake(2, self.r)
    self.shoot_spring:pull(0.25)
    HitCircle(effects, self.x + self.shape.w*math.cos(self.r), self.y + self.shape.w*math.sin(self.r), {rs = 6})
    Projectile(main, self.x + 2*self.shape.w*math.cos(self.r), self.y + 2*self.shape.w*math.sin(self.r), {v = 250, r = self.r, color = yellow})
  end
end


function Player:draw()
  graphics.push(self.x, self.y, self.r + self.visual_r, self.sx*self.movement_spring.x*self.shoot_spring.x, self.sy*self.movement_spring.x*self.shoot_spring.x)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, river)
  graphics.pop()
end




Projectile = Object:extend()
Projectile:implement(GameObject)
function Projectile:new(group, x, y, opts)
  self:new_game_object(group, x, y, opts)
  self:set_as_rectangle(10, 4, 'dynamic', 'projectile')
  self:apply_impulse(self.v*math.cos(self.r), self.v*math.sin(self.r))
  self.color = self.color or fg1
end


function Projectile:update(dt)
  self:update_game_object(dt)
  self:move_along_angle(self.v, self.r)
end


function Projectile:draw()
  graphics.push(self.x, self.y, self.r)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 2, 2, self.color)
  graphics.pop()
end


function Projectile:die(n, x, y, r)
  self.dead = true
  for i = 1, n do HitParticle(effects, x, y, {r = (r and random:float(r - math.pi/2.5, r + math.pi/2.5)), color = self.color}) end
  HitCircle(effects, x, y):scale_down()
end


function Projectile:on_collision_enter(other, contact)
  if other:is(Wall) then
    local nx, ny = contact:getNormal()
    local x, y = contact:getPositions()
    local r = 0
    if nx == 0 and ny == -1 then r = -math.pi/2
    elseif nx == 0 and ny == 1 then r = math.pi/2
    elseif nx == -1 and ny == 0 then r = math.pi
    else r = 0 end
    self:die(random:int(2, 3), x, y, r)

  elseif table.any(enemies, function(v) return other:is(v) end) then
    local x, y = contact:getPositions()
    self:die(random:int(2, 3), x, y)
    other:hit(self)
  end
end




Seeker = Object:extend()
Seeker:implement(GameObject)
function Seeker:new(group, x, y, opts)
  self:new_game_object(group, x, y, opts)
  self:set_as_rectangle(14, 6, 'dynamic', 'enemy')
  self:set_fixed_rotation(true)
  self.color = red
  self.hit_spring = Spring(1)

  self.max_v = 50
  self.v = self.max_v
  self.hp = 25
end


function Seeker:update(dt)
  self:update_game_object(dt)
  self.hit_spring:update(dt)
  self:accelerate_towards_object(player, self.v)
  self:rotate_towards_object(player, 0.2)
end


function Seeker:draw()
  local color = self.color
  if self.hit_flash then color = fg1 end
  graphics.push(self.x, self.y, self.r, self.hit_spring.x, self.hit_spring.y)
    graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, color)
  graphics.pop()
end


function Seeker:hit(other)
  if self.dead then return end

  if other:is(Projectile) then
    self.hit_spring:pull(0.5)
    self.hit_flash = true
    self.timer:after(0.15, function() self.hit_flash = false end, 'hit_flash')

    self.hp = self.hp - (other.damage or 5)
    if self.hp <= 0 then
      self.dead = true
      HitCircle(effects, self.x, self.y, {rs = 0.85*self.shape.w}):scale_down(0.4):change_color(0.3, red)
      for i = 1, random:int(4, 6) do HitParticle(effects, self.x, self.y, {color = self.color, m = 1.25}) end
    end
  end
end




HitCircle = Object:extend()
HitCircle:implement(GameObject)
function HitCircle:new(group, x, y, opts)
  self:new_game_object(group, x, y, opts)
  self.rs = self.rs or 8
  self.color = self.color or fg1
  self.duration = self.duration or 0.05
  self.timer:after(self.duration, function() self.dead = true end, 'die')
end


function HitCircle:update(dt)
  self:update_game_object(dt)
end


function HitCircle:draw()
  graphics.circle(self.x, self.y, self.rs, self.color)
end


function HitCircle:scale_down(duration)
  self.duration = duration or 0.2
  self.timer:cancel('die')
  self.timer:tween(self.duration, self, {rs = 0}, math.cubic_in_out, function() self.dead = true end)
  return self
end


function HitCircle:change_color(delay_multiplier, target_color)
  self.timer:after((delay_multiplier or 0.5)*self.duration, function() self.color = target_color end)
  return self
end




HitParticle = Object:extend()
HitParticle:implement(GameObject)
function HitParticle:new(group, x, y, opts)
  self:new_game_object(group, x, y, opts)
  self.v = (self.m or 1)*(self.v or random:float(50, 150))
  self.duration = (self.m or 1)*(self.duration or random:float(0.2, 0.6))
  self.r = opts.r or random:float(0, 2*math.pi)
  self.w = (self.m or 1)*(self.w or random:float(3.5, 7))
  self.h = self.w/2
  self.color = self.color or fg1
  self.timer:tween(self.duration, self, {w = 2, h = 2, v = 0}, math.cubic_in_out, function() self.dead = true end)
end


function HitParticle:update(dt)
  self:update_game_object(dt)
  self.x = self.x + self.v*math.cos(self.r)*dt
  self.y = self.y + self.v*math.sin(self.r)*dt
end


function HitParticle:draw()
  graphics.push(self.x, self.y, self.r)
    graphics.rectangle(self.x, self.y, self.w, self.h, 2, 2, self.color)
  graphics.pop()
end




Wall = Object:extend()
Wall:implement(GameObject)
function Wall:new(group, x, y, opts)
  self:new_game_object(group, x, y, opts)
  self:set_as_chain(true, self.vertices, 'static', 'solid')
end


function Wall:update(dt)
  self:update_game_object(dt)
end


function Wall:draw()
  self.shape:draw(bg2)
end




function love.run()
  return engine_run({
    game_name = 'Upgrade Arena',
    game_width = 480,
    game_height = 270,
    window_width = 480*3,
    window_height = 270*3,
    line_style = 'rough',
    default_filter = 'nearest',
    init = init,
    update = update,
    draw = draw,
    input = {
      ['move_left'] = {'a'},
      ['move_right'] = {'d'},
      ['move_up'] = {'w'},
      ['move_down'] = {'s'},
      ['primary'] = {'m1'},
    }
  })
end

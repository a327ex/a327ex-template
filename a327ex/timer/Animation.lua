Animation = Object:extend()


function Animation:new(x, y, delay, name)
  self.x, self.y = x, y
  self.delay = delay
  self.name = name
  self.animation = Sequence(self.delay, graphics.get_animation_size(self.name), "once", {[0] = function() self.dead = true end})
  self.r, self.sx, self.sy = 0, 1, 1
end


function Animation:update(dt)
  self.animation:update(dt)
end


function Animation:draw()
  graphics.draw_animation(self.name, self.animation.frame, self.x, self.y, self.r, self.sx, self.sy)
end



Sequence = Object:extend()


function Sequence:new(delay, frames, loop_mode, actions)
  self.delay = delay
  self.frames = frames
  self.loop_mode = loop_mode or "once"
  self.actions = actions
  self.timer = 0
  self.frame = 1
  self.direction = 1
end


function Sequence:update(dt)
  if self.dead then return end

  self.timer = self.timer + dt
  local delay = self.delay
  if type(self.delay) == "table" then delay = self.delay[self.frame] end

  if self.timer > delay then
    self.timer = 0
    self.frame = self.frame + self.direction
    if self.frame > self.frames or self.frame < 1 then
      if self.loop_mode == "once" then
        self.frame = self.frames
        self.dead = true
      elseif self.loop_mode == "loop" then
        self.frame = 1
      elseif self.loop_mode == "bounce" then
        self.direction = -self.direction
        self.frame = self.frame + 2*self.direction
      end
      if self.actions and self.actions[0] then self.actions[0]() end
    end
    if self.actions and self.actions[self.frame] then self.actions[self.frame]() end
  end
end



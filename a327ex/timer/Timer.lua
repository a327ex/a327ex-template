Timer = Object:extend()


function Timer:new()
  self.timers = {}
end


function Timer:after(delay, action, tag)
  local tag = tag or random:uid()
  self.timers[tag] = {type = "after", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action}
end


function Timer:every(delay, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or random:uid()
  self.timers[tag] = {type = "every", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, times = times, after = after}
end


function Timer:every_immediate(delay, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or random:uid()
  self.timers[tag] = {type = "every", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, times = times, after = after}
  action()
end


function Timer:during(delay, action, after, tag)
  local after = after or function() end
  local tag = tag or random:uid()
  self.timers[tag] = {type = "during", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, after = after}
end


function Timer:tween(delay, target, source, method, after, tag)
  local method = method or math.linear
  local after = after or function() end
  local tag = tag or random:uid()
  local initial_values = {}
  for k, _ in pairs(source) do initial_values[k] = target[k] end
  self.timers[tag] = {type = "tween", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), target = target, initial_values = initial_values, source = source, method = method, after = after}
end


function Timer:cancel(tag)
  self.timers[tag] = nil
end


function Timer:set_every_delay(tag, delay)
  self.timers[tag].delay = self:resolve_delay(delay)
end


function Timer:get_time()
  return love.timer.getTime()
end


function Timer:get_delay(tag)
  return self.timers[tag].delay
end


function Timer:resolve_delay(delay)
  if type(delay) == "table" then
    return random:float(delay[1], delay[2])
  else
    return delay
  end
end


function Timer:update(dt)
  for tag, timer in pairs(self.timers) do
    timer.timer = timer.timer + dt

    if timer.type == "after" then
      if timer.timer > timer.delay then
        timer.action()
        self.timers[tag] = nil
      end

    elseif timer.type == "every" then
      if timer.timer > timer.delay then
        timer.action()
        timer.timer = timer.timer - timer.delay
        timer.delay = self:resolve_delay(timer.unresolved_delay)
        if timer.times > 0 then
          timer.times = timer.times - 1
          if timer.times <= 0 then
            timer.after()
            self.timers[tag] = nil
          end
        end
      end

    elseif timer.type == "during" then
      timer.action()
      if timer.timer > timer.delay then
        self.timers[tag] = nil
      end

    elseif timer.type == "tween" then
      local t = timer.method(timer.timer/timer.delay)
      for k, v in pairs(timer.source) do
        timer.target[k] = math.lerp(t, timer.initial_values[k], v)
      end
      if timer.timer > timer.delay then
        timer.after()
        self.timers[tag] = nil
      end
    end
  end
end

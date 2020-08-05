Canvas = Object:extend()


function Canvas:new(w, h)
  self.w, self.h = w, h
  self.canvas = love.graphics.newCanvas(self.w, self.h, {msaa = msaa, mipmaps = "auto"})
end


function Canvas:draw(x, y, r, sx, sy, ox, oy)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.draw(self.canvas, x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  love.graphics.setBlendMode("alpha")
end


function Canvas:draw_to(action)
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  action()
  love.graphics.setCanvas()
end


function Canvas:set()
  love.graphics.setCanvas(self.canvas)
end


function Canvas:unset()
  love.graphics.setCanvas()
end


function Canvas:clear()
  love.graphics.clear()
end

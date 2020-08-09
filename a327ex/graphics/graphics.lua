graphics = {}
graphics.animations = {}
graphics.tilesets = {}
graphics.images = {}
graphics.fonts = {}
graphics.shaders = {}
graphics.text_tags = {}
graphics.debug_queries = {}


function graphics.set_text_tag(tag, actions)
  graphics.text_tags[tag] = actions
end


function graphics.new_animation(name, w, h, frames)
  local source = love.graphics.newImage("assets/images/" .. name .. ".png")
  local sw, sh = source:getWidth(), source:getHeight()
  local i = 1
  if frames then
    graphics.animations[name] = {source = source, w = sw, h = sh, frames = #frames}
    for _, frame in ipairs(frames) do
      graphics.animations[name][i] = {quad = love.graphics.newQuad((frame-1)*w, 0, w, h, sw, sh), w = w, h = h}
      i = i + 1
    end
  else
    graphics.animations[name] = {source = source, w = sw, h = sh, frames = sw/w}
    for x = 0, sw, w do
      graphics.animations[name][i] = {quad = love.graphics.newQuad(x, 0, w, h, sw, sh), w = w, h = h}
      i = i + 1
    end
  end
end


function graphics.draw_animation(name, frame, x, y, r, sx, sy, ox, oy)
  local animation_frame = graphics.animations[name][frame]
  love.graphics.draw(graphics.animations[name].source, animation_frame.quad, x, y, r or 0, sx or 1, sy or sx or 1, animation_frame.w/2 + (ox or 0), animation_frame.h/2 + (oy or 0))
end


function graphics.new_animation_from_spritesheet(name, w, h, frames, sheet_name)
  local source = love.graphics.newImage("assets/images/" .. sheet_name .. ".png")
  local sw, sh = source:getWidth(), source:getHeight()
  graphics.animations[name] = {source = source, w = sw, h = sh, frames = #frames}
  for i, frame in ipairs(frames) do
    graphics.animations[name][i] = {quad = love.graphics.newQuad((frame[1]-1)*w, (frame[2]-1)*h, w, h, sw, sh), w = w, h = h}
  end
end


function graphics.new_tileset(name, tile_w, tile_h)
  local source = love.graphics.newImage("assets/images/" .. name .. ".png")
  local sw, sh = source:getWidth(), source:getHeight()

  graphics.tilesets[name] = {image = source, w = sw, h = shi, grid = Grid(math.floor(sw/tile_w), math.floor(sh/tile_h), 0)}
  for i = 1, math.floor(sw/tile_w) do
    for j = 1, math.floor(sh/tile_h) do
      graphics.tilesets[name].grid:set(i, j, love.graphics.newQuad((i-1)*tile_w, (j-1)*tile_h, tile_w, tile_h, sw, sh))
    end
  end
end


function graphics.draw_tile(name, i, j, x, y, r, sx, sy, ox, oy)
  love.graphics.draw(graphics.tilesets[name].image, graphics.tilesets[name].grid:get(i, j), x, y, r or 0, sx or 1, sy or sx or 1, ox or 0, oy or 0)
end


function graphics.get_animation_frames(name)
  return graphics.animations[name].frames
end


function graphics.draw_image(name, x, y, r, sx, sy, ox, oy)
  love.graphics.draw(graphics.images[name].image, x, y, r or 0, sx or 1, sy or sx or 1, graphics.images[name].w/2 + (ox or 0), graphics.images[name].h/2 + (oy or 0))
end


function graphics.get_image(name)
  return graphics.images[name]
end


function graphics.get_image_width(name)
  return graphics.images[name].w
end


function graphics.get_image_height(name)
  return graphics.images[name].h
end


function graphics.get_image_size(name)
  return graphics.images[name].w, graphics.images[name].h
end


function graphics.push(x, y, r, sx, sy)
  love.graphics.push()
  love.graphics.translate(x or 0, y or 0)
  love.graphics.scale(sx or 1, sy or sx or 1)
  love.graphics.rotate(r or 0)
  love.graphics.translate(-x or 0, -y or 0)
end


function graphics.pop()
  love.graphics.pop()
end


function graphics.print(text, x, y, r, sx, sy, ox, oy)
  love.graphics.print(text, x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
end


function graphics.update(dt)
  for i = #self.debug_queries, 1, -1 do
    local query = self.debug_queries[i]
    query.frames = query.frames - 1
    if query.frames <= 0 then table.remove(self.debug_queries, i) end
  end
end


function graphics.add_polygon_debug_query(vertices, frames)
  table.insert(self.debug_queries, {vertices = vertices, frames = frames, type = "polygon"})
end


function graphics.draw_debug_queries()
  for _, query in ipairs(self.debug_queries) do
    if query.type == "polygon" then
      self:polygon(query.vertices)
    end
  end
end


function graphics.new_text(font, font_size)
  return love.graphics.newText(assets.fonts[font][font_size])
end


function graphics.new_gradient_mesh(direction, ...)
  local colors = {...}
  local mesh_data = {}

  if direction == "horizontal" then
    for i = 1, #colors do
      local color = colors[i]
      local x = (i-1)/(#colors-1)
      table.insert(mesh_data, {x, 1, x, 1, color[1], color[2], color[3], color[4] or 1})
      table.insert(mesh_data, {x, 0, x, 0, color[1], color[2], color[3], color[4] or 1})
    end
  elseif direction == "vertical" then
    for i = 1, #colors do
      local y = (i-1)/(#colors-1)
      table.insert(mesh_data, {1, y, 1, y, color[1], color[2], color[3], color[4] or 1})
      table.insert(mesh_data, {0, y, 0, y, color[1], color[2], color[3], color[4] or 1})
    end
  end

  return love.graphics.newMesh(mesh_data, "strip", "static")
end


function graphics.get_animation_size(name)
  return graphics.animations[name].frames
end


function graphics.shape(shape, color, line_width, ...)
  local r, g, b, a = love.graphics.getColor()
  if not color and not line_width then love.graphics[shape]("line", ...)
  elseif color and not line_width then
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics[shape]("fill", ...)
  else
    if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
    love.graphics.setLineWidth(line_width)
    love.graphics[shape]("line", ...)
    love.graphics.setLineWidth(1)
  end
  love.graphics.setColor(r, g, b, a)
end


function graphics.rectangle(x, y, w, h, rx, ry, color, line_width)
  graphics.shape("rectangle", color, line_width, x - w/2, y - h/2, w, h, rx, ry)
end


function graphics.dashed_rectangle(x, y, w, h, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x - w/2, y - h/2, x + w/2, y - h/2, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x - w/2, y - h/2, x - w/2, y + h/2, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x - w/2, y + h/2, x + w/2, y + h/2, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x + w/2, y - h/2, x + w/2, y + h/2, dash_size, gap_size, color, line_width)
end


function graphics.triangle(x, y, w, h, color, line_width)
  local x1, y1 = x + h/2, y
  local x2, y2 = x - h/2, y - w/2
  local x3, y3 = x - h/2, y + w/2
  graphics.polygon({x1, y1, x2, y2, x3, y3}, color, line_width)
end


function graphics.triangle_equilateral(x, y, w, color, line_width)
  local h = math.sqrt(math.pow(w, 2) - math.pow(w/2, 2))
  graphics.triangle(x, y, w, h, color, line_width)
end


function graphics.circle(x, y, r, color, line_width)
  graphics.shape("circle", color, line_width, x, y, r)
end


function graphics.polygon(vertices, color, line_width)
  graphics.shape("polygon", color, line_width, vertices)
end


function graphics.line(x1, y1, x2, y2, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  love.graphics.line(x1, y1, x2, y2)
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(1)
end


function graphics.rounded_line(x1, y1, x2, y2, color, line_width)
  love.graphics.push()
  love.graphics.translate(x1, y1)
  love.graphics.rotate(math.angle(x1, y1, x2, y2))
  love.graphics.translate(-x1, -y1)
  graphics.rectangle(x1, y1 - line_width/4, math.length(x2-x1, y2-y1), line_width/2, line_width/4, line_width/4, color)
  love.graphics.pop()
end


function graphics.dashed_line(x1, y1, x2, y2, dash_size, gap_size, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  local dx, dy = x2-x1, y2-y1
  local an, st = math.atan2(dy, dx), dash_size + gap_size
  local len = math.sqrt(dx*dx + dy*dy)
  local nm = (len-dash_size)/st
  love.graphics.push()
    love.graphics.translate(x1, y1)
    love.graphics.rotate(an)
    for i = 0, nm do love.graphics.line(i*st, 0, i*st + dash_size, 0) end
    love.graphics.line(nm*st, 0, nm*st + dash_size, 0)
  love.graphics.pop()
end


function graphics.dashed_rounded_line(x1, y1, x2, y2, dash_size, gap_size, color, line_width)
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  local dx, dy = x2-x1, y2-y1
  local an, st = math.atan2(dy, dx), dash_size + gap_size
  local len = math.sqrt(dx*dx + dy*dy)
  local nm = (len-dash_size)/st
  love.graphics.push()
    love.graphics.translate(x1, y1)
    love.graphics.rotate(an)
    for i = 0, nm do
      love.graphics.push()
      love.graphics.translate(i*st, 0)
      love.graphics.rotate(math.angle(i*st, 0, i*st + dash_size, 0))
      love.graphics.translate(-i*st, -0)
      graphics.shape("rectangle", color, nil, i*st, 0, math.length((i*st + dash_size)-(i*st), 0-0), line_width/2, line_width/4, line_width/4)
      love.graphics.pop()
    end
    love.graphics.push()
    love.graphics.translate(nm*st, 0)
    love.graphics.rotate(math.angle(nm*st, 0, nm*st + dash_size, 0))
    love.graphics.translate(-nm*st, -0)
    graphics.shape("rectangle", color, nil, nm*st, 0, math.length((nm*st + dash_size)-(nm*st), 0-0), line_width/2, line_width/4, line_width/4)
    love.graphics.pop()
  love.graphics.pop()
end


function graphics.ellipse(x, y, rx, ry, color, line_width)
  graphics.shape("ellipse", color, line_width, x, y, rx, ry)
end


function graphics.set_shader(shader)
  love.graphics.setShader(graphics.shaders[shader])
end


function graphics.set_color(color)
  love.graphics.setColor(color.r, color.g, color.b, color.a)
end


function graphics.set_background_color(color)
  love.graphics.setBackgroundColor(color.r, color.g, color.b, color.a)
end


function graphics.set_line_width(line_width)
  love.graphics.setLineWidth(line_width)
end


function graphics.set_font(font_name, size)
  love.graphics.setFont(graphics.fonts[font_name][size])
end


function graphics.set_line_style(style)
  love.graphics.setLineStyle(style)
end


function graphics.set_default_filter(min, max)
  love.graphics.setDefaultFilter(min, max)
end


function graphics.set_mouse_visible(value)
  love.mouse.setVisible(value)
end



Text = Object:extend()


function Text:new(x, y, tagged_text)
  self.timer = Timer()
  self.x, self.y = x, y
  self.font = font or love.graphics.getFont()
  self.tagged_text = tagged_text
  self.raw_text, self.characters = self:parse(tagged_text)
  self.line_height_multiplier = 1
  self.line_count = 1
  self.tags_to_actions = {}
  self:format_text()
  for i, c in ipairs(self.characters) do
    for k, v in pairs(graphics.text_tags) do
      for _, tag in ipairs(c.tags) do
        if tag == k then
          if v.init then v.init(c, i, self) end
        end
      end
    end
  end
  return self
end


function Text:update(dt)
  self.timer:update(dt)
  self:format_text()
  for i, c in ipairs(self.characters) do
    for k, v in pairs(graphics.text_tags) do
      for _, tag in ipairs(c.tags) do
        if tag == k then
          if v.update then v.update(c, dt, i, self) end
        end
      end
    end
  end
end


function Text:draw()
  for i, c in ipairs(self.characters) do
    for k, v in pairs(graphics.text_tags) do
      for _, tag in ipairs(c.tags) do
        if tag == k then
          if v.draw then v.draw(c, i, self) end
        end
      end
    end
    graphics.print(c.character, self.x + c.x, self.y + c.y, c.r or 0, c.sx or 1, c.sy or c.sx or 1, c.ox or 0, c.oy or 0)
    graphics.set_color(white)
  end
end


function Text:set_tag(tag, actions)
  self.tags_to_actions[tag] = actions
end


function Text:format_text()
  if self.wrap_width then self.w = self.wrap_width
  else self.w = self.font:getWidth(self.raw_text) end

  local x = 0
  local line, col = 1, 1
  local last_space_index = 1
  for i, c in ipairs(self.characters) do
    if c.character == " " then
      c.line = line
      c.col = col
      c.x = x
      c.y = self.font:getHeight()*(line-1)
      last_space_index = i
      col = col + 1
      x = x + self.font:getWidth(c.character)
    elseif c.character == "\n" then
      c.line = line
      c.col = col
      c.x = x
      c.y = self.font:getHeight()*(line-1)
      line = line + 1
      col = 1
      x = 0
    else
      if x + self.font:getWidth(c.character) > self.w then
        line = line + 1
        col = 1
        x = 0
        self.characters[last_space_index].character = "\n"
        for j = last_space_index+1, i do
          self.characters[j].line = line
          self.characters[j].col = col
          self.characters[j].x = x
          self.characters[j].y = self.font:getHeight()*(line-1)
          x = x + self.font:getWidth(self.characters[j].character)
          col = col + 1
        end
        c.line = line
        c.col = col
        c.x = x
        c.y = self.font:getHeight()*(line-1)
        x = x + self.font:getWidth(c.character)
      else
        c.line = line
        c.col = col
        c.x = x
        c.y = self.font:getHeight()*(line-1)
        col = col + 1
        x = x + self.font:getWidth(c.character)
      end
    end
  end
  self.h = self.font:getHeight()*line*self.line_height_multiplier
  self.line_count = line

  if self.justify == "right" then
    for i = 1, self.line_count do
      local characters = self:get_characters_in_line(i)
      local line_width = 0
      for _, c in ipairs(characters) do line_width = line_width + self.font:getWidth(c.character) end
      local left_over_width = self.w - line_width
      for _, c in ipairs(characters) do c.x = c.x + left_over_width end
    end
  elseif self.justify == "center" then
    for i = 1, self.line_count do
      local characters = self:get_characters_in_line(i)
      local line_width = 0
      for _, c in ipairs(characters) do line_width = line_width + self.font:getWidth(c.character) end
      local left_over_width = self.w - line_width
      local spaces_count = 0
      for _, c in ipairs(characters) do
        if c.character == " " then
          spaces_count = spaces_count + 1
        end
      end
      local added_width_to_each_space = math.floor(left_over_width/spaces_count)
      local total_added_width = 0
      for _, c in ipairs(characters) do
        if c.character == " " then
          c.x = c.x + added_width_to_each_space
          total_added_width = total_added_width + added_width_to_each_space
        else
          c.x = c.x + total_added_width
        end
      end
    end
  end
end


function Text:get_characters_in_line(line)
  local characters = {}
  for _, c in ipairs(self.characters) do
    if c.line == line then table.insert(characters, c) end
  end
  return characters
end


function Text:parse(text)
  local tags = {}
  for i, tags_text, j in text:gmatch("()%[(.-)%]()") do
    if tags_text == "" then
      table.insert(tags, {i = tonumber(i), j = tonumber(j)-1})
    else
      local local_tags = {}
      for tag in tags_text:gmatch("[%w]+") do table.insert(local_tags, tag) end
      table.insert(tags, {i = tonumber(i), j = tonumber(j)-1, tags = local_tags})
    end
  end

  local characters = {}
  local current_tags = nil
  local current_line, current_col = 1, 1
  for i = 1, #text do
    local c = text:sub(i, i)
    local inside_tags = false
    for _, tag in ipairs(tags) do
      if i >= tag.i and i <= tag.j then
        inside_tags = true
        current_tags = tag.tags
        break
      end
    end
    if not inside_tags then
      table.insert(characters, {character = c, visible = true, tags = current_tags or {}})
    end
  end

  local raw_text = ""
  for _, character in ipairs(characters) do
    raw_text = raw_text .. character.character
  end
  return raw_text, characters
end


function Text:set_wrap_width(wrap_width)
  self.wrap_width = wrap_width
  return self
end


function Text:set_line_height_multiplier(m)
  self.line_height_multiplier = m or 1
  return self
end


function Text:set_font(font)
  self.font = font
  return self
end


function Text:set_justify(justify)
  self.justify = justify or "left"
  return self
end

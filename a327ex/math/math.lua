function math.get_polygon_center(vs)
  local xs, ys = 0, 0
  for i = 1, #vs, 2 do
    xs = xs + vs[i]
    ys = ys + vs[i+1]
  end
  return xs/(#vs/2), ys/(#vs/2)
end


function math.get_polygon_size(vs)
  local min_x, min_y, max_x, max_y = 100000, 100000, -100000, -100000
  for i = 1, #vs, 2 do
    if vs[i] < min_x then min_x = vs[i] end
    if vs[i] > max_x then max_x = vs[i] end
    if vs[i+1] < min_y then min_y = vs[i+1] end
    if vs[i+1] > max_y then max_y = vs[i+1] end
  end
  return math.abs(max_x - min_x), math.abs(max_y - min_y)
end


function math.is_polygon_in_polygon(polygon_1, polygon_2)
  return mlib.polygon.isPolygonInside(polygon_2, polygon_1)
end


function math.is_point_in_polygon(x, y, vertices)
  return mlib.polygon.checkPoint(x, y, vertices)
end


function math.get_rectangle_vertices(x, y, w, h)
  return {x - w/2, y - h/2, x + w/2, y - h/2, x + w/2, y + h/2, x - w/2, y + h/2}
end


function math.is_point_in_rectangle(px, py, x, y, w, h)
  return math.is_point_in_polygon(px, py, math.get_rectangle_vertices(x, y, w, h))
end



function math.is_rectangle_in_rectangle(x1, y1, w1, h1, x2, y2, w2, h2)
  return math.is_polygon_in_polygon(math.get_rectangle_vertices(x1, y1, w1, h1), math.get_rectangle_vertices(x2, y2, w2, h2))
end


function math.is_point_in_rectangle(px, py, x, y, w, h, r)
  local x1, y1 = math.rotate_point(x - w/2, y - h/2, r or 0, x, y)
  local x2, y2 = math.rotate_point(x + w/2, y - h/2, r or 0, x, y)
  local x3, y3 = math.rotate_point(x + w/2, y + h/2, r or 0, x, y)
  local x4, y4 = math.rotate_point(x - w/2, y + h/2, r or 0, x, y)
  local vertices = {x1, y1, x2, y2, x3, y3, x4, y4}
  return math.is_point_in_polygon(px, py, vertices)
end


function math.rotate_point(x, y, r, ox, oy)
  return x*math.cos(r) - y*math.sin(r) + ox - ox*math.cos(r) + oy*math.sin(r), x*math.sin(r) + y*math.cos(r) + oy - oy*math.cos(r) - ox*math.sin(r)
end


function math.scale_point(x, y, sx, sy, ox, oy)
  return x*sx + ox - ox*sx, y*sy + oy - oy*sy
end


function math.rotate_scale_point(x, y, r, sx, sy, ox, oy)
  local rx, ry = math.rotate_point(x, y, r, ox, oy)
  return math.scale_point(rx, ry, sx, sy, ox, oy)
end


function math.angle_to_horizontal(r)
  if r > math.pi/2 or r < -math.pi/2 then return -1
  elseif r <= math.pi/2 and r >= -math.pi/2 then return 1 end
end


function math.angle_to_vertical(r)
  if r > 0 and r < math.pi then return -1
  elseif r <= 0 and r >= -math.pi then return 1 end
end


function math.snap_center(v, x)
  return math.ceil(v/x)*x - x/2
end


function math.distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end


function math.loop(t, length)
  return clamp(t-math.floor(t/length)*length, 0, length)
end


function math.clamp01(v)
  if v < 0 then return 0
  elseif v > 1 then return 1
  else return v end
end


function math.lerp_angle(t, a, b)
  local dt = math.loop((b-a), 2*math.pi)
  if dt > math.pi then dt = dt - 2*math.pi end
  return a + dt*math.clamp01(t)
end


function math.round(n, p)
  local m = 10^(p or 0)
  return math.floor(n*m+0.5)/m
end


function math.snap(n, g)
  return math.round(n/g, 0)*g
end


function math.clamp(v, min, max)
  return math.min(math.max(v, min), max)
end


function math.length(x, y)
  return math.sqrt(x*x + y*y)
end


function math.sign(n)
  if n > 0 then return 1
  elseif n < 0 then return -1
  else return 0 end
end


function math.angle(x, y, px, py)
  return math.atan2(py - y, px - x)
end


function math.remap(v, old_min, old_max, new_min, new_max)
  return ((v - old_min)/(old_max - old_min))*(new_max - new_min) + new_min
end


local PI = math.pi
local PI2 = math.pi/2
local LN2 = math.log(2)
local LN210 = 10*math.log(2)


function math.lerp_dt(f, dt, src, dst)
  return math.lerp(1 - (1-f)^dt, src, dst)
end


function math.lerp(value, src, dst)
  return src*(1 - value) + dst*value
end


function math.linear(t)
  return t
end


function math.sine_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return 1 - math.cos(t*PI2) end
end


function math.sine_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.sin(t*PI2) end
end


function math.sine_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return -0.5*(math.cos(t*PI) - 1) end
end


function math.sine_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then return 0.5*math.sin((t*2)*PI2)
  else return -0.5*math.cos((t*2-1)*PI2) + 1 end
end


function math.quad_in(t)
  return t*t
end


function math.quad_out(t)
  return -t*(t-2)
end


function math.quad_in_out(t)
  if t < 0.5 then
    return 2*t*t
  else
    t = t - 1
    return -2*t*t + 1
  end
end


function math.quad_out_in(t)
  if t < 0.5 then
    t = t*2
    return -0.5*t*(t-2)
  else
    t = t*2 - 1
    return 0.5*t*t + 0.5
  end
end


function math.cubic_in(t)
  return t*t*t
end

function math.cubic_out(t)
  t = t - 1
  return t*t*t + 1
end


function math.cubic_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t
  else
    t = t - 2
    return 0.5*(t*t*t + 2)
  end
end


function math.cubic_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t + 1)
end


function math.quart_in(t)
  return t*t*t*t
end


function math.quart_out(t)
  t = t - 1
  t = t*t
  return 1 - t*t
end


function math.quart_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t
  else
    t = t - 2
    t = t*t
    return -0.5*(t*t - 2)
  end
end


function math.quart_out_in(t)
  if t < 0.5 then
    t = t*2 - 1
    t = t*t
    return -0.5*t*t + 0.5
  else
    t = t*2 - 1
    t = t*t
    return 0.5*t*t + 0.5
  end
end


function math.quint_in(t)
  return t*t*t*t*t
end


function math.quint_out(t)
  t = t - 1
  return t*t*t*t*t + 1
end


function math.quint_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t*t
  else
    t = t - 2
    return 0.5*t*t*t*t*t + 1
  end
end


function math.quint_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t*t*t + 1)
end


function math.expo_in(t)
  if t == 0 then return 0
  else return math.exp(LN210*(t - 1)) end
end


function math.expo_out(t)
  if t == 1 then return 1
  else return 1 - math.exp(-LN210*t) end
end


function math.expo_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1 end
  t = t*2
  if t < 1 then return 0.5*math.exp(LN210*(t - 1))
  else return 0.5*(2 - math.exp(-LN210*(t - 1))) end
end


function math.expo_out_in(t)
  if t < 0.5 then return 0.5*(1 - math.exp(-20*LN2*t))
  elseif t == 0.5 then return 0.5
  else return 0.5*(math.exp(20*LN2*(t - 1)) + 1) end
end


function math.circ_in(t)
  if t < -1 or t > 1 then return 0
  else return 1 - math.sqrt(1 - t*t) end
end


function math.circ_out(t)
  if t < 0 or t > 2 then return 0
  else return math.sqrt(t*(2 - t)) end
end


function math.circ_in_out(t)
  if t < -0.5 or t > 1.5 then return 0.5
  else
    t = t*2
    if t < 1 then return -0.5*(math.sqrt(1 - t*t) - 1)
    else
      t = t - 2
      return 0.5*(math.sqrt(1 - t*t) + 1)
    end
  end
end


function math.circ_out_in(t)
  if t < 0 then return 0
  elseif t > 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*math.sqrt(1 - t*t)
  else
    t = t*2 - 1
    return -0.5*((math.sqrt(1 - t*t) - 1) - 1)
  end
end


function math.bounce_in(t)
  t = 1 - t
  if t < 1/2.75 then return 1 - (7.5625*t*t)
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 1 - (7.5625*t*t + 0.75)
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 1 - (7.5625*t*t + 0.9375)
  else
    t = t - 2.625/2.75
    return 1 - (7.5625*t*t + 0.984375)
  end
end


function math.bounce_out(t)
  if t < 1/2.75 then return 7.5625*t*t
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 7.5625*t*t + 0.75
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 7.5625*t*t + 0.9375
  else
    t = t - 2.625/2.75
    return 7.5625*t*t + 0.984375
  end
end


function math.bounce_in_out(t)
  if t < 0.5 then
    t = 1 - t*2
    if t < 1/2.75 then return (1 - (7.5625*t*t))*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (1 - (7.5625*t*t + 0.75))*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (1 - (7.5625*t*t + 0.9375))*0.5
    else
      t = t - 2.625/2.75
      return (1 - (7.5625*t*t + 0.984375))*0.5
    end
  else
    t = t*2 - 1
    if t < 1/2.75 then return (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end


function math.bounce_out_in(t)
  if t < 0.5 then
    t = t*2
    if t < 1/2.75 then return (7.5625*t*t)*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5
    end
  else
    t = 1 - (t*2 - 1)
    if t < 1/2.75 then return 0.5 - (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return 0.5 - (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return 0.5 - (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return 0.5 - (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end


local overshoot = 1.70158

function math.back_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return t*t*((overshoot + 1)*t - overshoot) end
end


function math.back_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return t*t*((overshoot + 1)*t + overshoot) + 1
  end
end


function math.back_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then return 0.5*(t*t*(((overshoot*1.525) + 1)*t - overshoot*1.525))
    else
      t = t - 2
      return 0.5*(t*t*(((overshoot*1.525) + 1)*t + overshoot*1.525) + 2)
    end
  end
end


function math.back_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*(t*t*((overshoot + 1)*t + overshoot) + 1)
  else
    t = t*2 - 1
    return 0.5*t*t*((overshoot + 1)*t - overshoot) + 0.5
  end
end


local amplitude = 1
local period = 0.0003

function math.elastic_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return -(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
  end
end


function math.elastic_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 1 end
end


function math.elastic_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then
      t = t - 1
      return -0.5*(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
    else
      t = t - 1
      return amplitude*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)*0.5 + 1
    end
  end
end


function math.elastic_out_in(t)
  if t < 0.5 then
    t = t*2
    if t == 0 then return 0
    else return (amplitude/2)*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 0.5 end
  else
    if t == 0.5 then return 0.5
    elseif t == 1 then return 1
    else
      t = t*2 - 1
      t = t - 1
      return -((amplitude/2)*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)) + 0.5
    end
  end
end

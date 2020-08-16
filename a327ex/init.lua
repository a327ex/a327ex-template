local path = ...
if not path:find("init") then
  require(path .. ".string")
  require(path .. ".data_structures.table")
  require(path .. ".external")
  require(path .. ".graphics.graphics")
  require(path .. ".game.Object")
  require(path .. ".system")
  require(path .. ".data_structures.Graph")
  require(path .. ".data_structures.Grid")
  require(path .. ".game.GameObject")
  require(path .. ".game.Group")
  require(path .. ".game.log")
  require(path .. ".game.LogMessage")
  require(path .. ".game.misc")
  require(path .. ".graphics.Camera")
  require(path .. ".graphics.Canvas")
  require(path .. ".graphics.Color")
  require(path .. ".graphics.Text")
  require(path .. ".math.math")
  require(path .. ".math.Random")
  require(path .. ".math.Spring")
  require(path .. ".math.Vector")
  require(path .. ".timer.Animation")
  require(path .. ".timer.Sequence")
  require(path .. ".timer.Timer")
  require(path .. ".input")
end

function a327ex_run(config)
  love.filesystem.setIdentity(config.game_name)

  local _, _, flags = love.window.getMode()
  local window_width, window_height = love.window.getDesktopDimensions(flags.display)
  if config.window_width ~= 'max' then window_width = config.window_width end
  if config.window_height ~= 'max' then window_height = config.window_height end

  local limits = love.graphics.getSystemLimits()
  local anisotropy = limits.anisotropy
  msaa = limits.canvasmsaa
  if config.msaa ~= 'max' then msaa = config.msaa end
  if config.anisotropy ~= 'max' then anisotropy = config.anisotropy end

  gw, gh = config.game_width or 1920, config.game_height or 1080
  sx, sy = window_width/(config.game_width or 1920), window_height/(config.game_height or 1080)

  love.window.setMode(window_width, window_height, {
    fullscreen = config.fullscreen, borderless = config.borderless, resizable = config.resizable, vsync = config.vsync, msaa = msaa or 0, display = config.display
  })

  love.graphics.setBackgroundColor(0, 0, 0, 1)
  love.graphics.setColor(1, 1, 1, 1)
  love.joystick.loadGamepadMappings("a327ex/gamecontrollerdb.txt")
  graphics.set_line_style(config.line_style or "smooth")
  graphics.set_default_filter(config.default_filter or "linear", config.default_filter or "linear", anisotropy or 1)

  system.load_images()
  system.load_fonts()
  system.load_shaders()

  input.bind('f12', 'f12')
  for k, v in pairs(config.input or {}) do input.bind(k, v) end
  random = Random()
  timer = Timer()
  camera = Camera(gw/2, gh/2)
  log.group = Group()
  config.init()

  if love.timer then love.timer.step() end

  local _, _, flags = love.window.getMode()
  local fixed_dt = 1/flags.refreshrate
  local accumulator = fixed_dt
  local dt = 0
  frame, time, refresh_rate = 0, 0, flags.refreshrate

  return function()
    if love.event then
      love.event.pump()
      for name, a, b, c, d, e, f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        elseif name == "keypressed" then input.keyboard_state[a] = true; input.last_key_pressed = a
        elseif name == "keyreleased" then input.keyboard_state[a] = false
        elseif name == "mousepressed" then input.mouse_state[input.mouse_buttons[c]] = true; input.last_key_pressed = input.mouse_buttons[c]
        elseif name == "mousereleased" then input.mouse_state[input.mouse_buttons[c]] = false
        elseif name == "wheelmoved" then if b == 1 then input.mouse_state.wheel_up = true elseif b == -1 then input.mouse_state.wheel_down = true end
        elseif name == "gamepadpressed" then input.gamepad_state[input.index_to_gamepad_button[b]] = true; input.last_key_pressed = input.index_to_gamepad_button[b]
        elseif name == "gamepadreleased" then input.gamepad_state[input.index_to_gamepad_button[b]] = false
        elseif name == "gamepadaxis" then input.gamepad_axis[input.index_to_gamepad_axis[b]] = c end
      end
    end

    if love.timer then dt = love.timer.step() end

    accumulator = accumulator + dt
    while accumulator >= fixed_dt do
      frame = frame + 1
      input.update()
      timer:update(fixed_dt*slow_amount)
      camera:update(fixed_dt*slow_amount)
      log.group:update(fixed_dt)
      config.update(fixed_dt*slow_amount)
      system.update()
      input.last_key_pressed = nil
      accumulator = accumulator - fixed_dt
      time = time + fixed_dt
    end

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      config.draw()
      log.group:draw()
      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.001) end
  end
end

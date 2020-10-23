require 'engine'


function init()

end


function update(dt)

end


function draw()

end


function love.run()
  local run = engine_run({
    game_name = 'GAME NAME',
    game_width = 480,
    game_height = 270,
    window_width = 480*3,
    window_height = 270*3,
    msaa = 'max',
    anisotropy = 'max',
    line_style = 'rough',
    default_filter = 'nearest',
    init = init,
    update = update,
    draw = draw,
    input = {
      ['move_left'] = {'a', 'dpleft'},
      ['move_right'] = {'d', 'dpright'},
      ['move_up'] = {'w', 'dpup'},
      ['move_down'] = {'s', 'dpdown'},
    }
  })

  return run
end

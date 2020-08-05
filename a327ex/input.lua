input = {}
input.mouse_buttons = {"m1", "m2", "m3", "m4", "m5", "wheel_up", "wheel_down"}
input.gamepad_buttons = {"fdown", "fup", "fleft", "fright", "dpdown", "dpup", "dpleft", "dpright", "start", "back", "guide", "leftstick", "rightstick", "rb", "lb"}
input.index_to_gamepad_button = {
  ["a"] = "fdown", ["b"] = "fright", ["x"] = "fleft", ["y"] = "fup", ["back"] = "back", ["start"] = "start", ["guide"] = "guide", ["leftstick"] = "leftstick",
  ["rightstick"] = "rightstick", ["leftshoulder"] = "lb", ["rightshoulder"] = "rb", ["dpdown"] = "dpdown", ["dpup"] = "dpup", ["dpleft"] = "dpleft", ["dpright"] = "dpright",
}
input.index_to_gamepad_axis = {["leftx"] = "leftx", ["rightx"] = "rightx", ["lefty"] = "lefty", ["righty"] = "righty", ["triggerleft"] = "lt", ["triggerright"] = "rt"}
input.gamepad_axis = {}
input.joystick = love.joystick.getJoysticks()[1]
input.keyboard_state = {}
input.previous_keyboard_state = {}
input.mouse_state = {}
input.previous_mouse_state = {}
input.gamepad_state = {}
input.previous_gamepad_state = {}
input.actions = {}


function input.update()
  for _, action in ipairs(input.actions) do
    input[action].pressed = false
    input[action].down = false
    input[action].released = false
  end

  for _, action in ipairs(input.actions) do
    for _, key in ipairs(input[action].keys) do
      if table.contains(input.mouse_buttons, key) then
        input[action].pressed = input[action].pressed or (input.mouse_state[key] and not input.previous_mouse_state[key])
        input[action].down = input[action].down or input.mouse_state[key]
        input[action].released = input[action].released or (not input.mouse_state[key] and  input.previous_mouse_state[key])
      elseif table.contains(input.gamepad_buttons, key) then
        input[action].pressed = input[action].pressed or (input.gamepad_state[key] and not input.previous_gamepad_state[key])
        input[action].down = input[action].down or input.gamepad_state[key]
        input[action].released = input[action].released or (not input.gamepad_state[key] and  input.previous_gamepad_state[key])
      else
        input[action].pressed = input[action].pressed or (input.keyboard_state[key] and not input.previous_keyboard_state[key])
        input[action].down = input[action].down or input.keyboard_state[key]
        input[action].released = input[action].released or (not input.keyboard_state[key] and input.previous_keyboard_state[key])
      end
    end
  end


  input.previous_mouse_state = table.copy(input.mouse_state)
  input.previous_gamepad_state = table.copy(input.gamepad_state)
  input.previous_keyboard_state = table.copy(input.keyboard_state)
  input.mouse_state.wheel_up = false
  input.mouse_state.wheel_down = false
end


function input.bind(action, keys)
  if not input[action] then input[action] = {} end
  if type(keys) == "string" then input[action].keys = {keys}
  elseif type(keys) == "table" then input[action].keys = keys end
  table.insert(input.actions, action)
end


function input.unbind(action)
  input[action] = nil
end


function input.axis(key)
  return input.gamepad_axis[key]
end

log = {}

function log.message(text)
  table.each(log.group.objects, function(v)
    if v:is(LogMessage) then
      v:move_up()
    end
  end)

  log.group:create_object('LogMessage', 20, sy*gh, {text = '[log_message_fade]' .. text})
end

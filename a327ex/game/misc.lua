slow_amount = 1

function slow(amount, duration)
  slow_amount = amount
  timer:tween(duration, _G, {slow_amount = 1}, math.cubic_in_out, function() slow_amount = 1 end, 'slow')
end

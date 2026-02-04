---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

function weather.gettime()
  local time = GlobalState.currentTime
  return time.hour, time.minute
end

--------------------- OBJECT ---------------------
getmetatable(weather).__newindex = function() error('attempt to edit a read-only object', 2) end

return weather
---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

function weather.gettime()
  return qb_weather:getTime()
end

--------------------- OBJECT ---------------------
getmetatable(weather).__newindex = function() error('attempt to edit a read-only object', 2) end

return weather
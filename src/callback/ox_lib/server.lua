---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param player integer|string The `player` to trigger the callback for.
---@param name string The callback `name`.
---@param cb function The receiving callback function.
---@param ... any Additional arguments to pass to the callback.
-- Triggers a callback with the given name and calls back the data through the given function.
function callback.trigger(player, name, cb, ...)
  local src = tonumber(player or source)
  if not IsSrcAPlayer(src) then error('bad argument #1 to \'trigger\' (number or string expected, got '..player..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'trigger\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #3 to \'trigger\' (function expected, got '..type(cb)..')', 2) end
  lib.callback(name, src --[[@as number]], cb, ...)
end

---@param player integer|string The `player` to trigger the callback for.
---@param name string The callback `name`.
---@param ... any Additional arguments to pass to the callback.
---@return ...
function callback.await(player, name, ...)
  local src = tonumber(player or source)
  if not IsSrcAPlayer(src) then error('bad argument #1 to \'await\' (number or string expected, got '..player..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'await\' (string expected, got '..type(name)..')', 2) end
  if ... then
    local args = {...}
    if args[1] and type(args[1]) == 'function' then error('bad argument #3 to \'await\' (callback function is redundant)', 2) end
  end
  return lib.callback.await(name, src --[[@as number]], ...)
end

--------------------- OBJECT ---------------------
getmetatable(callback).__newindex = function() error('attempt to edit a read-only object', 2) end

return callback

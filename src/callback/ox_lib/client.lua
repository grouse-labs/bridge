---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param name string The callback `name`.
---@param delay integer? The delay in milliseconds before the callback is triggered.
---@param cb function The receiving callback function.
---@param ... any Additional arguments to pass to the callback.
-- Triggers a callback with the given name and calls back the data through the given function.
function callback.trigger(name, delay, cb, ...)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'trigger\' (string expected, got '..type(name)..')', 2) end
  if delay and type(delay) ~= 'number' then error('bad argument #2 to \'trigger\' (number or false expected, got '..type(delay)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #3 to \'trigger\' (function expected, got '..type(cb)..')', 2) end
  lib.callback(name, delay and delay or false, cb, ...)
end

---@param name string The callback `name`.
---@param delay integer? The delay in milliseconds before the callback is triggered.
---@param ... any Additional arguments to pass to the callback.
---@return ...
function callback.await(name, delay, ...)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'AwaitCallback\' (string expected, got '..type(name)..')', 2) end
  if delay and type(delay) ~= 'number' then error('bad argument #2 to \'trigger\' (number or false expected, got '..type(delay)..')', 2) end
  return lib.callback.await(name, delay and delay or false, ...)
end

--------------------- OBJECT ---------------------
getmetatable(callback).__newindex = function() error('attempt to edit a read-only object', 2) end

return callback

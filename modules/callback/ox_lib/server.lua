local CALLBACK <const> = 'ox_lib'
if CALLBACK ~= GetConvar('bridge:callback', 'ox_lib') then error('invalid callback resource name', 0) end
if not IsResourceValid(CALLBACK) then error('callback resource `'..CALLBACK..'` not valid', 0) end

local load, load_resource_file = load, LoadResourceFile
if not lib then load(load_resource_file('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib
local VERSION <const> = GetResourceMetadata(CALLBACK, 'version', 0)
if VERSION:gsub('%D', '') < ('3.29.0'):gsub('%D', '') then error('incompatible version of '..CALLBACK..' detected (expected 3.29.0 or higher, got '..VERSION..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'ox_lib'
local function get_callback() return CALLBACK end

---@return string version
local function get_version() return VERSION end

---@param name string The name of the callback to create.
---@param cb function The function to call when the callback is triggered.
local function register_callback(name, cb)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'RegisterCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #2 to \'RegisterCallback\' (function expected, got '..type(cb)..')', 2) end
  lib.callback.register(name, cb)
end

---@param player integer|string? The `player` to trigger the callback for. <br> If `nil`, the callback will be triggered for the function source.
---@param name string The name of the callback to trigger.
---@param cb function The function to call when the callback is received.
---@param ... any Additional arguments to pass to the callback.
local function trigger_callback(player, name, cb, ...)
  if not IsSrcValid(player or source) then error('bad argument #1 to \'TriggerCallback\' (number or string expected, got '..player..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'TriggerCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #3 to \'TriggerCallback\' (function expected, got '..type(cb)..')', 2) end
  lib.callback(name, player or source, cb, ...)
end

---@param player integer|string? The `player` to trigger the callback for. <br> If `nil`, the callback will be triggered for the function source.
---@param name string The name of the callback to trigger.
---@param ... any Additional arguments to pass to the callback.
---@return ... result
local function await_callback(player, name, ...)
  if not IsSrcValid(player or source) then error('bad argument #1 to \'AwaitCallback\' (number or string expected, got '..player..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'AwaitCallback\' (string expected, got '..type(name)..')', 2) end
  return lib.callback.await(name, player or source, ...)
end

--------------------- OBJECT ---------------------

return {
  _CALLBACK = CALLBACK,
  _VERSION = VERSION,
  getcallback = get_callback,
  getversion = get_version,
  register = register_callback,
  trigger = trigger_callback,
  await = await_callback
}
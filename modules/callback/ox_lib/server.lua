local callback = 'ox_lib'
if callback ~= GetResourceMetadata('bridge', 'callback', 0) then return end
if not IsResourceValid(callback) then return end

local load, load_resource_file = load, LoadResourceFile
if not lib then load(load_resource_file('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib
local version = GetResourceMetadata(callback, 'version', 0)
if version:gsub('%D', '') < ('3.29.0'):gsub('%D', '') then error('incompatible version of '..callback..' detected (expected 3.29.0 or higher, got '..version..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'ox_lib'
local function get_callback() return callback end

---@return string version
local function get_version() return version end

---@return table
local function get_object() return lib end

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
  if not IsSrcValid(player or source) then error('bad argument #1 to \'TriggerCallback\' (number or string expected, got '..type(player)..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'TriggerCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #3 to \'TriggerCallback\' (function expected, got '..type(cb)..')', 2) end
  lib.callback(name, player or source, cb, ...)
end

--------------------- OBJECT ---------------------

return {
  _CALLBACK = callback,
  _VERSION = version,
  getcallback = get_callback,
  getversion = get_version,
  getobject = get_object,
  register = register_callback,
  trigger = trigger_callback
}
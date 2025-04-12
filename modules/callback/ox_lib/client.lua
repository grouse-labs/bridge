local CALLBACK <const> = 'ox_lib'
if CALLBACK ~= GetConvar('bridge:callback', 'ox_lib') then error('invalid callback resource name', 0) end
if not IsResourceValid(CALLBACK) then error('callback resource `'..CALLBACK..'` not valid', 0) end

local load, load_resource_file = load, LoadResourceFile
if not lib then load(load_resource_file('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib
local version = GetResourceMetadata(CALLBACK, 'version', 0)
if version:gsub('%D', '') < ('3.29.0'):gsub('%D', '') then error('incompatible version of '..CALLBACK..' detected (expected 3.29.0 or higher, got '..version..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'ox_lib'
local function get_callback() return CALLBACK end

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

---@param name string The name of the callback to trigger.
---@param cb function The function to call when the callback is received.
---@param ... any Additional arguments to pass to the callback.
local function trigger_callback(name, cb, ...)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'TriggerCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #2 to \'TriggerCallback\' (function expected, got '..type(cb)..')', 2) end
  return lib.callback(name, false, cb, ...)
end

---@param name string The name of the callback to trigger.
---@param ... any Additional arguments to pass to the callback.
---@return ... result
local function await_callback(name, ...)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'AwaitCallback\' (string expected, got '..type(name)..')', 2) end
  return lib.callback.await(name, false, ...)
end

--------------------- OBJECT ---------------------

return {
  _CALLBACK = CALLBACK,
  _VERSION = version,
  getcallback = get_callback,
  getversion = get_version,
  getobject = get_object,
  register = register_callback,
  trigger = trigger_callback,
  await = await_callback
}
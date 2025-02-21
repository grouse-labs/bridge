local CALLBACK <const> = 'es_extended'
if CALLBACK ~= GetResourceMetadata('bridge', 'callback', 0) then return end
if not IsResourceValid(CALLBACK) then return end

local ESX = exports[CALLBACK]:getSharedObject()
local version = GetResourceMetadata(CALLBACK, 'version', 0)
if version:gsub('%D', '') < ('1.12.4'):gsub('%D', '') then error('incompatible version of '..CALLBACK..' detected (expected 1.12.4 or higher, got '..version..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'es_extended'
local function get_callback() return CALLBACK end

---@return string version
local function get_version() return version end

---@return table
local function get_object() return QBCore end

---@param name string The name of the callback to create.
---@param cb function The function to call when the callback is triggered.
local function register_callback(name, cb)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'RegisterCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #2 to \'RegisterCallback\' (function expected, got '..type(cb)..')', 2) end
  ESX.RegisterClientCallback(name, cb)
end

---@param name string The name of the callback to trigger.
---@param cb function The function to call when the callback is received.
---@param ... any Additional arguments to pass to the callback.
local function trigger_callback(name, cb, ...)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'TriggerCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #2 to \'TriggerCallback\' (function expected, got '..type(cb)..')', 2) end
  QBCore.TriggerServerCallback(name, cb, ...)
end

--------------------- OBJECT ---------------------

return {
  _CALLBACK = CALLBACK,
  _VERSION = version,
  getcallback = get_callback,
  getversion = get_version,
  getobject = get_object,
  register = register_callback,
  trigger = trigger_callback
}
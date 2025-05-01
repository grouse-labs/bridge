---@diagnostic disable: duplicate-set-field
local CALLBACK <const> = 'ox_lib'
if CALLBACK ~= GetConvar('bridge:callback', 'ox_lib') then error('invalid callback resource name', 0) end
if not IsResourceValid(CALLBACK) then error('callback resource `'..CALLBACK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(CALLBACK, 'version', 0)
if VERSION:gsub('%D', '') < ('3.29.0'):gsub('%D', '') then error('incompatible version of '..CALLBACK..' detected (expected 3.29.0 or higher, got '..VERSION..')', 0) end

if not lib then load(LoadResourceFile('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib

---@type CCallback
---@diagnostic disable-next-line: missing-fields
local callback = {}

--------------------- FUNCTIONS ---------------------

---@return 'ox_lib'
-- Returns the callback resource name.
function callback.getname() return CALLBACK end

---@return string version
-- Returns the callback version as defined in the resource manifest.
function callback.getversion() return VERSION end

---@param name string The callback `name`.
---@param cb function The callback function.
-- Registers an event handler with a callback to the respective enviroment
function callback.register(name, cb)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'register\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #2 to \'register\' (function expected, got '..type(cb)..')', 2) end
  lib.callback.register(name, cb)
end

--------------------- OBJECT ---------------------

setmetatable(callback, {
  __name = 'callback',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('callback: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^2callback library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, CALLBACK, VERSION, address) or address
  end
})

_ENV.callback = callback

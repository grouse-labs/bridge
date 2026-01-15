---@diagnostic disable: duplicate-set-field
local CALLBACK <const> = 'gr_lib'
if CALLBACK ~= GetConvar('bridge:callback', 'ox_lib') then error('invalid callback resource name', 0) end
if not IsResourceValid(CALLBACK) then error('callback resource `'..CALLBACK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(CALLBACK, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('callback')[CALLBACK]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then error(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(CALLBACK, MIN_VERSION, VERSION), 0) end

---@type CCallback
---@diagnostic disable-next-line: missing-fields
local callback = {}

--------------------- FUNCTIONS ---------------------

---@return 'gr_lib'
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
  glib.callback.register(name, cb)
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
---@diagnostic disable: duplicate-set-field
local NOTIFY <const> = 'es_extended'
if NOTIFY ~= MODULE_NAMES.notify then return end
if not IsResourceValid(NOTIFY) then error('notify resource `'..NOTIFY..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(NOTIFY, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('notify')[NOTIFY]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then error(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(NOTIFY, MIN_VERSION, VERSION), 0) end

local ESX = exports[NOTIFY]:getSharedObject()

---@type CNotify
---@diagnostic disable-next-line: missing-fields
local notify = {}

--------------------- FUNCTIONS ---------------------

---@return 'es_extended'
-- Returns the notify resource name.
function notify.getname() return NOTIFY end

---@return string version
-- Returns the notify resource version as defined in the resource manifest.
function notify.getversion() return VERSION end

--------------------- OBJECT ---------------------

setmetatable(notify, {
  __name = 'notify',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('notify: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^2notify library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, NOTIFY, VERSION, address) or address
  end
})

_ENV.notify = notify
_ENV.ESX = ESX

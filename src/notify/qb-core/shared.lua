---@diagnostic disable: duplicate-set-field
local NOTIFY <const> = 'qb-core'
if NOTIFY ~= GetConvar('bridge:notify', 'native') then error('invalid notify resource name', 0) end
if not IsResourceValid(NOTIFY) and IsResourceValid('qbx_core') then error('notify resource `'..NOTIFY..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(NOTIFY, 'version', 0)
if VERSION:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..NOTIFY..' detected (expected 1.3.0 or higher, got '..VERSION..')', 0) end

local QBCore = exports[NOTIFY]:GetCoreObject({'Shared'})

---@type CNotify
---@diagnostic disable-next-line: missing-fields
local notify = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-core'
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
_ENV.QBCore = QBCore

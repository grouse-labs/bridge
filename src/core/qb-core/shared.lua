---@diagnostic disable: duplicate-set-field
local FRAMEWORK <const> = 'qb-core'
if FRAMEWORK ~= GetConvar('bridge:framework', 'qbx_core') then error('invalid framework resource name', 0) end
if not IsResourceValid(FRAMEWORK) and IsResourceValid('qbx_core') then error('framework resource `'..FRAMEWORK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(FRAMEWORK, 'version', 0)
if VERSION:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..FRAMEWORK..' detected (expected 1.3.0 or higher, got '..VERSION..')', 0) end

local QBCore = exports[FRAMEWORK]:GetCoreObject({'Functions', 'Shared'})

---@type CFramework
---@diagnostic disable-next-line: missing-fields
local core = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-core'
-- Returns the framework name.
function core.getname() return FRAMEWORK end

---@return string version
-- Returns the framework version as defined in the resource manifest.
function core.getversion() return VERSION end

---@return table QBCore
-- Returns the framework object.
function core.getobject() return QBCore end

--------------------- EVENTS ---------------------

RegisterNetEvent(string.format('QBCore:%s:UpdateObject', bridge._CONTEXT:sub(1, 1):upper()..bridge._CONTEXT:sub(2)), function()
  QBCore = exports['qb-core']:GetCoreObject({'Functions', 'Shared'})
end)

--------------------- OBJECT ---------------------

setmetatable(core, {
  __name = 'core',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('core: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^2core library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, FRAMEWORK, VERSION, address) or address
  end
})

_ENV.core = core
_ENV.QBCore = QBCore

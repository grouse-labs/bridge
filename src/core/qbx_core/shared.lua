---@diagnostic disable: duplicate-set-field
local FRAMEWORK <const> = 'qbx_core'
if FRAMEWORK ~= GetConvar('bridge:framework', 'qbx_core') then error('invalid framework resource name', 0) end
if not IsResourceValid(FRAMEWORK) and IsResourceValid('qb-core') then error('framework resource `'..FRAMEWORK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(FRAMEWORK, 'version', 0)
if VERSION:gsub('%D', '') < ('1.22.6'):gsub('%D', '') then error('incompatible version of '..FRAMEWORK..' detected (expected 1.22.6 or higher, got '..VERSION..')', 0) end

local qbx = exports[FRAMEWORK]

---@type CFramework
---@diagnostic disable-next-line: missing-fields
local core = {}

--#TODO:
--#[X] Test which version (preferably the latest) of qbx_core this is compatible with and update the version check accordingly.

--------------------- FUNCTIONS ---------------------

---@return 'qbx_core'
-- Returns the framework name.
function core.getname() return FRAMEWORK end

---@return string version
-- Returns the framework version as defined in the resource manifest.
function core.getversion() return VERSION end

---@return table QBCore
-- Returns the framework object.
function core.getobject()
  if GetConvar('qbx:enablebridge', 'true') == 'false' then error('qbx:enablebridge is set to false', 2) end
  return exports['qb-core']:GetCoreObject()
end

--------------------- OBJECT ---------------------

setmetatable(core, {
  __name = 'core',
  __version = VERSION,
  __tostring = function()
    return string.format('^3[%s]^7 - ^2core library^7 ^5\'%s\'^7 v^5%s^7', bridge._RESOURCE, FRAMEWORK, VERSION)
  end
})

_ENV.core = core
_ENV.qbx = qbx

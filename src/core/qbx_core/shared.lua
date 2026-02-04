---@diagnostic disable: duplicate-set-field
local FRAMEWORK <const> = 'qbx_core'
if FRAMEWORK ~= MODULE_NAMES.core then return end
if not IsResourceValid(FRAMEWORK) and IsResourceValid('qb-core') then error('framework resource `'..FRAMEWORK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(FRAMEWORK, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('framework')[FRAMEWORK]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then warn(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(FRAMEWORK, MIN_VERSION, VERSION)) end

if not lib then load(LoadResourceFile('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib
if not qbx then load(LoadResourceFile('qbx_core', 'modules/lib.lua'), '@qbx_core/modules/lib.lua', 't', _ENV)() end
local qbx = _ENV.qbx
local qbxport = exports[FRAMEWORK]

---@type CFramework
---@diagnostic disable-next-line: missing-fields
local core = {}

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
  __tostring = function(t)
    local address = string.format('core: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^2core library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, FRAMEWORK, VERSION, address) or address
  end
})

_ENV.core = core
_ENV.qbxport = qbxport

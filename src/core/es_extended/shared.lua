---@diagnostic disable: duplicate-set-field
local FRAMEWORK <const> = 'es_extended'
if FRAMEWORK ~= GetConvar('bridge:framework', 'qbx_core') then error('invalid framework resource name', 0) end
if not IsResourceValid(FRAMEWORK) then error('framework resource `'..FRAMEWORK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(FRAMEWORK, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('framework')[FRAMEWORK]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then error(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(FRAMEWORK, MIN_VERSION, VERSION), 0) end

local ESX = exports[FRAMEWORK]:getSharedObject()

---@type CFramework
---@diagnostic disable-next-line: missing-fields
local core = {}

--------------------- FUNCTIONS ---------------------

---@return 'es_extended'
-- Returns the framework name.
function core.getname() return FRAMEWORK end

---@return string version
-- Returns the framework version as defined in the resource manifest.
function core.getversion() return VERSION end

---@return table ESX
-- Returns the framework object.
function core.getobject() return ESX end

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
_ENV.ESX = ESX

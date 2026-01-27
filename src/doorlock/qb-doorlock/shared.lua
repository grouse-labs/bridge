---@diagnostic disable: duplicate-set-field
local DOORLOCK <const> = 'qb-doorlock'
if DOORLOCK ~= MODULE_NAMES.doorlock then return end
if not IsResourceValid(DOORLOCK) then error('doorlock resource `'..DOORLOCK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(DOORLOCK, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('doorlock')[DOORLOCK]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then warn(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(DOORLOCK, MIN_VERSION, VERSION)) end

---@type CDoorlock
---@diagnostic disable-next-line: missing-fields
local doorlock = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-doorlock'
-- Returns the doorlock resource name.
function doorlock.getname() return DOORLOCK end

---@return string version
-- Returns the doorlock version as defined in the resource manifest.
function doorlock.getversion() return VERSION end

--------------------- OBJECT ---------------------

setmetatable(doorlock, {
  __name = 'doorlock',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('doorlock: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^2doorlock library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, DOORLOCK, VERSION, address) or address
  end
})

_ENV.doorlock = doorlock
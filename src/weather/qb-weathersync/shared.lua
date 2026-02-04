---@diagnostic disable: duplicate-set-field
local WEATHER <const> = 'qb-weathersync'
if WEATHER ~= MODULE_NAMES.weather then return end
if not IsResourceValid(WEATHER) then error('weather resource `'..WEATHER..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(WEATHER, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('weather')[WEATHER]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then warn(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(WEATHER, MIN_VERSION, VERSION)) end

local qb_weather = exports[WEATHER]
_ENV.qb_weather = qb_weather

---@type CWeather
---@diagnostic disable-next-line: missing-fields
local weather = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-weathersync'
-- Returns the doorlock resource name.
function weather.getname() return WEATHER end

---@return string version
-- Returns the doorlock version as defined in the resource manifest.
function weather.getversion() return VERSION end

--------------------- OBJECT ---------------------

setmetatable(weather, {
  __name = 'weather',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('weather: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^2weather library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, WEATHER, VERSION, address) or address
  end
})

_ENV.weather = weather
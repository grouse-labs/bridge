---@diagnostic disable: duplicate-set-field
local MENU <const> = 'ox_lib'
if MENU ~= GetConvar('bridge:menu', '') then error('invalid menu resource name', 0) end
if not IsResourceValid(MENU) then error('menu resource `'..MENU..'` not valid', 0) end

local load, load_resource_file = load, LoadResourceFile
if not lib then load(load_resource_file('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib

local VERSION <const> = GetResourceMetadata(MENU, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('menu')[MENU]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then error(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(MENU, MIN_VERSION, VERSION), 0) end

---@type CMenu
---@diagnostic disable-next-line: missing-fields
local menu = {}

--------------------- FUNCTIONS ---------------------

---@return 'ox_lib'
function menu.getname() return MENU end

---@return string version
function menu.getname() return VERSION end

---@return table
function menu.getobject() return lib end

---@param menu_id string The ID of the menu to register.
---@param title string The title of the menu.
---@param options {header: string, description: string, icon: string, istitle: boolean?, disabled: boolean?, hasSubMenu: boolean?, onSelect: fun()?, event_type: string?, event: string?, args: table?}[] The options for the menu.
function menu.registermenu(menu_id, title, options)
  if not menu_id or type(menu_id) ~= 'string' then error('bad argument #1 to \'RegisterMenu\' (string expected, got '..type(menu_id)..')', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'RegisterMenu\' (string expected, got '..type(title)..')', 2) end
  if not options then error('bad argument #3 to \'RegisterMenu\' (table expected, got nil)', 2) end
  local converted_options = ConvertMenuOptions(options)
  if not converted_options then error('bad argument #3 to \'RegisterMenu\' (options invalid)', 2) end
  lib.registerContext({id = menu_id, title = ConvertMDHTML(title) --[[@as string]], options = converted_options})
end

---@param menu_id string The ID of the menu to update.
function menu.openmenu(menu_id)
  if not menu_id or type(menu_id) ~= 'string' then error('bad argument #1 to \'OpenMenu\' (string expected, got '..type(menu_id)..')', 2) end
  lib.showContext(menu_id)
end

function menu.closemenu() lib.hideContext() end

--------------------- OBJECT ---------------------

return setmetatable(menu, {
  __name = 'menu',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('menu: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^menu library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, MENU, VERSION, address) or address
  end,
  __newindex = function() error('attempt to edit a read-only object', 2) end
})

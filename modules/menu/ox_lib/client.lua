local MENU <const> = 'ox_lib'
if MENU ~= GetResourceMetadata('bridge', 'menu', 0) then return end
if not IsResourceValid(MENU) then return end

local load, load_resource_file = load, LoadResourceFile
if not lib then load(load_resource_file('ox_lib', 'init.lua'), '@ox_lib/init.lua', 't', _ENV)() end
local lib = _ENV.lib
local version = GetResourceMetadata(MENU, 'version', 0)
if version:gsub('%D', '') < ('3.29.0'):gsub('%D', '') then error('incompatible version of '..MENU..' detected (expected 3.29.0 or higher, got '..version..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'ox_lib'
local function get_menu() return MENU end

---@return string version
local function get_version() return version end

---@return table
local function get_object() return lib end

---@param menu_id string The ID of the menu to register.
---@param title string The title of the menu.
---@param options {header: string, description: string, icon: string, istitle: boolean?, disabled: boolean?, hasSubMenu: boolean?, onSelect: fun()?, event_type: string?, event: string?, args: table?}[] The options for the menu.
local function register_menu(menu_id, title, options)
  if not menu_id or type(menu_id) ~= 'string' then error('bad argument #1 to \'RegisterMenu\' (string expected, got '..type(menu_id)..')', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'RegisterMenu\' (string expected, got '..type(title)..')', 2) end
  if not options then error('bad argument #3 to \'RegisterMenu\' (table expected, got nil)', 2) end
  local converted_options = ConvertMenuOptions(options)
  if not converted_options then error('bad argument #3 to \'RegisterMenu\' (options invalid)', 2) end
  lib.registerContext({id = menu_id, title = ConvertMDHTML(title) --[[@as string]], options = converted_options})
end

---@param menu_id string The ID of the menu to update.
local function open_menu(menu_id)
  if not menu_id or type(menu_id) ~= 'string' then error('bad argument #1 to \'OpenMenu\' (string expected, got '..type(menu_id)..')', 2) end
  lib.showContext(menu_id)
end

local function close_menu() lib.hideContext() end

--------------------- OBJECT ---------------------

return {
  _MENU = MENU,
  _VERSION = version,
  getmenu = get_menu,
  getversion = get_version,
  getobject = get_object,
  registermenu = register_menu,
  openmenu = open_menu,
  closemenu = close_menu
}
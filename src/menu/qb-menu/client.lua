local MENU <const> = 'qb-menu'
if MENU ~= GetConvar('bridge:menu', 'ox_lib') then error('invalid menu resource name', 0) end
if not IsResourceValid(MENU) then error('menu resource `'..MENU..'` not valid', 0) end

local qb_menu = exports[MENU]
local VERSION <const> = GetResourceMetadata(MENU, 'version', 0)
if VERSION:gsub('%D', '') < ('1.2.0'):gsub('%D', '') then error('incompatible version of '..MENU..' detected (expected 1.2.0 or higher, got '..VERSION..')', 0) end

local RegisteredMenus = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-menu'
local function get_menu() return MENU end

---@return string version
local function get_version() return VERSION end

---@return table
local function get_object() return lib end

---@param menu_id string The ID of the menu to register.
---@param title string The title of the menu.
---@param options {header: string, description: string, icon: string, istitle: boolean?, disabled: boolean?, hasSubMenu: boolean?, onSelect: fun()?, event_type: string?, event: string?, args: table?}[] The options for the menu.
local function register_menu(menu_id, title, options)
  if not menu_id or type(menu_id) ~= 'string' then error('bad argument #1 to \'RegisterMenu\' (string expected, got '..type(menu_id)..')', 2) end
  if not title or type(title) ~= 'string' then error('bad argument #2 to \'RegisterMenu\' (string expected, got '..type(title)..')', 2) end
  if not options then error('bad argument #3 to \'RegisterMenu\' (table expected, got nil)', 2) end
  RegisteredMenus[menu_id] = ConvertMenuOptions({header = title, description = '', icon = '', istitle = true}, options)
end

---@param menu_id string The ID of the menu to update.
local function open_menu(menu_id)
  if not menu_id or type(menu_id) ~= 'string' then error('bad argument #1 to \'OpenMenu\' (string expected, got '..type(menu_id)..')', 2) end
  if not RegisteredMenus[menu_id] then error('menu \''..menu_id..'\' is not registered', 2) end
  qb_menu:openMenu(RegisteredMenus[menu_id])
end

local function close_menu() qb_menu:closeMenu() end

--------------------- OBJECT ---------------------

return {
  _MENU = MENU,
  _VERSION = VERSION,
  getmenu = get_menu,
  getversion = get_version,
  getobject = get_object,
  registermenu = register_menu,
  openmenu = open_menu,
  closemenu = close_menu
}
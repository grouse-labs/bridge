local menu = 'qb-menu'
if menu ~= GetResourceMetadata('bridge', 'menu', 0) then return end
if not IsResourceValid(menu) then return end

local qb_menu = exports[menu]
local version = GetResourceMetadata(menu, 'version', 0)
if version:gsub('%D', '') < ('1.2.0'):gsub('%D', '') then error('incompatible version of '..menu..' detected (expected 1.2.0 or higher, got '..version..')', 0) end
local RegisteredMenus = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-menu'
local function get_menu() return menu end

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
  RegisteredMenus[menu_id] = ConvertMenuOptions(MergeArrays({{header = title, description = '', icon = '', istitle = true}}, options))
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
  _MENU = menu,
  _VERSION = version,
  getmenu = get_menu,
  getversion = get_version,
  getobject = get_object,
  registermenu = register_menu,
  openmenu = open_menu,
  closemenu = close_menu
}
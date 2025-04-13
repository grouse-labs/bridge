local RES_NAME <const> = GetCurrentResourceName()
local RESOURCE <const> = 'bridge'
local get_res_meta = GetResourceMetadata
local VERSION <const>, URL <const>, DES <const> = get_res_meta(RESOURCE, 'version', 0), get_res_meta(RESOURCE, 'url', 0), get_res_meta(RESOURCE, 'description', 0)
local DEBUG_MODE <const> = GetConvar('bridge:debug', 'false') == 'true'
local FRAMEWORK <const> = GetConvar('bridge:framework', 'qb-core')
local CALLBACK <const> = GetConvar('bridge:callback', 'ox_lib')
local TARGET <const> = GetConvar('bridge:target', 'ox_target')
local MENU <const> = GetConvar('bridge:menu', 'ox_lib')
local NOTIFY <const> = GetConvar('bridge:notify', 'native')
local load, load_resource_file = load, LoadResourceFile
-- local export = exports[res]
local is_server = IsDuplicityVersion() == 1
local context = is_server and 'server' or 'client'
if not IsResourceValid then load(load_resource_file(RESOURCE, 'shared/main.lua'), '@bridge/shared/main.lua', 't', _ENV)() end

local module_names = {
  core = FRAMEWORK,
  callback = CALLBACK,
  target = TARGET,
  menu = MENU,
  notify = NOTIFY
}

---@param module_type 'core'|'callback'|'target'|'menu'|'notify'
---@return string?
local function get_module_name(module_type)
  return module_names[module_type]
end

---@param bridge CBridge
---@param module string
---@return function?
local function import(bridge, module)
  local dir = get_module_name(module) and 'src/'..module..'/'..get_module_name(module)..'/' or 'src/'..module..'/'
  local file = load_resource_file(RESOURCE, dir..'shared.lua')
  dir = not file and dir..context..'.lua' or dir
  file = not file and load_resource_file(RESOURCE, dir) or file
  if not file then return end
  local result, err = load(file, '@@'..RESOURCE..'/'..dir, 't', _ENV)
  if not result or err then return error('error occured loading module \''..module..'\''..(err and '\n\t'..err or ''), 3) end
  bridge[module] = result()
  if DEBUG_MODE then print('^3[bridge]^7 - ^2loaded `bridge` module^7 ^5\''..module..'\'^7') end
  return bridge[module]
end

---@param bridge CBridge
---@param index string
---@param ... any
---@return function
local function call(bridge, index, ...)
  local module = rawget(bridge, index) or import(bridge, index)
  if not module then
    -- local method = function(...) return export[index](nil, ...) end
    -- if not ... then bridge[index] = method end
    -- module = method
    error('module \''..index..'\' not found', 2)
  end
  return module
end

---@class CBridge
---@field _VERSION string
---@field _URL string
---@field _DESCRIPTION string
---@field _DEBUG boolean
---@field _CURRENT_RESOURCE string
---@field core CFramework
---@field callback CCallback
---@field target CTarget
---@field menu CMenu
---@field notify CNotify
---@field print fun(...): msg: string Prints a message to the console. <br> If `bridge:debug` is set to `false`, it will not print the message. <br> Returns the message that was printed.
---@field require fun(module_name: string): module: unknown Returns the module if it was found and could be loaded. <br> `mod_name` needs to be a dot seperated path from resource to module. <br> Credits to [Lua Modules Loader](http://lua-users.org/wiki/LuaModulesLoader) by @lua-users & ox_lib's [`require`](https://github.com/overextended/ox_lib/blob/cdf840fc68ace1f4befc78555a7f4f59d2c4d020/imports/require/shared.lua#L149).
local bridge = {
  _VERSION = VERSION,
  _URL = URL,
  _DESCRIPTION = DES,
  _DEBUG = DEBUG_MODE,
  _CURRENT_RESOURCE = RES_NAME,
  print = function(...)
    local msg = '^3['..RES_NAME..']^7 - '..(...)
    if DEBUG_MODE then
      print(msg)
    end
    return msg
  end
}
setmetatable(bridge, {__index = call, __call = call})
_ENV.bridge = bridge
_ENV.require = bridge.require

return bridge
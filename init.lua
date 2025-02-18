local res = 'bridge'
local get_res_meta = GetResourceMetadata
local version, url, des = get_res_meta(res, 'version', 0), get_res_meta(res, 'url', 0), get_res_meta(res, 'description', 0)
local debug_mode = get_res_meta(res, 'debug_mode', 0) == 'true'
local framework = get_res_meta(res, 'framework', 0)
local callback = get_res_meta(res, 'callback', 0)
local target = get_res_meta(res, 'target', 0)
local menu = get_res_meta(res, 'menu', 0)
local notify = get_res_meta(res, 'notify', 0)
local load, load_resource_file = load, LoadResourceFile
-- local export = exports[res]
local is_server = IsDuplicityVersion() == 1
local context = is_server and 'server' or 'client'
if not IsResourceValid then load(load_resource_file(res, 'shared/main.lua'), '@bridge/shared/main.lua', 't', _ENV)() end

---@param module_type 'core'|'callback'|'target'|'menu'|'notify'
---@return string?
local function get_module_name(module_type)
  local module = module_type == 'core' and framework or module_type == 'callback' and callback or module_type == 'target' and target or module_type == 'menu' and menu or module_type == 'notify' and notify or nil
  return module
end

---@param bridge CBridge
---@param module string
---@return function?
local function import(bridge, module)
  local dir = get_module_name(module) and 'modules/'..module..'/'..get_module_name(module)..'/' or 'modules/'..module..'/'
  local file = load_resource_file(res, dir..'shared.lua')
  dir = not file and dir..context..'.lua' or dir
  file = not file and load_resource_file(res, dir) or file
  print(dir)
  if not file then return end
  local result, err = load(file, '@@'..res..'/'..dir, 't', _ENV)
  if not result or err then return error('error occured loading module \''..module..'\''..(err and '\n\t'..err or ''), 3) end
  bridge[module] = result()
  if debug_mode then print('^3[bridge]^7 - ^2loaded `bridge` module^7 ^5\''..module..'\'^7') end
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
---@field core CFramework
---@field callback CCallback
---@field target CTarget
---@field menu CMenu
---@field notify CNotify
---@field require fun(module_name: string): module: module|function|table Returns the module if it was found and could be loaded. <br> `mod_name` needs to be a dot seperated path from resource to module. <br> Credits to [Lua Modules Loader](http://lua-users.org/wiki/LuaModulesLoader) by @lua-users & ox_lib's [`require`](https://github.com/overextended/ox_lib/blob/cdf840fc68ace1f4befc78555a7f4f59d2c4d020/imports/require/shared.lua#L149).
local bridge = {_VERSION = version, _URL = url, _DESCRIPTION = des, _DEBUG = debug_mode}
setmetatable(bridge, {__index = call, __call = call})
_ENV.bridge = bridge
_ENV.require = bridge.require

return bridge
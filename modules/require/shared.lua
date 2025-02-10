---@class module<T>: {[string]: function}
do
  local curr_res = GetCurrentResourceName() or GetInvokingResource()
  local get_res_state = GetResourceState
  local debug_mode = GetResourceMetadata('bridge', 'debug_mode', 0) == 'true'
  local _require = require
  ---@type {[string]: {env: table, contents: (fun(): module|function), exported: module|function}}
  local packages = {}
  local path = './?.lua;./?/init.lua;./?/shared/import.lua'
  local preload = {}
  local curr_pkg = ''

  local function does_res_exist(res_name)
    local state = get_res_state(res_name)
    return state == 'started' or state == 'starting'
  end

  ---@param mod_name string
  ---@param contents function
  local function bld_mod_preload_cache(mod_name, contents)
    preload[mod_name] = function()
      packages[mod_name] = packages[mod_name] or {}
      packages[mod_name].env = _ENV
      packages[mod_name].contents = contents
      if debug_mode then print('^3[bridge]^7 - ^2loaded module^7 ^5\''..mod_name..'\'^7') end
      return packages[mod_name].contents()
    end
  end

  ---@param mod_name string The name of the module to search for. <br> This has to be a dot-separated path to the module. <br> For example, `bridge.init`.
  ---@param pattern string? A pattern to search for the module. <br> This has to be a string with a semicolon-separated list of paths. <br> For example, `./?.lua;./?/init.lua`.
  ---@return string mod_path, string? errmsg The path to the module, and an error message if the module was not found.
  local function search_path(mod_name, pattern) -- Based on the Lua [`package.searchpath`](https://github.com/lua/lua/blob/c1dc08e8e8e22af9902a6341b4a9a9a7811954cc/loadlib.c#L474) function, [Lua Modules Loader](http://lua-users.org/wiki/LuaModulesLoader) by @lua-users & ox_lib's [`package.searchpath`](https://github.com/overextended/ox_lib/blob/cdf840fc68ace1f4befc78555a7f4f59d2c4d020/imports/require/shared.lua#L50) function.
    if type(mod_name) ~= 'string' then error('bad argument #1 to \'search_path\' (string expected, got '..type(mod_name)..')', 2) end
    local mod_path = mod_name:gsub('%.', '/')
    local resource, dir, contents = mod_name:match('^%@?(%w+%_?%-?%w+)'), '', ''
    local errmsg = nil
    pattern = pattern or path
    if not does_res_exist(resource) then resource = curr_res; mod_path = curr_res..'/'..mod_path end
    for subpath in pattern:gmatch('[^;]+') do
      local file = subpath:gsub('%?', mod_path)
      dir = file:match('^./%@?%w+%_?%-?%w+(.*)')
      mod_name = resource..dir:gsub('%/', '.'):gsub('.lua', '') --[[@as string]]
      if preload[mod_name] then return mod_name end
      contents = LoadResourceFile(resource, dir)
      if contents then
        local module_fn, err = load(contents, '@@'..resource..dir, 't', _ENV)
        if module_fn then
          bld_mod_preload_cache(mod_name, module_fn)
          break
        end
        errmsg = (errmsg or '')..(err and '\n\t'..err or '')
      end
    end
    return preload[mod_name] and mod_name or false, errmsg
  end

  ---@type (fun(mod_name: string, env: table?): module|function|false, string)[]
  local loaders = {
    ---@param mod_name string
    ---@return module|function|table|false result, string errmsg
    function(mod_name)
      local success, contents = pcall(_require, mod_name)
      if success then
        mod_name = mod_name:match('([^%.]+)$')
        bld_mod_preload_cache(mod_name, function() return contents end)
        return preload[mod_name](), mod_name
      end
      return false, contents
    end,
    ---@param mod_name string
    ---@return module|function|table|false result, string errmsg
    function(mod_name)
      local mod_path, err = search_path(mod_name)
      if mod_path and not err then
        local package = packages[mod_path]
        if package then return package.exported, mod_path end
        return preload[mod_path] and preload[mod_path](), mod_path
      end
      return false, 'module \''..mod_name..'\' not found'..(err and '\n\t'..err or '')
    end
  }

  ---@param mod_name string The name of the module to load. <br> This has to be a dot-separated path to the module. <br> For example, `bridge.init`.
  ---@return module|function|table|false result, string errmsg
  local function load_module(mod_name)
    local errmsg = ''
    for i = 1, #loaders do
      local result, err = loaders[i](mod_name)
      if result ~= false then
        curr_pkg = err
        packages[curr_pkg].exported = result or result == nil
        return packages[curr_pkg].exported, curr_pkg
      end
      errmsg = errmsg..'\n\t'..err
    end
    return false, errmsg
  end

  ---@param mod_name string The name of the module to require. <br> This has to be a dot-separated path to the module. <br> For example, `bridge.init`.
  ---@return module|function|table module Returns `module` if the file is a module or function.
  local function require(mod_name) -- Returns the module if it was found and could be loaded. <br> `mod_name` needs to be a dot seperated path from resource to module. <br> Credits to [Lua Modules Loader](http://lua-users.org/wiki/LuaModulesLoader) by @lua-users & ox_lib's [`require`](https://github.com/overextended/ox_lib/blob/cdf840fc68ace1f4befc78555a7f4f59d2c4d020/imports/require/shared.lua#L149).
    if type(mod_name) ~= 'string' then error('bad argument #1 to \'require\' (string expected, got '..type(mod_name)..')', 2) end
    local errmsg = 'bad argument #1 to \'require\' (module \''..mod_name..'\' not found)'
    if packages[mod_name] then return packages[mod_name].exported end
    local result, err = load_module(mod_name)
    if result then return result end
    error(errmsg..'\n\t'..err, 2)
  end

  return require
end
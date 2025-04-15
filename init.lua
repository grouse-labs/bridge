if _VERSION:gsub('%D', '') < ('5.4'):gsub('%D', '') then error('Lua version 5.4 is required', 0) end

local RES_NAME <const> = GetCurrentResourceName()
local BRIDGE <const> = 'bridge'

local get_res_meta = GetResourceMetadata
local VERSION <const> = get_res_meta(BRIDGE, 'version', 0)
local URL <const> = get_res_meta(BRIDGE, 'url', 0)
local DES <const> = get_res_meta(BRIDGE, 'description', 0)

local get_convar = GetConvar
local DEBUG_MODE <const> = get_convar('bridge:debug', 'false') == 'true'
local FRAMEWORK <const> = get_convar('bridge:framework', 'qb-core')
local CALLBACK <const> = get_convar('bridge:callback', 'ox_lib')
local TARGET <const> = get_convar('bridge:target', 'ox_target')
local MENU <const> = get_convar('bridge:menu', 'ox_lib')
local NOTIFY <const> = get_convar('bridge:notify', 'native')

local load, load_resource_file = load, LoadResourceFile
local get_resource_state = GetResourceState
-- local export = exports[res]

local CONTEXT <const> = IsDuplicityVersion() == 1 and 'server' or 'client'

---@enum (key) module_types
local module_names <const> = {
  core = FRAMEWORK,
  callback = CALLBACK,
  target = TARGET,
  menu = MENU,
  notify = NOTIFY
}

local resource_states <const> = {
  ---@diagnostic disable-next-line: duplicate-doc-alias
  ---@enum (key) valid_states
  valid = {['started'] = true, ['starting'] = true},
  ---@diagnostic disable-next-line: duplicate-doc-alias
  ---@enum (key) invalid_states
  invalid = {['missing'] = true, ['unknown'] = true, ['stopped'] = true, ['stopping'] = true}
}

local job_types <const> = {
  ---@enum (key) leo_jobs
  [GetResourceMetadata('bridge', 'job_types', 0)--[[@as 'leo']]] = json.decode(GetResourceMetadata('bridge', 'job_types_extra', 0)),
  ---@enum (key) ems_jobs
  [GetResourceMetadata('bridge', 'job_types', 1)--[[@as 'ems']]] = json.decode(GetResourceMetadata('bridge', 'job_types_extra', 1))
}

--#TODO:
--#[ ] Make ConVar set constants mutable.

--------------------- FUNCTIONS ---------------------

---@param module_type module_types
---@return string?
local function get_module_name(module_type)
  return module_names[module_type]
end

---@param bridge CBridge
---@param module string
---@return function?
local function import(bridge, module)
  local dir = get_module_name(module) and 'src/'..module..'/'..get_module_name(module)..'/' or 'src/'..module..'/'
  local file = load_resource_file(BRIDGE, dir..CONTEXT..'.lua')
  local shared = load_resource_file(BRIDGE, dir..'shared.lua')

  file = shared and file and string.format('%s\n%s', shared, file) or shared or file

  if not file then return end
  local result, err = load(file, '@@'..BRIDGE..'/'..dir..CONTEXT, 't', _ENV)
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
    error('bridge module \''..index..'\' not found', 2)
  end
  return module
end

---@param tbl table<any, any>|any? The table to iterate over.
---@param fn fun(key: any, value: any?): boolean The evaluation function.
---@return any key, any value The key-value pair that matches the evaluation function.
local function for_each(tbl, fn)
  tbl = type(tbl) ~= 'table' and {tbl} or tbl
  for k, v in pairs(tbl) do
    if fn(k, v) then return k, v end
  end
end

---@param job_name string The name of the job to check for.
---@return string? job_type
local function get_job_type(job_name)
  return for_each(job_types, function(_, v) return v[job_name] end)
end

---@param resource_name string
---@return boolean valid
function IsResourceValid(resource_name)
  local state = get_resource_state(resource_name)
  return resource_states.valid[state] and not resource_states.invalid[state]
end

---@param data {name: string?, label: string, grade: {name: string, level: integer}|integer, grade_name: string?, grade_label: string?, salary: integer?, payment: integer?}? The job data to convert.
---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number}? job_data The converted job data.
function ConvertPlayerJobData(data)
  if not data then return end
  local grade_type = type(data.grade)
  local name = data.name or data.label:lower()
  return {
    name = name,
    label = data.label,
    grade = grade_type ~= 'table' and data.grade or data.grade.level,
    grade_name = grade_type ~= 'table' and data.grade_name or data.grade.name,
    grade_label = grade_type ~= 'table' and data.grade_label or data.grade.name,
    job_type = for_each(job_types, function(k, v) return v[name] and k end),
    salary = data.salary or data.payment
  }
end

---@param data {name: string?, label: string, grade: {name: string, level: integer}|integer?, grade_name: string?} The gang data to convert.
---@return {name: string, label: string, grade: number, grade_name: string}? gang_data The gang data for the `player`.
function ConvertGangData(data)
  if not data then return end
  local grade_type = type(data.grade)
  return {
    name = data.name or 'none',
    label = data.label,
    grade = grade_type ~= 'table' and data.grade or data.grade.level or 0,
    grade_name = grade_type ~= 'table' and data.grade_name or data.grade.name
  }
end

---@param name string The name of the job.
---@param data {name: string?, label: string, payment: number?, salary: integer?, type: string?, grades: table<string|integer, {name: string?, label: string, salary: integer?, payment: integer}>?, grade: table<string|integer, {name: string?, label: string, salary: integer?, payment: integer}>} The job data to convert.
---@return {name: string, label: string, _type: string, grades: {[number]: {label: string, salary: number}}}? job_data The converted job data.
function ConvertJobData(name, data)
  if not data then return end
  local grades = {}
  local fnd_grades = data.grades or data.grade
  for k, v in pairs(fnd_grades) do
    local new_key = type(k) ~= 'number' and tonumber(k) and tonumber(k) or k
    grades[new_key] = {label = v.name or v.label, salary = v.salary or v.payment}
  end
  name = name or data.label:lower()
  return {
    name = name,
    label = data.label,
    _type = data.type or get_job_type(name),
    grades = grades
  }
end

if CONTEXT == 'server' then

  ---@param src integer|string? The source to check.
  ---@return boolean? valid
  function IsSrcAPlayer(src)
    src = src or source
    return tonumber(src) and tonumber(src) > 0 and DoesPlayerExist(src)
  end
else

  ---@param arr1 any[]|any? The first array to merge.
  ---@param arr2 any[]|any? The second array to merge.
  ---@return any[]|any merged The merged array. 
  local function merge_arrays(arr1, arr2)
    if not arr1 or not arr2 then return arr1 or arr2 end
    arr1 = type(arr1) ~= 'table' and {arr1} or arr1
    arr2 = type(arr2) ~= 'table' and {arr2} or arr2
    for i = 1, #arr2 do arr1[#arr1 + 1] = arr2[i] end
    return arr1
  end

  ---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: fun(entity: integer, distance: number)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
  ---@return table[]? converted_options The converted options for the target.
  function ConvertTargetOptions(options)
    if not options then return end
    local converted_options = {}
    for i = 1, #options do
      local option = options[i]
      if not option then error('invalid target option at index '..i, 3) end
      local label = option.label
      if not label or type(label) ~= 'string' then error('invalid target option label at index '..i, 3) end
      converted_options[i] = TARGET == 'ox_target' and {
        name = option.name or label,
        label = label,
        icon = option.icon,
        distance = option.distance or 2.5,
        items = option.item,
        canInteract = option.canInteract,
        onSelect = option.onSelect,
        event = option.event_type == 'client' and option.event or nil,
        serverEvent = option.event_type == 'server' and option.event or nil,
        command = option.event_type == 'command' and option.event or nil,
        groups = merge_arrays(option.jobs, option.gangs)
      } or {
        type = option.event_type,
        event = option.event,
        icon = option.icon,
        label = label,
        item = option.item,
        canInteract = option.canInteract,
        action = option.onSelect,
        job = option.jobs,
        gang = option.gangs
      }
    end
    return converted_options
  end

end

--------------------- OBJECT ---------------------

local glib = glib or load(LoadResourceFile('gr_lib', 'init.lua'), '@@gr_lib/shared/init.lua', 't', _ENV)()

---@version 5.4
---@class CBridge
---@field _VERSION string
---@field _URL string
---@field _DESCRIPTION string
---@field _DEBUG boolean
---@field _RESOURCE string
---@field _CONTEXT string
---@field core CFramework
---@field callback CCallback
---@field target CTarget
---@field menu CMenu
---@field notify CNotify
---@field print fun(...): msg: string Prints a message to the console. <br> If `bridge:debug` is set to `false`, it will not print the message. <br> Returns the message that was printed.
local bridge = setmetatable({
  _VERSION = VERSION,
  _URL = URL,
  _DESCRIPTION = DES,
  _DEBUG = DEBUG_MODE,
  _RESOURCE = RES_NAME,
  _CONTEXT = CONTEXT,
  print = function(...)
    local msg = '^3['..RES_NAME..']^7 - '..(...)
    if DEBUG_MODE then
      print(msg)
    end
    return msg
  end
}, {
  __name = BRIDGE,
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('%s: %p', BRIDGE, t)
    if DEBUG_MODE then
      local msg = string.format('^3[%s]^7 - ^2bridge library^7 ^5\'%s\'^7 v^5%s^7\n%s', RES_NAME, BRIDGE, VERSION, address)
      for k, v in pairs(t) do
        if type(v) == 'table' then
          msg = msg..string.format('\n^3[%s]^7 - ^2`bridge` module^7 ^5\'%s\'^7 ^2is loaded^7\n%s: %p', RES_NAME, k, k, v)
        end
      end
    return msg
    end
    return address
  end,
  __index = call,
  __call = call
})

_ENV.bridge = bridge
_ENV.glib = glib

return bridge
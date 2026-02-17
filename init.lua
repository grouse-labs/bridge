BRIDGE_VERSIONS = enum 'eBridgeVersions'

--[[{
  lua = '5.4',
  framework = {
    ['es_extended'] = '1.13.4',
    ['qb-core'] = '1.3.0',
    ['qbx_core'] = '1.23.0'
  },
  callback = {
    ['gr_lib'] = '1.0.0',
    ['ox_lib'] = '3.30.6'
  },
  target = {
    ['ox_target'] = '1.17.2',
    ['qb-target'] = '5.5.0'
  },
  menu = {
    ['ox_lib'] = '3.30.6',
    ['qb-menu'] = '1.2.0'
  },
  notify = {
    ['es_extended'] = '1.13.4',
    ['qb-core'] = '1.3.0',
    ['qbx_core'] = '1.23.0'
  }
  doorlock = {
		['ox_doorlock'] = '1.17.2',
		['qb-doorlock'] = '2.0.0'
	},
	weather = {
    ['Renewed-Weathersync'] = '1.1.8',
		['qb-weathersync'] = '2.1.1'
	}
}]]

local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('lua') --[[@as string]]
if _VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then error(('Lua version `%s` is required'):format(MIN_VERSION), 0) end

local RES_NAME <const> = GetCurrentResourceName()
local BRIDGE <const> = 'bridge'

local get_res_meta = GetResourceMetadata
local VERSION <const> = get_res_meta(BRIDGE, 'version', 0)
local URL <const> = get_res_meta(BRIDGE, 'url', 0)
local DES <const> = get_res_meta(BRIDGE, 'description', 0)

local get_convar = GetConvar
local DEBUG_MODE <const> = get_convar('grinch:debug', 'false') == 'true'

--------------------- RESOURCE DETECTION ---------------------

local FALLBACKS <const> = {qbx = 'qbx_core', qb = 'qb-core', esx = 'es_extended'}

---@param resources string[]
---@return string
local function detect_resource(resources)
  local lim = #resources
  for i = 1, lim do
    local resource = resources[i]
    if IsResourceValid(resource) then
      return resource
    end
  end
  return 'null'
end

local FRAMEWORK do
  FRAMEWORK = get_convar('grinch:framework', 'null'):lower()
  if FRAMEWORK == 'null' then
    FRAMEWORK = detect_resource({'qbx_core', 'es_extended', 'qb-core'})
  end
  FRAMEWORK = FALLBACKS[FRAMEWORK] or FRAMEWORK
end
local CALLBACK do
  CALLBACK = get_convar('grinch:callback', 'null'):lower()
  if CALLBACK == 'null' then
    CALLBACK = detect_resource({'ox_lib', 'gr_lib'})
  end
end
local TARGET do
  TARGET = get_convar('grinch:target', 'null'):lower()
  if TARGET == 'null' then
    TARGET = detect_resource({'ox_target', 'qb-target'})
  end
end
local MENU do
  MENU = get_convar('grinch:menu', 'null'):lower()
  if MENU == 'null' then
    MENU = detect_resource({'ox_lib', 'qb-menu'})
  end
end
local NOTIFY do
  NOTIFY = get_convar('grinch:notify', 'null'):lower()
  if NOTIFY == 'null' then
    NOTIFY = detect_resource({'es_extended', 'qbx_core', 'qb-core'})
  end
  NOTIFY = NOTIFY ~= 'null' and NOTIFY or 'native'
end
local DOORLOCK do
  DOORLOCK = get_convar('grinch:doorlock', 'null'):lower()
  if DOORLOCK == 'null' then
    DOORLOCK = detect_resource({'ox_doorlock', 'qb-doorlock'})
  end
end
local WEATHER do
  WEATHER = get_convar('grinch:weather', 'null'):lower()
  if WEATHER == 'null' then
    WEATHER = detect_resource({'Renewed-Weathersync', 'qb-weathersync'})
  end
end

------------------------------------------

local load, load_resource_file = load, LoadResourceFile
-- local export = exports[res]

local CONTEXT <const> = IsDuplicityVersion() == 1 and 'server' or 'client'

---@enum (key) module_types
MODULE_NAMES = {
  core = FRAMEWORK,
  callback = CALLBACK,
  target = TARGET,
  menu = MENU,
  notify = NOTIFY,
  doorlock = DOORLOCK,
  weather = WEATHER
}

AddConvarChangeListener('', function(name, _)
  if not MODULE_NAMES[name:gsub('grinch:')] then return end
  MODULE_NAMES[name:gsub('grinch:')] = get_convar(name, '')
end)

--------------------- BRIDGE ---------------------

---@param module_type module_types
---@return string?
local function get_module_name(module_type)
  return MODULE_NAMES[module_type]
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
---@field doorlock CDoorlock
---@field weather CWeather
---@field print fun(...): msg: string Prints a message to the console. <br> If `grinch:debug` is set to `false`, it will not print the message. <br> Returns the message that was printed.
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

--------------------- ENV FUNCTIONS ---------------------
local job_types = enum 'job_types' {
  ---@enum (key) leo_jobs
  [get_res_meta('bridge', 'job_types', 0)--[[@as 'leo']]] = json.decode(get_res_meta('bridge', 'job_types_extra', 0)),
  ---@enum (key) ems_jobs
  [get_res_meta('bridge', 'job_types', 1)--[[@as 'ems']]] = json.decode(get_res_meta('bridge', 'job_types_extra', 1))
}

---@param job string
---@return string
function GetJobType(job) return job_types:search(job) --[[@as string]] end

---@param _type string
---@return string[] jobs
function GetTypeJobs(_type)
  local _, result = job_types:search(_type)
  local jobs = {}
  if not result or type(result) ~= 'table' then return jobs end
  for job in pairs(result--[[@as table]]) do jobs[#jobs + 1] = job end
  return jobs
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
    job_type = job_types:search(name),
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
    _type = data.type or job_types:search(name),
    grades = grades
  }
end

if CONTEXT == 'server' then
  -- glib.github.check(BRIDGE, 'grouse-labs', BRIDGE)
else

  if NOTIFY == 'native' then
    RegisterNetEvent('grinch:client:Notify', bridge.notify.text)
    RegisterNetEvent('grinch:client:ItemNotify', bridge.notify.item)
  end

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

  ---@param options target_options[] The options for the target.
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
        anyItem  = type(option.item) == 'table' and #option.item > 0,
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
        name = option.name,
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

  ---@type {[string]: [string, string|fun(tag, text): string][]} The HTML to Markdown conversion table.
  local HTML_TO_MD <const> = {
    ['TEXT'] = {
      {'<pre>%s?(.-)%s?</pre>', '```\n%1\n```'},
      {'<(h[1-6])>%s?(.-)%s?</%1>', function(tag, text)
        local level = tonumber(tag:sub(2)) or 1
        return string.rep('#', level)..' '..text
      end},
      {'<b>%s?(.-)%s?</b>', '**%1**'},
      {'<strong>%s?(.-)%s?</strong>', '**%1**'},
      {'<i>%s?(.-)%s?</i>', '*%1*'},
      {'<em>%s?(.-)%s?</em>', '*%1*'},
      {'<tt>%s?(.-)%s?</tt>', '`%1`'},
      {'<code>%s?(.-)%s?</code>', '```\n%1\n```'}
    },
    ['LINK'] = {
      {'<a href=%p?(.-)%p?>(.-)</a>', '[%2](%1)'}
    },
    ['LIST'] = {
      {'<ul>(.-)</ul>', '%1'},
      {'<li>(.-)</li>', '- %1'}
    },
    ['BLOCKQUOTE'] = {
      {'<blockquote>(.-)</blockquote>', '> %1'}
    },
    ['IMAGE'] = {
      {'<img src=%p?(.-)%p? alt=%p?(.-)%p?>', '![%2](%1)'},
      {'<img src=%p?(.-)%p? width=%p?%w+%%?%p? height=%p?%w+%%?%p?>', '![image](%1)'}
    },
    ['FORMAT'] = {
      {'<p>(.-)</p>', '%1'},
      {'<center>(.-)</center>', '%1'},
      {'<br>', '\n'}
    }
  }

  ---@type {[string]: [string, string|fun(tag, text): string][]} The Markdown to HTML conversion table.
  local MD_TO_HTML <const> = {
    ['TEXT'] = {
      {'```(.-)```', '<pre>%1</pre>'},
      {'#%s?(.-)\n', '<h1>%1</h1>\n'},
      {'##%s?(.-)\n', '<h2>%1</h2>\n'},
      {'###%s?(.-)\n', '<h3>%1</h3>\n'},
      {'####%s?(.-)\n', '<h4>%1</h4>\n'},
      {'#####%s?(.-)\n', '<h5>%1</h5>\n'},
      {'######%s?(.-)\n', '<h6>%1</h6>\n'},
      {'%*%*%s?(.-)%s?%*%*', '<strong>%1</strong>'},
      {'%*%s?(.-)%s?%*', '<em>%1</em>'},
      {'__%s?(.-)%s?__', '<u>%1</u>'},
      {'~~%s?(.-)%s?~~', '<s>%1</s>'}
    },
    ['LINK'] = {
      {'%[(.-)%]%((.-)%)', '<a href="%2">%1</a>'}
    },
    ['LIST'] = {
      {'\n%- (.-)', '<li>%1</li>'},
      {'<li>(.-)</li>', '<ul>%1</ul>'}
    },
    ['BLOCKQUOTE'] = {
      {'\n> (.-)', '<blockquote>%1</blockquote>'},
      {'<blockquote>(.-)</blockquote>', '<blockquote>%1</blockquote>'}
    },
    ['IMAGE'] = {
      {'!%[(.-)%]%((.-)%)', '<img src="%2" alt="%1">'}
    },
    ['FORMAT'] = {
      {'\n', '<br>'}
    }
  }

  ---@param tag string The tag to check.
  ---@return boolean is_html_tag The tag is an HTML tag.
  local function is_html_tag(tag) return tag:match('^<%a+>$') end

  ---@param text string The text to convert.
  ---@param format 'HTML'|'MD'? The format to convert to. <br> If `nil`, the format is determined by the text and resource manifest.
  ---@return string? converted_text The converted text.
  function ConvertMDHTML(text, format)
    if not text then return end
    if not format then format = MENU == 'ox_lib' and 'MD' or 'HTML' end
    if (is_html_tag(text) and format == 'HTML') or (not is_html_tag(text) and format == 'MD') then return text end
    local pattern_table = format == 'HTML' and MD_TO_HTML or HTML_TO_MD
    for _, patterns in pairs(pattern_table) do
      for i = 1, #patterns do
        local pattern = patterns[i]
        text = text:gsub(pattern[1], pattern[2])
      end
    end
    return text
  end

  ---@param options {header: string, description: string, icon: string, istitle: boolean?, disabled: boolean?, hasSubMenu: boolean?, onSelect: fun()?, event_type: string?, event: string?, args: table?}[] The options for the menu.
  ---@param ... any
  ---@return table[]? converted_options The converted options for the menu.
  function ConvertMenuOptions(options, ...)
    if not options then return end
    local converted_options = {}
    options = MENU == 'ox_lib' and options or merge_arrays(options, ...)
    for i = 1, #options do
      local option = options[i]
      if not option then error('invalid menu option at index '..i, 3) end
      local header = option.header
      if not header or type(header) ~= 'string' then error('invalid menu option header at index '..i, 3) end
      local description = option.description
      if not description or type(description) ~= 'string' then error('invalid menu option description at index '..i, 3) end
      converted_options[i] = MENU == 'ox_lib' and {
        title = ConvertMDHTML(header),
        description = ConvertMDHTML(description),
        icon = option.icon,
        isTitle = option.istitle,
        disabled = option.disabled,
        hasSubMenu = option.hasSubMenu,
        onSelect = option.onSelect,
        event = option.event_type == 'client' and option.event or nil,
        serverEvent = option.event_type == 'server' and option.event or nil,
        command = option.event_type == 'command' and option.event or nil,
        args = option.args
      } or {
        header = ConvertMDHTML(header),
        txt = ConvertMDHTML(description),
        icon = option.icon,
        isMenuHeader = option.istitle,
        disabled = option.disabled,
        params = {
          isAction = option.onSelect ~= nil,
          action = option.onSelect,
          event = option.event,
          isServer = option.event and option.event_type == 'server',
          args = option.args
        }
      }
    end
    return converted_options
  end

end

return bridge
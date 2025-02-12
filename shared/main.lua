local get_resource_state = GetResourceState

local resource_states = {
  valid = {['started'] = true, ['starting'] = true},
  invalid = {['missing'] = true, ['unknown'] = true, ['stopped'] = true, ['stopping'] = true}
}

---@param resource_name string
---@return boolean valid
function IsResourceValid(resource_name)
  local state = get_resource_state(resource_name)
  return resource_states.valid[state] and not resource_states.invalid[state]
end

function IsSrcValid(src)
  src = src or source
  local src_type = type(src)
  src = src_type == 'string' and tonumber(src) or src
  return src_type == 'number' and src > 0
end

---@param tbl table<any, any>|any? The table to iterate over.
---@param fn fun(key: any, value: any?): boolean The evaluation function.
---@return any value The value that matches the evaluation function.
local function for_each(tbl, fn)
  tbl = type(tbl) ~= 'table' and {tbl} or tbl
  for k, v in pairs(tbl) do
    if fn(k, v) then return v end
  end
end

-- If the framework is ESX, the enum job_types below is used to determine the job type of the player.
-- Add the job type to the job_types enum if it is not already present, as well as any additional jobs that should be considered part of that job type.
---@enum job_types
local job_types = {['leo'] = {['police'] = true, ['fib'] = true, ['sheriff'] = true}, ['ems'] = {['ambulance'] = true, ['fire'] = true}}

---@param data table The job data to convert.
---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number}? job_data The converted job data.
function ConvertJobData(data)
  if not data then return end
  if data.job_type then return data end
  local grade_type = type(data.grade)
  return {
    name = data.name or 'unemployed',
    label = data.label,
    grade = grade_type ~= 'table' and data.grade or data.grade.level,
    grade_name = grade_type ~= 'table' and data.grade_name or data.grade.name,
    grade_label = grade_type ~= 'table' and data.grade_label or data.grade.name,
    job_type = for_each(job_types, function(k, v) return v[data.name] and k end),
    salary = data.salary or data.payment
  }
end

---@param data table The gang data to convert.
---@return {name: string, label: string, grade: number, grade_name: string}? gang_data The gang data for the `player`.
function ConvertGangData(data)
  if not data then return end
  if data.grade_name then return data end
  local grade_type = type(data.grade)
  return {
    name = data.name or 'none',
    label = data.label,
    grade = grade_type ~= 'table' and data.grade or data.grade.level or 0,
    grade_name = grade_type ~= 'table' and data.grade_name or data.grade.name
  }
end

---@param arr1 any[]|any? The first array to merge.
---@param arr2 any[]|any? The second array to merge.
---@return any[]|any merged The merged array. 
function MergeArrays(arr1, arr2)
  if not arr1 or not arr2 then return arr1 or arr2 end
  arr1 = type(arr1) ~= 'table' and {arr1} or arr1
  arr2 = type(arr2) ~= 'table' and {arr2} or arr2
  for i = 1, #arr2 do arr1[#arr1 + 1] = arr2[i] end
  return arr1
end

local target = GetResourceMetadata('bridge', 'target', 0)

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
    converted_options[i] = target == 'ox_target' and {
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
      groups = MergeArrays(option.jobs, option.gangs)
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

local menu = GetResourceMetadata('bridge', 'menu', 0)

---@param tag string The tag to check.
---@return boolean is_html_tag The tag is an HTML tag.
local function is_html_tag(tag) return tag:match('^<%a+>$') end

---@param text string The text to convert.
---@param format 'HTML'|'MD'? The format to convert to. <br> If `nil`, the format is determined by the text and resource manifest.
---@return string? converted_text The converted text.
function ConvertMDHTML(text, format)
  if not text then return end
  if not format then format = menu == 'ox_lib' and 'MD' or 'HTML' end
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
---@return table[]? converted_options The converted options for the menu.
function ConvertMenuOptions(options)
  if not options then return end
  local converted_options = {}
  for i = 1, #options do
    local option = options[i]
    if not option then error('invalid menu option at index '..i, 3) end
    local header = option.header
    if not header or type(header) ~= 'string' then error('invalid menu option header at index '..i, 3) end
    local description = option.description
    if not description or type(description) ~= 'string' then error('invalid menu option description at index '..i, 3) end
    converted_options[i] = menu == 'ox_lib' and {
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
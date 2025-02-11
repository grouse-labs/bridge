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
local function merge_arrays(arr1, arr2)
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
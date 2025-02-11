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
    name = data.name,
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
    name = data.name,
    label = data.label,
    grade = grade_type ~= 'table' and data.grade or data.grade.level,
    grade_name = grade_type ~= 'table' and data.grade_name or data.grade.name
  }
end
---@diagnostic disable: duplicate-set-field
---@diagnostic disable-next-line: duplicate-doc-alias
---@enum core_events
local EVENTS <const> = {
  load = 'esx:playerLoaded',
  unload = 'esx:onPlayerLogout',
  job = 'esx:setJob',
  player = 'esx:setPlayerData'
}

local PlayerData = {}
local JobData = {}

--------------------- FUNCTIONS ---------------------

---@param event_type 'load'|'unload'|'job'|'player'
---@return core_events
function core.getevent(event_type)
  if type(event_type) ~= 'string' then error('bad argument #1 to \'getevent\' (string expected, got '..type(event_type)..')', 2) end
  event_type = event_type:lower()
  return EVENTS[event_type] or error('bad argument #1 to \'getevent\' (invalid event type)', 2)
end

--------------------- PLAYER ---------------------

---@return table PlayerData The player data of the `player`.
function core.getplayerdata()
  PlayerData = not next(PlayerData) and ESX.GetPlayerData() or PlayerData
  return PlayerData
end

---@return string identifier The identifier of the `player`.
function core.getplayeridentifier()
  return core.getplayerdata().identifier
end

---@return string name The name of the `player`.
local function get_name()
  return core.getplayerdata().firstname..' '..core.getplayerdata().lastname
end

---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data of the `player`.
function core.getplayerjob()
  JobData = not next(JobData) and ConvertPlayerJobData(core.getplayerdata().job) or JobData
  if not JobData or not next(JobData) then error('error calling \'getplayerjob\' (job data not found)', 2) end
  return JobData
end

-- ---@return {name: string, label: string, grade: number, grade_name: string} gang_data The gang data for the `player`.
-- function core.getplayergang()
--   local data = ConvertGangData(core.getplayerdata().gang)
--   if not data or not next(data) then error('error calling \'getplayergang\' (gang data not found)', 2) end
--   return data
-- end

---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
function core.doesplayerhavegroup(groups)
  if type(groups) == 'string' then groups = {groups} end
  if type(groups) ~= 'table' then error('bad argument #1 to \'doesplayerhavegroup\' (string or table expected, got '..type(groups)..')', 2) end
  -- local player = core.getplayerdata()
  local job = JobData
  -- local gang = ConvertGangData(player.gang)
  for i = 1, #groups do
    local group = groups[i]
    if job and (job.name == group or job.label == group or job.job_type == group) then return true end
    -- if gang and (gang.name == group or gang.label == group) then return true end
  end
  return false
end

---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
function core.getplayermoney(money_type)
  if type(money_type) ~= 'string' then error('bad argument #2 to \'getplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  money_type = money_type == 'cash' and 'money' or money_type:lower()
  return core.getplayerdata().accounts[money_type]
end

---@return boolean is_downed Whether the `player` is downed.
function core.isplayerdowned()
  return core.getplayerdata().dead
end

--------------------- EVENTS ---------------------

AddEventHandler(EVENTS.player, function(key, val, _)
  PlayerData[key] = val
end)

for event, name in pairs(EVENTS) do
  RegisterNetEvent(name, function(...)
    local args = {...}
    if event == 'load' then
      PlayerData = args[1]
    elseif event == 'unload' then
      PlayerData = {}
    elseif event == 'job' then
      PlayerData.job = args[1]
      JobData = ConvertPlayerJobData(args[1]) or JobData
    -- elseif event == 'player' then
    --   PlayerData[args[1]] = args[2]
    end
  end)
end

--------------------- OBJECT ---------------------
getmetatable(core).__newindex = function() error('attempt to edit a read-only object', 2) end

return core

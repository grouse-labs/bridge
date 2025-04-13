local FRAMEWORK <const> = 'es_extended'
if FRAMEWORK ~= GetConvar('bridge:framework', 'qbx_core') then error('invalid framework resource name', 0) end
if not IsResourceValid(FRAMEWORK) then error('framework resource `'..FRAMEWORK..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(FRAMEWORK, 'version', 0)
if VERSION:gsub('%D', '') < ('1.12.4'):gsub('%D', '') then error('incompatible version of '..FRAMEWORK..' detected (expected 1.12.4 or higher, got '..VERSION..')', 0) end

local EVENTS <const> = {
  load = 'esx:playerLoaded',
  unload = 'esx:onPlayerLogout',
  job = 'esx:setJob',
  player = 'esx:setPlayerData'
}
local ESX = exports[FRAMEWORK]:getSharedObject()
local PlayerData = {}

--------------------- FUNCTIONS ---------------------

---@return 'es_extended'
local function get_framework() return FRAMEWORK end

---@return string version
local function get_version() return VERSION end

---@return {load: string, unload: string, job: string, player: string} Events
local function get_events() return EVENTS end

---@return table ESX
local function get_object() return ESX end

local function get_player()
  PlayerData = not next(PlayerData) and ESX.GetPlayerData() or PlayerData
  return PlayerData
end

---@return string|integer identifier The identifier of the `player`.
local function get_identifier()
  return get_player().identifier
end

---@return string name The name of the `player`.
local function get_name()
  return get_player().firstname..' '..get_player().lastname
end

---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data of the `player`.
local function get_job()
  local data = ConvertPlayerJobData(get_player().job)
  if not data or not next(data) then error('error calling \'getplayerjob\' (job data not found)', 2) end
  return data
end

-- ---@return {name: string, label: string, grade: number, grade_name: string} gang_data The gang data for the `player`.
-- local function get_gang()
--   local data = ConvertGangData(get_player().gang)
--   if not data or not next(data) then error('error calling \'getplayergang\' (gang data not found)', 2) end
--   return data
-- end

---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
local function has_group(groups)
  if type(groups) == 'string' then groups = {groups} end
  if type(groups) ~= 'table' then error('bad argument #1 to \'hasgroup\' (string or table expected, got '..type(groups)..')', 2) end
  local player = get_player()
  local job = ConvertPlayerJobData(player.job)
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
local function get_money(money_type)
  if type(money_type) ~= 'string' then error('bad argument #2 to \'getplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  money_type = money_type == 'cash' and 'money' or money_type
  return get_player().accounts[money_type:lower()]
end

---@return boolean is_downed Whether the `player` is downed.
local function is_downed()
  return get_player().dead
end

--------------------- EVENTS ---------------------

for event, name in pairs(EVENTS) do
  RegisterNetEvent(name, function(data)
    if event == 'load' then
      PlayerData = ESX.GetPlayerData()
    elseif event == 'unload' then
      PlayerData = {}
    elseif event == 'job' then
      PlayerData.job = ConvertPlayerJobData(data)
    elseif event == 'player' then
      PlayerData = data
    end
  end)
end

--------------------- OBJECT ---------------------

return {
  _FRAMEWORK = FRAMEWORK,
  _VERSION = VERSION,
  _EVENTS = EVENTS,
  getframework = get_framework,
  getversion = get_version,
  getevents = get_events,
  getobject = get_object,
  getplayer = get_player,
  getplayeridentifier = get_identifier,
  getplayername = get_name,
  getplayerjob = get_job,
  -- getplayergang = get_gang,
  doesplayerhavegroup = has_group,
  getplayermoney = get_money,
  isplayerdowned = is_downed
}

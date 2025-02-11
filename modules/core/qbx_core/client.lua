local framework = 'qbx_core'
if framework ~= GetResourceMetadata('bridge', 'framework', 0) then return end
if not IsResourceValid(framework) then return end
if IsResourceValid('qb-core') then return end

local qbx = exports[framework]
local PlayerData = {}
local version = GetResourceMetadata(framework, 'version', 0)
-- if version:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..framework..' detected (expected 1.3.0 or higher, got '..version..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'qbx_core'
local function get_framework() return framework end

---@return string version
local function get_version() return version end

---@return table QBCore
local function get_object()
  if GetConvar('qbx:enablebridge', 'true') == 'false' then error('qbx:enablebridge is set to false', 2) end
  return exports['qb-core']:GetCoreObject()
end

local function get_player()
  PlayerData = not next(PlayerData) and qbx:GetPlayerData() or PlayerData
  return PlayerData
end

---@return string|integer identifier The identifier of the `player`.
local function get_identifier()
  return get_player().citizenid
end

---@return string name The name of the `player`.
local function get_name()
  return get_player().charinfo.firstname..' '..get_player().charinfo.lastname
end

---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data of the `player`.
local function get_job()
  local data = ConvertJobData(get_player().job)
  if not data or not next(data) then error('error calling \'getplayerjob\' (job data not found)', 2) end
  return data
end

---@return {name: string, label: string, grade: number, grade_name: string} gang_data The gang data for the `player`.
local function get_gang()
  local data = ConvertGangData(get_player().gang)
  if not data or not next(data) then error('error calling \'getplayergang\' (gang data not found)', 2) end
  return data
end

---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
local function has_group(groups)
  local group_type = type(groups)
  if group_type ~= 'string' and group_type ~= 'table' then error('bad argument #1 to \'doesplayerhavegroup\' (string or table expected, got '..group_type..')', 2) end
  return qbx:HasPrimaryGroup(player, groups)
end

---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
local function get_money(money_type)
  if type(money_type) ~= 'string' then error('bad argument #2 to \'getplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type
  return get_player().money[money_type:lower()]
end

---@return boolean isDowned Whether the `player` is downed.
local function is_downed()
  return get_player().metadata.inlaststand or get_player().metadata.isdead
end

--------------------- EVENTS ---------------------

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  PlayerData = qbx:GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
  PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
  if not next(PlayerData) then return end
  PlayerData.job = ConvertJobData(data)
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
  PlayerData = data
end)

--------------------- OBJECT ---------------------

return {
  _FRAMEWORK = framework,
  _VERSION = version,
  getframework = get_framework,
  getversion = get_version,
  getobject = get_object,
  getplayer = get_player,
  getplayeridentifier = get_identifier,
  getplayername = get_name,
  getplayerjob = get_job,
  getplayergang = get_gang,
  doesplayerhavegroup = has_group,
  getplayermoney = get_money,
  isplayerdowned = is_downed
}

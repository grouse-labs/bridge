local framework = 'qb-core'

if not IsResourceValid(framework) then return end
if IsResourceValid('qbx_core') then return end

local QBCore = exports[framework]:GetCoreObject()
local version = GetResourceMetadata(framework, 'version', 0)

local function get_framework() return framework end

local function get_version() return version end

local function get_object() return QBCore end

---@param player_src integer|string?
---@return table Player
local function get_player(player_src)
  if not IsSrcValid(player_src) then error('bad argument #1 to \'GetPlayer\' (number expected, got '..type(player_src)..')', 2) end
  return QBCore.Functions.GetPlayer(player_src)
end

---@param player_src integer|string?
---@return string
local function get_identifier(player_src)
  if not IsSrcValid(player_src) then error('bad argument #1 to \'GetIdentifier\' (number expected, got '..type(player_src)..')', 2) end
  return QBCore.Functions.GetPlayer(player_src).PlayerData.citizenid
end

---@param player_src integer|string?
---@return string name
local function get_name(player_src)
  if not IsSrcValid(player_src) then error('bad argument #1 to \'GetName\' (number expected, got '..type(player_src)..')', 2) end
  local PlayerData = QBCore.Functions.GetPlayer(player_src).PlayerData
  return PlayerData.firstname..' '..PlayerData.lastname
end

---@param player integer|string? The `player` to retrieve the job data for. <br> `player` is a server-side only argument, and is the player's server ID. <br> If `player` is nil, the source is used.
---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number}? job_data The job data for the `player`.
local function get_job(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'GetJob\' (number expected, got '..type(player)..')', 2) end
  local data = ConvertJobData(QBCore.Functions.GetPlayer(player).PlayerData.job)
  if not data or not next(data) then error('error calling \'GetJob\' (job data not found)', 2) end
  return data
end

local function get_gang(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'GetGang\' (number expected, got '..type(player)..')', 2) end
  local data = ConvertGangData(QBCore.Functions.GetPlayer(player).PlayerData.gang)
  if not data or not next(data) then error('error calling \'GetGang\' (gang data not found)', 2) end
  return data
end

---@param player integer|string? The `player` to check for the specified group(s). <br> If `player` is nil, the source is used. <br> `player` is a server-side only argument.
---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
local function has_group(player, groups)
  if not IsSrcValid(player) then error('bad argument #1 to \'HasGroup\' (number expected, got '..type(player)..')', 2) end
  local group_type = type(groups)
  if group_type ~= 'string' and group_type ~= 'table' then error('bad argument #2 to \'HasGroup\' (string or table expected, got '..group_type..')', 2) end
  local job_data = get_job(player)
  local gang_data = get_gang(player)
  if not job_data or not next(job_data) then return false end
  if not gang_data or not next(gang_data) then return false end
  local job_name, job_label, job_type, gang_name, gang_label = job_data.name, job_data.label, job_data.job_type, gang_data.name, gang_data.label
  if group_type == 'string' then
    return job_name == groups or job_label == groups or job_type == groups or gang_name == groups or gang_label == groups
  end
  for i = 1, #groups do
    local group = groups[i]
    if job_name == group or job_label == group or job_type == group or gang_name == group or gang_label == group then return true end
  end
  return false
end

---@param player integer|string? The `player` to check for the specified group(s). <br> If `player` is nil, the source is used. <br> `player` is a server-side only argument.
---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
local function get_money(player, money_type)
  if not IsSrcValid(player) then error('bad argument #1 to \'GetMoney\' (number expected, got '..type(player)..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'GetMoney\' (string expected, got '..type(money_type)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type
  return QBCore.Functions.GetPlayer(player).PlayerData.money[money_type:lower()]
end

---@param player integer|string? The `player` to add money to. <br> If `player` is nil, the source is used.
---@param money_type 'money'|'cash'|'bank' The type of money to add. <br> If `money_type` is 'cash', the player's has cash added. <br> If `money_type` is 'bank', the player's bank has money added to it.
---@param amount number The amount of money to add.
---@return boolean added Whether the money was added to the `player`.
local function add_money(player, money_type, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'AddMoney\' (number expected, got '..type(player)..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'AddMoney\' (string expected, got '..type(money_type)..')', 2) end
  if type(amount) ~= 'number' then error('bad argument #3 to \'AddMoney\' (number expected, got '..type(amount)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type
  local prev = get_money(player, money_type)
  QBCore.Functions.GetPlayer(player).PlayerData.Functions.AddMoney(money_type:lower(), amount, 'bridge added money: '..amount)
  return get_money(player, money_type) == prev + amount
end

---@param player integer|string? The `player` to remove money from. <br> If `player` is nil, the source is used.
---@param money_type 'money'|'cash'|'bank' The type of money to remove. <br> If `money_type` is 'cash', the player's cash is removed. <br> If `money_type` is 'bank', the player's bank has money removed from it.
---@param amount number The amount of money to remove.
---@return boolean removed Whether the money was removed from the `player`.
local function remove_money(player, money_type, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'RemoveMoney\' (number expected, got '..type(player)..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'RemoveMoney\' (string expected, got '..type(money_type)..')', 2) end
  if type(amount) ~= 'number' then error('bad argument #3 to \'RemoveMoney\' (number expected, got '..type(amount)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type
  local prev = get_money(player, money_type)
  QBCore.Functions.GetPlayer(player).PlayerData.Functions.RemoveMoney(money_type:lower(), amount, 'bridge removed money: '..amount)
  return get_money(player, money_type) == prev - amount
end

---@param player integer|string? The `player` to check if they are downed. <br> If `player` is nil, the source is used. <br> `player` is a server-side only argument.
---@return boolean is_downed Whether the `player` is downed.
local function is_downed(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'IsDowned\' (number expected, got '..type(player)..')', 2) end
  local metadata = QBCore.Functions.GetPlayer(player).PlayerData.metadata
  if not metadata or not next(metadata) then error('error calling \'IsDowned\' (metadata not found)', 2) end
  return metadata.inlaststand or metadata.isdowned
end

---@param player integer|string? The `player` to retrieve the inventory for. <br> If `player` is nil, the source is used.
---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean}} inventory The inventory for the `player`.
local function get_inventory(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'getplayerinventory\' (number expected, got '..type(player)..')', 2) end
  local inventory = {}
  local PlayerData = QBCore.Functions.GetPlayer(player).PlayerData
  for name, item in pairs(PlayerData.items) do
    inventory[name] = {
      name = item.name,
      label = item.label,
      weight = item.weight,
      useable = item.useable,
      unique = item.unique
    }
  end
  return inventory
end

---@param player integer|string? The `player` to check has the item for. <br> If `player` is nil, the source is used.
---@param item_name string The `item_name` to check for.
---@param amount number? The amount of the item to check for. <br> If `amount` is nil, the default amount is 1.
---@return boolean has_item Whether the `player` has the specified `item`.
local function has_item(player, item_name, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'doesplayerhaveitem\' (number expected, got '..type(player)..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'doesplayerhaveitem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'doesplayerhaveitem\' (number expected, got '..type(amount)..')', 2) end
  local PlayerData = QBCore.Functions.GetPlayer(player).PlayerData
  local item = PlayerData.items[item_name]
  if not item then return false end
  return amount and item.amount >= amount or item.amount > 0
end

---@param player integer|string? The `player` to add the item to. <br> If `player` is nil, the source is used.
---@param item_name string The `item_name` to add.
---@param amount number? The amount of the item to add. <br> If `amount` is nil, the default amount is 1.
---@return boolean added Whether the item was added to the `player`.
local function add_item(player, item_name, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'addplayeritem\' (number expected, got '..type(player)..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'addplayeritem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'addplayeritem\' (number expected, got '..type(amount)..')', 2) end
  local PlayerData = QBCore.Functions.GetPlayer(player).PlayerData
  PlayerData.Functions.AddItem(item_name, amount or 1)
  return has_item(player, item_name, amount)
end

---@param player integer|string? The `player` to remove the item from. <br> If `player` is nil, the source is used.
---@param item_name string The `item_name` to remove.
---@param amount number? The amount of the item to remove. <br> If `amount` is nil, the default amount is 1.
---@return boolean removed Whether the item was removed from the `player`.
local function remove_item(player, item_name, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'removeplayeritem\' (number expected, got '..type(player)..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'removeplayeritem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'removeplayeritem\' (number expected, got '..type(amount)..')', 2) end
  local PlayerData = QBCore.Functions.GetPlayer(player).PlayerData
  PlayerData.Functions.RemoveItem(item_name, amount or 1)
  return not has_item(player, item_name, amount)
end

-- Item Methods

---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean}} Items A table of all items available in the inventory system.
local function get_items()
  local Items = {}
  for name, item in pairs(QBCore.Shared.Items) do
    Items[name] = {
      name = item.name,
      label = item.label,
      weight = item.weight,
      useable = item.useable,
      unique = item.unique
    }
  end
  return Items
end

---@param item_name string The name of the item to get the data for.
---@return {name: string, label: string, weight: number, useable: boolean, unique: boolean} item_data The data for the specified item.
local function get_item(item_name)
  if type(item_name) ~= 'string' then error('bad argument #1 to \'getitem\' (string expected, got '..type(item_name)..')', 2) end
  local item = QBCore.Shared.Items[item_name]
  if not item or not next(item) then error('error calling \'getitem\' (item data not found)', 2) end
  return {
    name = item.name,
    label = item.label,
    weight = item.weight,
    useable = item.useable,
    unique = item.unique
  }
end

---@param item_name string The `item_name` to create a useable item callback for.
---@param cb fun(src: number|string) The function to call when the item is used.
local function create_useable_item(item_name, cb)
  if type(item_name) ~= 'string' then error('bad argument #1 to \'createuseableitem\' (string expected, got '..type(item_name)..')', 2) end
  if type(cb) ~= 'function' then error('bad argument #2 to \'createuseableitem\' (function expected, got '..type(cb)..')', 2) end
  QBCore.Functions.CreateUseableItem(item_name, cb)
end

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
  addplayermoney = add_money,
  removeplayermoney = remove_money,
  isplayerdowned = is_downed,
  getplayerinventory = get_inventory,
  doesplayerhaveitem = has_item,
  addplayeritem = add_item,
  removeplayeritem = remove_item,
  getitems = get_items,
  getitem = get_item,
  createuseableitem = create_useable_item
}

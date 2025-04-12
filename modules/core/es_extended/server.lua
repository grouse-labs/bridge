local FRAMEWORK <const> = 'es_extended'
if FRAMEWORK ~= GetConvar('bridge:framework', 'qbx_core') then error('invalid framework resource name', 0) end
if not IsResourceValid(FRAMEWORK) then error('framework resource `'..FRAMEWORK..'` not valid', 0) end

local ESX = exports[FRAMEWORK]:getSharedObject()
local VERSION <const> = GetResourceMetadata(FRAMEWORK, 'version', 0)
if VERSION:gsub('%D', '') < ('1.12.4'):gsub('%D', '') then error('incompatible version of '..FRAMEWORK..' detected (expected 1.12.4 or higher, got '..VERSION..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'es_extended'
local function get_framework() return FRAMEWORK end

---@return string version
local function get_version() return VERSION end

---@return table ESX
local function get_object() return ESX end

--------------------- PLAYER ---------------------

---@param player_src integer|string?
---@return table Player
local function get_player(player_src)
  if not IsSrcValid(player_src) then error('bad argument #1 to \'getplayer\' (number expected, got '..type(player_src)..')', 2) end
  return ESX.GetPlayerFromId(player_src)
end

---@param player_src integer|string?
---@return string identifier
local function get_identifier(player_src)
  if not IsSrcValid(player_src) then error('bad argument #1 to \'getplayeridentifier\' (number expected, got '..type(player_src)..')', 2) end
  local Player = get_player(player_src)
  if not Player then error('error calling \'getplayeridentifier\' (player not found)', 2) end
  return Player.getIdentifier()
end

---@param player_src integer|string?
---@return string name
local function get_name(player_src)
  if not IsSrcValid(player_src) then error('bad argument #1 to \'getplayername\' (number expected, got '..type(player_src)..')', 2) end
  local Player = get_player(player_src)
  if not Player then error('error calling \'getplayername\' (player not found)', 2) end
  return Player.getName()
end

---@param player integer|string? The `player` to retrieve the job data for. <br> If `player` is nil, the source is used.
---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data for the `player`.
local function get_job(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'getplayerjob\' (number expected, got '..type(player)..')', 2) end
  local Player = get_player(player)
  if not Player then error('error calling \'getplayerjob\' (player not found)', 2) end
  local data = ConvertPlayerJobData(Player.getJob())
  if not data or not next(data) then error('error calling \'getplayerjob\' (job data not found)', 2) end
  return data
end

-- ---@param player integer|string? The `player` to retrieve the gang data for. <br> If `player` is nil, the source is used.
-- ---@return {name: string, label: string, grade: number, grade_name: string} gang_data The gang data for the `player`.
-- local function get_gang(player)
--   if not IsSrcValid(player) then error('bad argument #1 to \'getplayergang\' (number expected, got '..type(player)..')', 2) end
--   local Player = get_player(player)
--   if not Player then error('error calling \'getplayergang\' (player not found)', 2) end
--   local data = ConvertGangData(--[[Add Applicable Gang Data Retrieval Function]])
--   if not data or not next(data) then error('error calling \'getplayergang\' (gang data not found)', 2) end
--   return data
-- end

---@param player integer|string? The `player` to check for the specified group(s). <br> If `player` is nil, the source is used.
---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
local function has_group(player, groups)
  if not IsSrcValid(player) then error('bad argument #1 to \'doesplayerhavegroup\' (number expected, got '..type(player)..')', 2) end
  local group_type = type(groups)
  if group_type ~= 'string' and group_type ~= 'table' then error('bad argument #2 to \'doesplayerhavegroup\' (string or table expected, got '..group_type..')', 2) end
  local job = get_job(player)
  -- local gang = get_gang(player)
  for i = 1, #groups do
    local group = groups[i]
    if job and (job.name == group or job.label == group or job.job_type == group) then return true end
    -- if gang and (gang.name == group or gang.label == group) then return true end
  end
  return false
end

---@param player integer|string? The `player` to check for the specified group(s). <br> If `player` is nil, the source is used.
---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
local function get_money(player, money_type)
  if not IsSrcValid(player) then error('bad argument #1 to \'getplayermoney\' (number expected, got '..type(player)..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'getplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  money_type = money_type == 'cash' and 'money' or money_type
  local Player = get_player(player)
  if not Player then error('error calling \'getplayermoney\' (player not found)', 2) end
  return Player.getAccount(money_type:lower())
end

---@param player integer|string? The `player` to add money to. <br> If `player` is nil, the source is used.
---@param money_type 'money'|'cash'|'bank' The type of money to add. <br> If `money_type` is 'cash', the player's has cash added. <br> If `money_type` is 'bank', the player's bank has money added to it.
---@param amount number The amount of money to add.
---@return boolean added Whether the money was added to the `player`.
local function add_money(player, money_type, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'addplayermoney\' (number expected, got '..type(player)..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'addplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  if type(amount) ~= 'number' then error('bad argument #3 to \'addplayermoney\' (number expected, got '..type(amount)..')', 2) end
  money_type = money_type == 'cash' and 'money' or money_type
  local Player = get_player(player)
  if not Player then error('error calling \'addplayermoney\' (player not found)', 2) end
  local prev = get_money(player, money_type)
  Player.addAccountMoney(money_type:lower(), amount)
  return get_money(player, money_type) == prev + amount
end

---@param player integer|string? The `player` to remove money from. <br> If `player` is nil, the source is used.
---@param money_type 'money'|'cash'|'bank' The type of money to remove. <br> If `money_type` is 'cash', the player's cash is removed. <br> If `money_type` is 'bank', the player's bank has money removed from it.
---@param amount number The amount of money to remove.
---@return boolean removed Whether the money was removed from the `player`.
local function remove_money(player, money_type, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'removeplayermoney\' (number expected, got '..type(player)..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'removeplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  if type(amount) ~= 'number' then error('bad argument #3 to \'removeplayermoney\' (number expected, got '..type(amount)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type
  local Player = get_player(player)
  if not Player then error('error calling \'removeplayermoney\' (player not found)', 2) end
  local prev = get_money(player, money_type)
  Player.removeAccountMoney(money_type:lower(), amount)
  return get_money(player, money_type) == prev - amount
end

---@param player integer|string? The `player` to check if they are downed. <br> If `player` is nil, the source is used.
---@return boolean is_downed Whether the `player` is downed.
local function is_downed(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'isplayerdowned\' (number expected, got '..type(player)..')', 2) end
  local Player = get_player(player)
  if not Player then error('error calling \'isplayerdowned\' (player not found)', 2) end
  return Player.getMeta('dead')
end

---@param player integer|string? The `player` to retrieve the inventory for. <br> If `player` is nil, the source is used.
---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean, amount: integer?}} inventory The inventory for the `player`.
local function get_inventory(player)
  if not IsSrcValid(player) then error('bad argument #1 to \'getplayerinventory\' (number expected, got '..type(player)..')', 2) end
  local inventory = {}
  local Player = get_player(player)
  if not Player then error('error calling \'getplayerinventory\' (player not found)', 2) end
  local PlayerItems = Player.getInventory()
  for name, item in pairs(PlayerItems) do
    inventory[name] = {
      name = item.name,
      label = item.label,
      weight = item.weight,
      useable = item.usable,
      unique = item.rare,
      amount = not item.rare and item.count or nil
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
  local Player = get_player(player)
  if not Player then error('error calling \'doesplayerhaveitem\' (player not found)', 2) end
  return Player.hasItem(item_name, amount or 1)
end

---@param player integer|string? The `player` to add the item to. <br> If `player` is nil, the source is used.
---@param item_name string The `item_name` to add.
---@param amount number? The amount of the item to add. <br> If `amount` is nil, the default amount is 1.
---@return boolean added Whether the item was added to the `player`.
local function add_item(player, item_name, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'addplayeritem\' (number expected, got '..type(player)..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'addplayeritem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'addplayeritem\' (number expected, got '..type(amount)..')', 2) end
  local Player = get_player(player)
  if not Player then error('error calling \'addplayeritem\' (player not found)', 2) end
  if Player.canCarryItem(item_name, amount) then Player.addInventoryItem(item_name, amount) end
  return Player.hasItem(item_name, amount or 1)
end

---@param player integer|string? The `player` to remove the item from. <br> If `player` is nil, the source is used.
---@param item_name string The `item_name` to remove.
---@param amount number? The amount of the item to remove. <br> If `amount` is nil, the default amount is 1.
---@return boolean removed Whether the item was removed from the `player`.
local function remove_item(player, item_name, amount)
  if not IsSrcValid(player) then error('bad argument #1 to \'removeplayeritem\' (number expected, got '..type(player)..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'removeplayeritem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'removeplayeritem\' (number expected, got '..type(amount)..')', 2) end
  local Player = get_player(player)
  if not Player then error('error calling \'removeplayeritem\' (player not found)', 2) end
  Player.removeInventoryItem(item_name, amount or 1)
  return not Player.hasItem(item_name, amount or 1)
end

--------------------- INVENTORY ---------------------

local function is_item_useable(item_name) return ESX.GetUsableItems()[item_name] ~= nil end

---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean}} Items A table of all items available in the inventory system.
local function get_items()
  local Items = {}
  for name, item in pairs(ESX.Items) do
    Items[name] = {
      name = item.name,
      label = item.label,
      weight = item.weight,
      useable = is_item_useable(name),
      unique = item.rare
    }
  end
  return Items
end

---@param item_name string The name of the item to get the data for.
---@return {name: string, label: string, weight: number, useable: boolean, unique: boolean} item_data The data for the specified item.
local function get_item(item_name)
  if type(item_name) ~= 'string' then error('bad argument #1 to \'getitem\' (string expected, got '..type(item_name)..')', 2) end
  local item = ESX.Items[item_name]
  if not item or not next(item) then error('error calling \'getitem\' (item data not found)', 2) end
  return {
    name = item.name,
    label = item.label,
    weight = item.weight,
    useable = is_item_useable(item_name),
    unique = item.rare
  }
end

---@param item_name string The `item_name` to create a useable item callback for.
---@param cb fun(src: number|string) The function to call when the item is used.
local function create_useable_item(item_name, cb)
  if type(item_name) ~= 'string' then error('bad argument #1 to \'createuseableitem\' (string expected, got '..type(item_name)..')', 2) end
  if type(cb) ~= 'function' then error('bad argument #2 to \'createuseableitem\' (function expected, got '..type(cb)..')', 2) end
  ESX.RegisterUsableItem(item_name, cb)
end


--------------------- SHARED ---------------------

local function get_jobs()
  local found_jobs = ESX.GetJobs()
  local jobs = {}
  for k, v in pairs(found_jobs) do
    jobs[k] = ConvertJobData(k, v)
  end
  return jobs
end

--------------------- OBJECT ---------------------

return {
  _FRAMEWORK = FRAMEWORK,
  _VERSION = VERSION,
  getframework = get_framework,
  getversion = get_version,
  getobject = get_object,
  getplayer = get_player,
  getplayeridentifier = get_identifier,
  getplayername = get_name,
  getplayerjob = get_job,
  -- getplayergang = get_gang,
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
  createuseableitem = create_useable_item,
  getjobs = get_jobs
}

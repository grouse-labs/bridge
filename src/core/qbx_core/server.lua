---@diagnostic disable: duplicate-set-field
--------------------- PLAYER ---------------------

---@param player integer|string The `player` server ID or src.
---@return table Player The player object.
function core.getplayer(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayer\' (number or string expected, got '..player..')', 2) end
  return qbx:GetPlayer(player)
end

---@param player integer|string The `player` server ID or src.
---@return string identifier The identifier of the `player`.
function core.getplayeridentifier(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayeridentifier\' (number or string expected, got '..player..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'getplayeridentifier\' (player not found)', 2) end
  return Player.PlayerData.citizenid
end

---@param player integer|string The `player` server ID or src.
---@return string name The name of the `player`.
function core.getplayername(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayername\' (number or string expected, got '..player..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'getplayername\' (player not found)', 2) end
  return Player.PlayerData.firstname..' '..Player.PlayerData.lastname
end

---@param player integer|string The `player` server ID or src.
---@return {name: string, label: string, grade: number, grade_name: string, grade_label: string, job_type: string, salary: number} job_data The job data for the `player`.
function core.getplayerjob(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayerjob\' (number or string expected, got '..player..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'getplayerjob\' (player not found)', 2) end
  local data = ConvertPlayerJobData(Player.PlayerData.job)
  if not data or not next(data) then error('error calling \'getplayerjob\' (job data not found)', 2) end
  return data
end

---@param player integer|string The `player` server ID or src.
---@return {name: string, label: string, grade: number, grade_name: string} gang_data The gang data for the `player`.
function core.getplayergang(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayergang\' (number or string expected, got '..player..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'getplayergang\' (player not found)', 2) end
  local data = ConvertGangData(Player.PlayerData.gang)
  if not data or not next(data) then error('error calling \'getplayergang\' (gang data not found)', 2) end
  return data
end

---@param player integer|string The `player` server ID or src.
---@param groups string|string[] The group(s) to check for. <br> If `groups` is a string, it is the name of the group to check for. <br> If `groups` is a table, it is a list of group names to check for. <br> The group name can be the job name, job label, job type, gang name or gang label.
---@return boolean has_group Whether the `player` has the specified group(s).
function core.doesplayerhavegroup(player, groups)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'doesplayerhavegroup\' (number or string expected, got '..player..')', 2) end
  if not core.getplayer(player) then error('error calling \'doesplayerhavegroup\' (player not found)', 2) end
  local group_type = type(groups)
  if group_type ~= 'string' and group_type ~= 'table' then error('bad argument #2 to \'doesplayerhavegroup\' (string or table expected, got '..group_type..')', 2) end
  return qbx:HasPrimaryGroup(player, groups)
end

---@param player integer|string The `player` server ID or src.
---@param money_type 'money'|'cash'|'bank' The type of money to check for. <br> If `money_type` is 'cash', the player's cash is checked. <br> If `money_type` is 'bank', the player's bank is checked.
---@return integer money The amount of money the `player` has.
function core.getplayermoney(player, money_type)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayermoney\' (number or string expected, got '..player..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'getplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type:lower()
  local Player = core.getplayer(player)
  if not Player then error('error calling \'getplayermoney\' (player not found)', 2) end
  return qbx:GetMoney(player, money_type)
end

---@param player integer|string The `player` server ID or src.
---@param money_type 'money'|'cash'|'bank' The type of money to add. <br> If `money_type` is 'cash', the player's has cash added. <br> If `money_type` is 'bank', the player's bank has money added to it.
---@param amount number The amount of money to add.
---@return boolean added Whether the money was added to the `player`.
function core.addplayermoney(player, money_type, amount)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'addplayermoney\' (number or string expected, got '..player..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'addplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  if type(amount) ~= 'number' then error('bad argument #3 to \'addplayermoney\' (number expected, got '..type(amount)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type:lower()
  local Player = core.getplayer(player)
  if not Player then error('error calling \'addplayermoney\' (player not found)', 2) end
  local prev = core.getplayermoney(player, money_type)
  qbx:AddMoney(money_type, amount, 'bridge added money: '..amount)
  return qbx:GetMoney(player, money_type) == prev + amount
end

---@param player integer|string The `player` server ID or src.
---@param money_type 'money'|'cash'|'bank' The type of money to remove. <br> If `money_type` is 'cash', the player's cash is removed. <br> If `money_type` is 'bank', the player's bank has money removed from it.
---@param amount number The amount of money to remove.
---@return boolean removed Whether the money was removed from the `player`.
function core.removeplayermoney(player, money_type, amount)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'removeplayermoney\' (number or string expected, got '..player..')', 2) end
  if type(money_type) ~= 'string' then error('bad argument #2 to \'removeplayermoney\' (string expected, got '..type(money_type)..')', 2) end
  if type(amount) ~= 'number' then error('bad argument #3 to \'removeplayermoney\' (number expected, got '..type(amount)..')', 2) end
  money_type = money_type == 'money' and 'cash' or money_type:lower()
  local Player = core.getplayer(player)
  if not Player then error('error calling \'removeplayermoney\' (player not found)', 2) end
  local prev = core.getplayermoney(player, money_type)
  qbx:RemoveMoney(money_type, amount, 'bridge removed money: '..amount)
  return qbx:GetMoney(player, money_type) == prev - amount
end

---@param player integer|string The `player` server ID or src.
---@return boolean is_downed Whether the `player` is downed.
function core.isplayerdowned(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'isplayerdowned\' (number or string expected, got '..player..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'isplayerdowned\' (player not found)', 2) end
  local metadata = Player.PlayerData.metadata
  if not metadata or not next(metadata) then error('error calling \'isplayerdowned\' (metadata not found)', 2) end
  return Player.PlayerData.metadata['inlaststand'] or Player.PlayerData.metadata['isdowned']
end

local ox_inventory = exports.ox_inventory

---@param item_name string The `item_name` to check for.
---@return boolean? is_useable Whether the `item_name` is useable.
local function is_item_useable(item_name)
  local data = ox_inventory:Items(item_name)
  if not data then return end
  local client_data, server_data = data.client, data.server
  return not data.consume and (client_data?.status or client_data?.useTime or client_data?.export or server_data?.export) or data.consume == 1
end

---@param player integer|string The `player` server ID or src.
---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean, amount: integer?}} inventory The inventory for the `player`.
function core.getplayerinventory(player)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'getplayerinventory\' (number or string expected, got '..player..')', 2) end
  local inventory = {}
  local Player = core.getplayer(player)
  if not Player then error('error calling \'getplayerinventory\' (player not found)', 2) end
  local PlayerItems = ox_inventory:GetInventoryItems(player)
  if not PlayerItems then error('error calling \'getplayerinventory\' (inventory not found)', 2) end
  for _, slot in pairs(PlayerItems) do
    local name = slot.name
    inventory[name] = {
      name = name,
      label = slot.label,
      weight = slot.weight,
      useable = is_item_useable(name),
      unique = slot.stack == nil and true or slot.stack,
      amount = not slot.stack and slot.count or nil
    }
  end
  return inventory
end

---@param player integer|string The `player` server ID or src.
---@param item_name string The `item_name` to check for.
---@param amount number? The amount of the item to check for. <br> If `amount` is nil, the default amount is 1.
---@return boolean has_item Whether the `player` has the specified `item`.
function core.doesplayerhaveitem(player, item_name, amount)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'doesplayerhaveitem\' (number or string expected, got '..player..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'doesplayerhaveitem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'doesplayerhaveitem\' (number expected, got '..type(amount)..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'doesplayerhaveitem\' (player not found)', 2) end
  return ox_inventory:GetItemCount(player, item_name) >= (amount or 1)
end

---@param player integer|string The `player` server ID or src.
---@param item_name string The `item_name` to add.
---@param amount number? The amount of the item to add. <br> If `amount` is nil, the default amount is 1.
---@return boolean added Whether the item was added to the `player`.
function core.addplayeritem(player, item_name, amount)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'addplayeritem\' (number or string expected, got '..player..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'addplayeritem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'addplayeritem\' (number expected, got '..type(amount)..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'addplayeritem\' (player not found)', 2) end
  amount = amount or 1
  return ox_inventory:CanCarryItem(player, item_name, amount) and ox_inventory:AddItem(player, item_name, amount) or false
end

---@param player integer|string The `player` server ID or src.
---@param item_name string The `item_name` to remove.
---@param amount number? The amount of the item to remove. <br> If `amount` is nil, the default amount is 1.
---@return boolean removed Whether the item was removed from the `player`.
function core.removeplayeritem(player, item_name, amount)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'removeplayeritem\' (number or string expected, got '..player..')', 2) end
  if type(item_name) ~= 'string' then error('bad argument #2 to \'removeplayeritem\' (string expected, got '..type(item_name)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'removeplayeritem\' (number expected, got '..type(amount)..')', 2) end
  local Player = core.getplayer(player)
  if not Player then error('error calling \'removeplayeritem\' (player not found)', 2) end
  return ox_inventory:RemoveItem(player, item_name, amount or 1) or false
end

--------------------- INVENTORY ---------------------

---@return {[string]: {name: string, label: string, weight: number, useable: boolean, unique: boolean}} Items A table of all items available in the inventory system.
function core.getitems()
  local Items = {}
  local OxItems = ox_inventory:Items()
  if not OxItems then error('error calling \'getitems\' (items not found)', 2) end
  for name, item in pairs(OxItems) do
    Items[name:lower()] = {
      name = item.name,
      label = item.label,
      weight = item.weight or 0,
      useable = is_item_useable(name),
      unique = item.stack == nil and true or item.stack
    }
  end
  return Items
end

---@param item_name string The name of the item to get the data for.
---@return {name: string, label: string, weight: number, useable: boolean, unique: boolean} item_data The data for the specified item.
function core.getitem(item_name)
  if type(item_name) ~= 'string' then error('bad argument #1 to \'getitem\' (string expected, got '..type(item_name)..')', 2) end
  local item = ox_inventory:Items(item_name)
  if not item or not next(item) then error('error calling \'getitem\' (item data not found)', 2) end
  return {
    name = item.name,
    label = item.label,
    weight = item.weight or 0,
    useable = is_item_useable(item_name),
    unique = item.stack == nil and true or item.stack
  }
end

---@param item_name string The `item_name` to create a useable item callback for.
---@param cb fun(src: number|string) The function to call when the item is used.
function core.createusableitem(item_name, cb)
  if type(item_name) ~= 'string' then error('bad argument #1 to \'createuseableitem\' (string expected, got '..type(item_name)..')', 2) end
  if type(cb) ~= 'function' then error('bad argument #2 to \'createuseableitem\' (function expected, got '..type(cb)..')', 2) end
  exports(item_name, function(event, _, inventory)
    if event ~= 'usingItem' then return end
    cb(inventory.id)
  end)
end

--------------------- JOBS ---------------------

---@return {[string]: {name: string, label: string, _type: string, grades: {[number]: {label: string, salary: number}}}}
function core.getjobs()
  local found_jobs = qbx:GetJobs()
  local jobs = {}
  for k, v in pairs(found_jobs) do
    jobs[k] = ConvertJobData(k, v)
  end
  return jobs
end

---@return {name: string, label: string, _type: string, grades: {[number]: {label: string, salary: number}}}
function core.getjob(job_name)
  if type(job_name) ~= 'string' then error('bad argument #1 to \'getjob\' (string expected, got '..type(job_name)..')', 2) end
  local found_job = core.getjobs()[job_name]
  if not found_job or not next(found_job) then error('error calling \'getjob\' (job data not found)', 2) end
  return found_job
end

--------------------- OBJECT ---------------------
getmetatable(core).__newindex = function() error('attempt to edit a read-only object', 2) end

return core

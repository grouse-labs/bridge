local NOTIFY <const> = 'qb-core'
if NOTIFY ~= GetResourceMetadata('bridge', 'notify', 0) then return end
if not IsResourceValid(NOTIFY) then return end
if IsResourceValid('qbx_core') then return end
local version = GetResourceMetadata(NOTIFY, 'version', 0)
if version:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..NOTIFY..' detected (expected 1.3.0 or higher, got '..version..')', 0) end

local QBCore = exports[NOTIFY]:GetCoreObject({'Shared'})

--------------------- FUNCTIONS ---------------------

---@param player string|integer?
---@param text string
---@param notify_type 'error'|'success'|'primary'? @default 'primary'
---@param time integer? @default 5000
local function text_notify(player, text, notify_type, time)
  player = player or source
  if not IsSrcValid(player) then error('bad argument #1 to \'TextNotify\' (string or integer expected, got '..type(player)..')', 2) end
  if not text or type(text) ~= 'string' then error('bad argument #2 to \'TextNotify\' (string expected, got '..type(text)..')', 2) end
  TriggerClientEvent('QBCore:Notify', player, text, notify_type, time)
end

---@param player string|integer?
---@param item string
---@param amount integer?
---@param text string?
local function item_notify(player, item, amount, text)
  player = player or source
  if not IsSrcValid(player) then error('bad argument #1 to \'ItemNotify\' (string or integer expected, got '..type(player)..')', 2) end
  if not item or type(item) ~= 'string' then error('bad argument #2 to \'ItemNotify\' (string expected, got '..type(item)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'ItemNotify\' (number expected, got '..type(amount)..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #4 to \'ItemNotify\' (string expected, got '..type(text)..')', 2) end
  amount = amount or 1
  TriggerClientEvent('qb-inventory:client:ItemNotify', player, QBCore.Shared.Items[item:lower()], amount >= 1 and 'add' or 'remove', amount)
  if text then text_notify(player, text) end
end

--------------------- OBJECT ---------------------

return {
  _TYPE = NOTIFY,
  text = text_notify,
  item = item_notify
}
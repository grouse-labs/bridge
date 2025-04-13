local NOTIFY <const> = 'qb-core'
if NOTIFY ~= GetConvar('bridge:notify', 'native') then error('invalid notify resource name', 0) end
if not IsResourceValid(NOTIFY) and IsResourceValid('qbx_core') then error('notify resource `'..NOTIFY..'` not valid', 0) end

local VERSION <const> = GetResourceMetadata(NOTIFY, 'version', 0)
if VERSION:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..NOTIFY..' detected (expected 1.3.0 or higher, got '..VERSION..')', 0) end

local QBCore = exports[NOTIFY]:GetCoreObject({'Functions', 'Shared'})

--------------------- FUNCTIONS ---------------------

---@param text string
---@param notify_type 'error'|'success'|'primary'? @default 'primary'
---@param time integer? @default 5000
local function text_notify(text, notify_type, time)
  if not text or type(text) ~= 'string' then error('bad argument #1 to \'TextNotify\' (string expected, got '..type(text)..')', 2) end
  QBCore.Functions.Notify(text, notify_type, time)
end

---@param item string
---@param amount integer?
---@param text string?
local function item_notify(item, amount, text)
  if not item or type(item) ~= 'string' then error('bad argument #1 to \'ItemNotify\' (string expected, got '..type(item)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #2 to \'ItemNotify\' (number expected, got '..type(amount)..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #3 to \'ItemNotify\' (string expected, got '..type(text)..')', 2) end
  amount = amount or 1
  TriggerEvent('qb-inventory:client:ItemNotify', QBCore.Shared.Items[item:lower()], amount >= 1 and 'add' or 'remove', amount)
  if text then text_notify(text) end
end

--------------------- OBJECT ---------------------

return {
  _TYPE = NOTIFY,
  text = text_notify,
  item = item_notify
}
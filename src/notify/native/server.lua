local NOTIFY <const> = 'native'
if NOTIFY ~= MODULE_NAMES.notify then return end

--------------------- FUNCTIONS ---------------------

---@param player string|integer?
---@param text string
---@param notify_type 'error'|'success'|'primary'? @default 'primary'
local function text_notify(player, text, notify_type)
  player = player or source
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'TextNotify\' (string or integer expected, got '..type(player)..')', 2) end
  if not text or type(text) ~= 'string' then error('bad argument #2 to \'TextNotify\' (string expected, got '..type(text)..')', 2) end
  TriggerClientEvent('grinch:client:Notify', player, text, notify_type)
end

---@param player string|integer?
---@param item string
---@param amount integer?
---@param text string?
local function item_notify(player, item, amount, text)
  player = player or source
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'ItemNotify\' (string or integer expected, got '..type(player)..')', 2) end
  if not item or type(item) ~= 'string' then error('bad argument #2 to \'ItemNotify\' (string expected, got '..type(item)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #3 to \'ItemNotify\' (number expected, got '..type(amount)..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #4 to \'ItemNotify\' (string expected, got '..type(text)..')', 2) end
  TriggerClientEvent('grinch:client:ItemNotify', player, item, amount, text)
end

--------------------- OBJECT ---------------------

return {
  _TYPE = NOTIFY,
  text = text_notify,
  item = item_notify
}
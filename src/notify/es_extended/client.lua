---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param text string The notify `text` as a string.
---@param _type 'error'|'success'|'primary'? The notify type. <br> Defaults to `'primary'`.
---@param time integer? The notify `time` in milliseconds.
function notify.text(text, _type, time)
  if not text or type(text) ~= 'string' then error('bad argument #1 to \'text\' (string expected, got '..type(text)..')', 2) end
  ESX.ShowNotification(text, _type == 'primary' and 'info' or _type, time)
end

---@param item string The item name as a string.
---@param amount integer? The item `amount` as a number. <br> Defaults to `1`.
---@param text string? The notify `text` as a string.
function notify.item(item, amount, text)
  if not item or type(item) ~= 'string' then error('bad argument #1 to \'item\' (string expected, got '..type(item)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #2 to \'item\' (number expected, got '..type(amount)..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #3 to \'item\' (string expected, got '..type(text)..')', 2) end
  amount = amount or 1
  ESX.UI.ShowInventoryItemNotification(amount >= 1 and 'add' or 'remove', ESX.Items[item].label, amount)
  if text then notify.text(text) end
end

--------------------- EVENTS ---------------------

RegisterNetEvent('bridge:client:notify_text', notify.text)
RegisterNetEvent('bridge:client:notify_item', notify.item)

--------------------- OBJECT ---------------------
getmetatable(notify).__newindex = function() error('attempt to edit a read-only object', 2) end

return notify

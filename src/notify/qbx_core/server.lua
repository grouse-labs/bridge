---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param player string|integer  The `player` server ID or src.
---@param text string The notify `text` as a string.
---@param _type 'error'|'success'|'primary'? The notify type. <br> Defaults to `'primary'`.
---@param time integer? The notify `time` in milliseconds.
function notify.text(player, text, _type, time)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'text\' (number or string expected, got '..player..')', 2) end
  if not text or type(text) ~= 'string' then error('bad argument #2 to \'text\' (string expected, got '..type(text)..')', 2) end
  qbxport:Notify(player, text, _type, time)
end

---@param player string|integer  The `player` server ID or src.
---@param item string The item name as a string.
---@param amount integer? The item `amount` as a number. <br> Defaults to `1`.
---@param text string? The notify `text` as a string.
function notify.item(player, item, amount, text)
  if not IsSrcAPlayer(player) then error('bad argument #1 to \'item\' (number or string expected, got '..player..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #4 to \'item\' (string expected, got '..type(text)..')', 2) end
  if text then notify.text(player, text) end
end

--------------------- OBJECT ---------------------
getmetatable(notify).__newindex = function() error('attempt to edit a read-only object', 2) end

return notify

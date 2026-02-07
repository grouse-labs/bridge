---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param text string The notify `text` as a string.
---@param _type 'error'|'success'|'primary'? The notify type. <br> Defaults to `'primary'`.
---@param time integer? The notify `time` in milliseconds.
function notify.text(text, _type, time)
  if not text or type(text) ~= 'string' then error('bad argument #1 to \'text\' (string expected, got '..type(text)..')', 2) end
  qbxport:Notify(text, _type, time)
end

---@param item string The item name as a string.
---@param amount integer? The item `amount` as a number. <br> Defaults to `1`.
---@param text string? The notify `text` as a string.
function notify.item(item, amount, text)
  if text then notify.text(text) end
end

--------------------- OBJECT ---------------------
getmetatable(notify).__newindex = function() error('attempt to edit a read-only object', 2) end

return notify

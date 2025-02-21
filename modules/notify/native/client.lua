local notify = 'native'
if notify ~= GetResourceMetadata('bridge', 'notify', 0) then return end

local txd = CreateRuntimeTxd('bridge_notify')
local IMAGE_PATH <const> = 'qb-inventory/html/images/?.png;ox_inventory/web/images/?.png'

--------------------- FUNCTIONS ---------------------

---@param dict string
---@return boolean loaded
local function load_texture_dict(dict)
  if not HasStreamedTextureDictLoaded(dict) then
    RequestStreamedTextureDict(dict, true)
    repeat Wait(0) until HasStreamedTextureDictLoaded(dict)
  end
  return HasStreamedTextureDictLoaded(dict)
end

---@param ped integer
---@return integer|false handle
local function load_ped_headshot(ped)
  local handle = RegisterPedheadshot(ped)
  if not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) then
    repeat Wait(0) until IsPedheadshotReady(handle) and IsPedheadshotValid(handle)
  end
  return handle
end

---@param dict string
---@param txd_name string
---@param icon integer
---@param title string
---@param text string
local function feed_post_msg_text(dict, txd_name, icon, title, text)
  BeginTextCommandThefeedPost('')
  EndTextCommandThefeedPostMessagetext(dict, txd_name, true, icon, title, text)
  EndTextCommandThefeedPostTicker(false, true)
end

---@param text string
---@param notify_type 'error'|'success'|'primary'? @default 'primary'
local function text_notify(text, notify_type)
  if not text or type(text) ~= 'string' then error('bad argument #1 to \'TextNotify\' (string expected, got '..type(text)..')', 2) end
  local handle = load_ped_headshot(PlayerPedId())
  if not handle then return end
  local headshot_txd = GetPedheadshotTxdString(handle)
  local title = notify_type == 'error' and '~r~Error~w~~s~' or notify_type == 'success' and '~g~Success~w~~s~' or 'Notification'
  feed_post_msg_text(headshot_txd, headshot_txd, 1, title, text)
  UnregisterPedheadshot(handle)
end

---@param item string
---@param amount integer?
---@param text string?
local function item_notify(item, amount, text)
  if not item or type(item) ~= 'string' then error('bad argument #1 to \'ItemNotify\' (string expected, got '..type(item)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #2 to \'ItemNotify\' (number expected, got '..type(amount)..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #3 to \'ItemNotify\' (string expected, got '..type(text)..')', 2) end
  local path = ''
  for subpath in IMAGE_PATH:gmatch('[^;]+') do
    if path ~= '' then break end
    local resource = subpath:match('^%@?(%w+%_?%-?%w+)')
    local dir = subpath:match('^%@?%w+%_?%-?%w+(.*)')
    local tmp_U, tmp_L = item:upper(), item:lower()
    if LoadResourceFile(resource, dir:gsub('%?', item)) then
      path = subpath:gsub('%?', item)
    elseif LoadResourceFile(resource, dir:gsub('%?', tmp_U)) then
      path = subpath:gsub('%?', tmp_U)
    elseif LoadResourceFile(resource, dir:gsub('%?', tmp_L)) then
      path = subpath:gsub('%?', tmp_L)
    end
  end
  if path == '' then error(('Item image for %s not found'):format(item), 2) end
  local dui = CreateDui('https://cfx-nui-'..path, 100, 100)
  local handle = GetDuiHandle(dui)
  CreateRuntimeTextureFromDuiHandle(txd, item, handle)
  if not load_texture_dict('bridge_notify') then return end
  amount = amount or 1
  local title = amount >= 1 and '~g~Item Found~w~~s~' or '~r~Item Lost~w~~s~'
  feed_post_msg_text('bridge_notify', item, 1, title, text or ('You %s %s x %s'):format(amount >= 1 and 'found' or 'lost', tostring(math.abs(amount)), item:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper()..rest:lower()
  end)))
  SetStreamedTextureDictAsNoLongerNeeded('bridge_notify')
end

--------------------- OBJECT ---------------------

return {
  text = text_notify,
  item = item_notify
}
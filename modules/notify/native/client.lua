local notify = 'native'
if notify ~= GetResourceMetadata('bridge', 'notify', 0) then return end

local txd = CreateRuntimeTxd('bridge_notify')
local IMAGE_PATH <const> = 'https://cfx-nui-qb-inventory/html/images/?.png'

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

---@param text string
---@param notify_type 'error'|'success'|'primary'? @default 'primary'
local function text_notify(text, notify_type)
  if not text or type(text) ~= 'string' then error('bad argument #1 to \'TextNotify\' (string expected, got '..type(text)..')', 2) end
  local handle = load_ped_headshot(PlayerPedId())
  if not handle then return end
  local headshot_txd = GetPedheadshotTxdString(handle)
  local title = notify_type == 'error' and 'Error' or notify_type == 'success' and 'Success' or 'Notification'
  BeginTextCommandThefeedPost('')
  EndTextCommandThefeedPostMessagetext(headshot_txd, headshot_txd, true, 1, title, text)
  EndTextCommandThefeedPostTicker(false, true)
  UnregisterPedheadshot(handle)
end

---@param item string
---@param amount integer?
---@param text string?
local function item_notify(item, amount, text)
  if not item or type(item) ~= 'string' then error('bad argument #1 to \'ItemNotify\' (string expected, got '..type(item)..')', 2) end
  if amount and type(amount) ~= 'number' then error('bad argument #2 to \'ItemNotify\' (number expected, got '..type(amount)..')', 2) end
  if text and type(text) ~= 'string' then error('bad argument #3 to \'ItemNotify\' (string expected, got '..type(text)..')', 2) end
  local dui = CreateDui(IMAGE_PATH:gsub('%?', item), 100, 100)
  local handle = GetDuiHandle(dui)
  CreateRuntimeTextureFromDuiHandle(txd, item, handle)
  if not load_texture_dict('bridge_notify') then return end
  BeginTextCommandThefeedPost('')
  EndTextCommandThefeedPostMessagetext('bridge_notify', item, true, 0, 'Item Found', ('You found %s x %s'):format(tostring(amount), not text and item:gsub('_', ' '):gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper()..rest:lower()
  end) or text))
  EndTextCommandThefeedPostTicker(false, true)
  SetStreamedTextureDictAsNoLongerNeeded('bridge_notify')
end

--------------------- OBJECT ---------------------

return {
  text = text_notify,
  item = item_notify
}
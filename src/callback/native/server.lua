--[[
  https://github.com/overextended/ox_lib

  This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

  Copyright © 2025 Linden <https://github.com/thelindat>
]]

local CALLBACK <const> = 'native'
if CALLBACK ~= GetConvar('bridge:callback', 'ox_lib') then error('invalid callback resource name', 0) end

local RES_NAME <const> = bridge._CURRENT_RESOURCE
local VERSION <const> = bridge._VERSION
local CB_EVENT <const> = '__gr_cb_%s'
local invoke = Citizen.InvokeNative
local Callbacks = {}

--------------------- UNTILITIES ---------------------

---@param key string The key of the callback to call.
---@param ... any Additional arguments to pass to the callback.
local function callback(key, ...)
  local cb = Callbacks[key] --[[@as function?]]

  if not cb then return end

  Callbacks[key] = nil

  cb(...)
end

---@param error string?
---@return string?
local function get_formated_stack_trace(error) -- Based on [doStackFormat](https://github.com/citizenfx/fivem/blob/476f550dfb5d35b53ff9db377445be76db7c28bc/data/shared/citizen/scripting/lua/scheduler.lua#L482)
  local stack_trace = invoke(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())
  return stack_trace and string.format('^1SCRIPT ERROR: %s^7\n%s', error or '', stack_trace) or stack_trace
end

---@param success boolean
---@param result any
---@param ... any
---@return any, any
local function receive_callback(success, result, ...)
  if not success then
    if result then
      return print(get_formated_stack_trace(result))
    end
    return false
  end

  return result, ...
end

--------------------- FUNCTIONS ---------------------

---@return 'native'
local function get_callback() return CALLBACK end

---@return string version
local function get_version() return VERSION end

---@param name string The name of the callback to create.
---@param cb function The function to call when the callback is triggered.
local function register_callback(name, cb)
  if not name or type(name) ~= 'string' then error('bad argument #1 to \'RegisterCallback\' (string expected, got '..type(name)..')', 2) end
  if not cb or type(cb) ~= 'function' then error('bad argument #2 to \'RegisterCallback\' (function expected, got '..type(cb)..')', 2) end

  RegisterNetEvent(CB_EVENT:format(name), function(resource, key, ...)
    TriggerClientEvent(CB_EVENT:format(resource), key, receive_callback(pcall(cb, ...)))
  end)
end

---@param player integer|string? The `player` to trigger the callback for. <br> If `nil`, the callback will be triggered for the function source.
---@param name string The name of the callback to trigger.
---@param cb function The function to call when the callback is received.
---@param ... any Additional arguments to pass to the callback.
local function trigger_callback(player, name, cb, ...)
  if not IsSrcValid(player or source) then error('bad argument #1 to \'TriggerCallback\' (number or string expected, got '..player..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'TriggerCallback\' (string expected, got '..type(name)..')', 2) end

  local src = player or source
  local key
  repeat
    key = string.format('%s:%s:%s', name, math.random(0, 100000), src)
  until not Callbacks[key]

  TriggerClientEvent(string.format(CB_EVENT, name), src, RES_NAME, key, ...)

  local p = not cb and promise.new()

  Callbacks[key] = function(response, ...)
    response = {response, ...}
    if p then
      return p:resolve(response)
    else
      cb(table.unpack(response))
    end
  end

  if p then
    SetTimeout(5000, function() p:reject(('callback event \'%s\' timed out'):format(key)) end)
    return table.unpack(Citizen.Await(p))
  end
end

---@param player integer|string? The `player` to trigger the callback for. <br> If `nil`, the callback will be triggered for the function source.
---@param name string The name of the callback to trigger.
---@param ... any Additional arguments to pass to the callback.
---@return ... result
local function await_callback(player, name, ...)
  if not IsSrcValid(player or source) then error('bad argument #1 to \'AwaitCallback\' (number or string expected, got '..player..')', 2) end
  if not name or type(name) ~= 'string' then error('bad argument #2 to \'AwaitCallback\' (string expected, got '..type(name)..')', 2) end
  local src = player or source
  ---@diagnostic disable-next-line: param-type-mismatch
  return trigger_callback(src, name, nil, ...)
end

--------------------- EVENTS ---------------------

RegisterNetEvent(string.format(CB_EVENT, RES_NAME), callback)

--------------------- OBJECT ---------------------

return {
  _CALLBACK = CALLBACK,
  _VERSION = VERSION,
  getcallback = get_callback,
  getversion = get_version,
  register = register_callback,
  trigger = trigger_callback,
  await = await_callback
}
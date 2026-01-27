---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param player integer|string The `player` who is changing the door state.
---@param door_id string The `door_id` to change the state of.
---@param state 0|1|boolean Locks `door_id` if state is true or 1.
---@param picked boolean Whether the door was lockpicked by a player.
function doorlock.setstate(player, door_id, state, picked)
  local src = tonumber(player or source)
  if not IsSrcAPlayer(src) then error('bad argument #1 to \'setstate\' (number or string expected, got '..player..')', 2) end
  if not door_id or type(door_id) ~= 'string' then error('bad argument #2 to \'setstate\' (string expected, got '..type(door_id)..')', 2) end
  if state == nil or state < 0 or state > 1 or type(state) ~= 'boolean' then error('bad argument #3 to \'setstate\' (boolean expected, got '..type(state)..')', 2) end
  if picked == nil or type(picked) ~= 'boolean' then error('bad argument #4 to \'setstate\' (boolean expected, got '..type(picked)..')', 2) end
  TriggerEvent('qb-doorlock:server:updateState', door_id, state == true, picked == true, false, true, true)
end

--------------------- OBJECT ---------------------
getmetatable(doorlock).__newindex = function() error('attempt to edit a read-only object', 2) end

return doorlock
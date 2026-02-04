---@diagnostic disable: duplicate-set-field
--------------------- FUNCTIONS ---------------------

---@param player integer|string The `player` who is changing the door state.
---@param door_id string The `door_id` to change the state of.
---@param state boolean Locks `door_id` if state is true.
---@param picked boolean? Whether the door was lockpicked by a player.
function doorlock.setstate(player, door_id, state, picked)
  local src = tonumber(player or source)
  if not IsSrcAPlayer(src) then error('bad argument #1 to \'setstate\' (number or string expected, got '..type(player)..')', 2) end
  if not door_id or type(door_id) ~= 'string' then error('bad argument #2 to \'setstate\' (string expected, got '..type(door_id)..')', 2) end
  if state == nil or type(state) ~= 'boolean' then error('bad argument #3 to \'setstate\' (boolean expected, got '..type(state)..')', 2) end
  local door = ox_doorlock:getDoorFromName(door_id)
  if not door then error('bad argument #2 to \'setstate\' (door does not exist)', 2) end
  ox_doorlock:setDoorState(door.id, state, picked == true)
end

--------------------- OBJECT ---------------------
getmetatable(doorlock).__newindex = function() error('attempt to edit a read-only object', 2) end

return doorlock
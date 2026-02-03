---@diagnostic disable: duplicate-set-field
local TARGET <const> = 'ox_target'
if TARGET ~= MODULE_NAMES.target then return end
if not IsResourceValid(TARGET) and IsResourceValid('qb-target') then error('target resource `'..TARGET..'` not valid', 0) end

local ox_target = exports[TARGET] --[[@as ox_target]]

local VERSION <const> = GetResourceMetadata(TARGET, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('target')[TARGET]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then warn(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(TARGET, MIN_VERSION, VERSION)) end

---@type CTarget
---@diagnostic disable-next-line: missing-fields
local target = {}

--------------------- FUNCTIONS ---------------------

---@return 'ox_target'
function target.getname() return TARGET end

---@return string version
function target.getversion() return VERSION end

---@return ox_target
function target.getobject() return ox_target end

---@param entities integer|integer[] The entity or entities to add a target to.
---@param options target_options[] The options for the target.
function target.addlocalentity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'addlocalentity\' (number or table expected, got '..type(entities)..')', 2) end
  if not options then error('bad argument #2 to \'addlocalentity\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addlocalentity\' (options invalid)', 2) end
  ox_target:addLocalEntity(entities, converted_options)
end

---@param entities integer|integer[] The entity or entities to remove a target from.
---@param options string|string[] The target or targets to remove from the entity.
function target.removelocalentity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'removelocalentity\' (number or table expected, got '..type(entities)..')', 2) end
  if type(options) == 'string' then options = {options} end
  if type(options) ~= 'table' then error('bad argument #2 to \'removelocalentity\' (string or table expected, got '..type(options)..')', 2) end
  ox_target:removeLocalEntity(entities, options)
end

---@param models string|number|(string|number)[] The model or models to add a target to.
---@param options target_options[] The options for the target.
function target.addmodel(models, options)
  if type(models) == 'string' then models = {models} end
  if type(models) ~= 'table' then error('bad argument #1 to \'addmodel\' (string or table expected, got '..type(models)..')', 2) end
  if not options then error('bad argument #2 to \'addmodel\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addmodel\' (options invalid)', 2) end
  ox_target:addModel(models, converted_options)
end

---@param models string|number|(string|number)[] The entity or entities to remove a target from.
---@param options string|string[] The target or targets to remove from the entity.
function target.removemodel(models, options)
  if type(models) == 'string' then models = {models} end
  if type(models) ~= 'table' then error('bad argument #1 to \'removemodel\' (string or table expected, got '..type(models)..')', 2) end
  if type(options) == 'string' then options = {options} end
  if type(options) ~= 'table' then error('bad argument #2 to \'removemodel\' (string or table expected, got '..type(options)..')', 2) end
  ox_target:removeModel(models, options)
end

---@param data {center: vector3, radius: number?, debug: boolean?} The data for the sphere zone.
---@param options target_options[] The options for the target.
---@return integer|string? box_zone The ID of the sphere zone. <br> If using ox_target, the integer ID of the zone is returned. <br> If using qb-target, the string name of the zone is returned.
function target.addspherezone(data, options)
  if not data then error('bad argument #1 to \'addboxzone\' (table expected, got nil)', 2) end
  if not options then error('bad argument #2 to \'addboxzone\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addboxzone\' (options invalid)', 2) end
  return ox_target:addSphereZone({
    coords = data.center,
    radius = data.radius,
    debug = data.debug or false,
    options = converted_options
  })
end

---@param data {center: vector3, size: vector3, heading: number?, debug: boolean?} The data for the box zone.
---@param options target_options[] The options for the target.
---@return integer|string? box_zone The ID of the box zone. <br> If using ox_target, the integer ID of the zone is returned. <br> If using qb-target, the string name of the zone is returned.
function target.addboxzone(data, options)
  if not data then error('bad argument #1 to \'addboxzone\' (table expected, got nil)', 2) end
  if not options then error('bad argument #2 to \'addboxzone\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addboxzone\' (options invalid)', 2) end
  return ox_target:addBoxZone({
    coords = data.center,
    size = data.size,
    rotation = data.heading or 0,
    debug = data.debug or false,
    options = converted_options
  })
end

---@param box_zone integer|string The ID of the box zone to remove.
function target.removezone(box_zone) ox_target:removeZone(box_zone) end

--------------------- OBJECT ---------------------

return setmetatable(target, {
  __name = 'target',
  __version = VERSION,
  __tostring = function(t)
    local address = string.format('target: %p', t)
    return bridge._DEBUG and string.format('^3[%s]^7 - ^target library^7 ^5\'%s\'^7 v^5%s^7\n%s', bridge._RESOURCE, TARGET, VERSION, address) or address
  end,
  __newindex = function() error('attempt to edit a read-only object', 2) end
})

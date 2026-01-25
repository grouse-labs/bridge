---@diagnostic disable: duplicate-set-field
local TARGET <const> = 'qb-target'
if TARGET ~= MODULE_NAMES.target then return end
if not IsResourceValid(TARGET) and IsResourceValid('ox_target') then error('target resource `'..TARGET..'` not valid', 0) end

local qb_target = exports[TARGET]

local VERSION <const> = GetResourceMetadata(TARGET, 'version', 0)
local MIN_VERSION <const> = BRIDGE_VERSIONS:lookup('target')[TARGET]
if VERSION:gsub('%D', '') < MIN_VERSION:gsub('%D', '') then warn(('incompatible version of `%s` detected (expected `%s` or higher, got `%s`)'):format(TARGET, MIN_VERSION, VERSION)) end

---@type CTarget
---@diagnostic disable-next-line: missing-fields
local target = {}

--------------------- FUNCTIONS ---------------------

---@return 'qb-target'
function target.getname() return TARGET end

---@return string version
function target.getversion() return VERSION end

---@return table
function target.getobject() return qb_target end

---@param entities integer|integer[] The entity or entities to add a target to.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: fun(entity: integer, distance: number)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
function target.addlocalentity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'addlocalentity\' (number or table expected, got '..type(entities)..')', 2) end
  if not options then error('bad argument #2 to \'addlocalentity\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addlocalentity\' (options invalid)', 2) end
  qb_target:AddTargetEntity(entities, {options = converted_options, distance = converted_options[1].distance or 2.5})
end

---@param entities integer|integer[] The entity or entities to remove a target from.
---@param options string|string[] The target or targets to remove from the entity.
function target.removelocalentity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'removelocalentity\' (number or table expected, got '..type(entities)..')', 2) end
  if type(options) == 'string' then options = {options} end
  if type(options) ~= 'table' then error('bad argument #2 to \'removelocalentity\' (string or table expected, got '..type(options)..')', 2) end
  qb_target:RemoveTargetEntity(entities, options)
end

---@param data {center: vector3, radius: number?, debug: boolean?} The data for the sphere zone.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: (fun(entity: integer, distance: number): boolean?)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
---@return integer|string? box_zone The ID of the sphere zone. <br> If using ox_target, the integer ID of the zone is returned. <br> If using qb-target, the string name of the zone is returned.
function target.addspherezone(data, options)
  if not data then error('bad argument #1 to \'addboxzone\' (table expected, got nil)', 2) end
  if not options then error('bad argument #2 to \'addboxzone\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addboxzone\' (options invalid)', 2) end
  local name = converted_options[1].name or converted_options[1].label
  qb_target:AddCircleZone(name, data.center, data.radius or 1.5, {
    name = name,
    debugPoly = data.debug or false,
  }, {
    options = converted_options,
    distance = options[1].distance or 2.5
  })
  return name
end

---@param data {center: vector3, size: vector3, heading: number?, debug: boolean?} The data for the box zone.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: (fun(entity: integer, distance: number): boolean?)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
---@return integer|string? box_zone The ID of the box zone. <br> If using ox_target, the integer ID of the zone is returned. <br> If using qb-target, the string name of the zone is returned.
function target.addboxzone(data, options)
  if not data then error('bad argument #1 to \'addboxzone\' (table expected, got nil)', 2) end
  if not options then error('bad argument #2 to \'addboxzone\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'addboxzone\' (options invalid)', 2) end
  local name = converted_options[1].name or converted_options[1].label
  local size = data.size
  local center = data.center
  local min_z, max_z = center.z - size.z / 2, center.z + size.z / 2
  qb_target:AddBoxZone(name, data.center, size.x, size.y, {
    name = name,
    heading = data.heading or 0,
    debugPoly = data.debug or false,
    minZ = min_z,
    maxZ = max_z,
  }, {
    options = converted_options,
    distance = options[1].distance or 2.5
  })
  return name
end

---@param box_zone integer|string The ID of the box zone to remove.
function target.removezone(box_zone) qb_target:RemoveZone(box_zone) end

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

local TARGET <const> = 'qb-target'
if TARGET ~= GetConvar('bridge:target', 'native') then error('invalid target resource name', 0) end
if not IsResourceValid(TARGET) and IsResourceValid('ox_target') then error('target resource `'..TARGET..'` not valid', 0) end

local qb_target = exports[TARGET]
local VERSION <const> = GetResourceMetadata(TARGET, 'version', 0)
-- if VERSION:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..framework..' detected (expected 1.3.0 or higher, got '..VERSION..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'qb-target'
local function get_target() return TARGET end

---@return string version
local function get_version() return VERSION end

---@return ox_target
local function get_object() return qb_target end

---@param entities integer|integer[] The entity or entities to add a target to.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: fun(entity: integer, distance: number)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
local function add_local_entity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'AddLocalEntity\' (number or table expected, got '..type(entities)..')', 2) end
  if not options then error('bad argument #2 to \'AddLocalEntity\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'AddLocalEntity\' (options invalid)', 2) end
  qb_target:AddTargetEntity(entities, {options = converted_options, distance = converted_options[1].distance or 2.5})
end

---@param entities integer|integer[] The entity or entities to remove a target from.
---@param options string|string[] The target or targets to remove from the entity.
local function remove_local_entity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'RemoveLocalEntity\' (number or table expected, got '..type(entities)..')', 2) end
  if type(options) == 'string' then options = {options} end
  if type(options) ~= 'table' then error('bad argument #2 to \'RemoveLocalEntity\' (string or table expected, got '..type(options)..')', 2) end
  qb_target:RemoveTargetEntity(entities, options)
end

---@param data {center: vector3, size: vector3, heading: number?, debug: boolean?} The data for the box zone.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: (fun(entity: integer, distance: number): boolean?)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
---@return integer|string? box_zone The ID of the box zone. <br> If using ox_target, the integer ID of the box zone is returned. <br> If using qb-target, the string name of the box zone is returned.
local function add_box_zone(data, options)
  if not data then error('bad argument #1 to \'AddBoxZone\' (table expected, got nil)', 2) end
  if not options then error('bad argument #2 to \'AddBoxZone\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'AddBoxZone\' (options invalid)', 2) end
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
local function remove_box_zone(box_zone) qb_target:RemoveZone(box_zone) end

--------------------- OBJECT ---------------------

return {
  _TARGET = TARGET,
  _VERSION = VERSION,
  gettarget = get_target,
  getversion = get_version,
  getobject = get_object,
  addlocalentity = add_local_entity,
  removelocalentity = remove_local_entity,
  addboxzone = add_box_zone,
  removeboxzone = remove_box_zone
}
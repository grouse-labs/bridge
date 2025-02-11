local target = 'ox_target'
if target ~= GetResourceMetadata('bridge', 'target', 0) then return end
if not IsResourceValid(target) then return end

local ox_target = exports[target] --[[@as ox_target]]
local version = GetResourceMetadata(target, 'version', 0)
-- if version:gsub('%D', '') < ('1.3.0'):gsub('%D', '') then error('incompatible version of '..framework..' detected (expected 1.3.0 or higher, got '..version..')', 0) end

--------------------- FUNCTIONS ---------------------

---@return 'ox_target'
local function get_target() return target end

---@return string version
local function get_version() return version end

---@return ox_target
local function get_object() return ox_target end

---@param entities integer|integer[] The entity or entities to add a target to.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: fun(entity: integer, distance: number)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
local function add_local_entity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'AddLocalEntity\' (number or table expected, got '..type(entities)..')', 2) end
  if not options then error('bad argument #2 to \'AddLocalEntity\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'AddLocalEntity\' (options invalid)', 2) end
  ox_target:addLocalEntity(entities, converted_options)
end

---@param entities integer|integer[] The entity or entities to remove a target from.
---@param options string|string[] The target or targets to remove from the entity.
local function remove_local_entity(entities, options)
  if type(entities) == 'number' then entities = {entities} end
  if type(entities) ~= 'table' then error('bad argument #1 to \'RemoveLocalEntity\' (number or table expected, got '..type(entities)..')', 2) end
  if type(options) == 'string' then options = {options} end
  if type(options) ~= 'table' then error('bad argument #2 to \'RemoveLocalEntity\' (string or table expected, got '..type(options)..')', 2) end
  ox_target:removeLocalEntity(entities, options)
end

---@param data {center: vector3, size: vector3, heading: number?, debug: boolean?} The data for the box zone.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: (fun(entity: integer, distance: number): boolean?)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
---@return integer|string? box_zone The ID of the box zone. <br> If using ox_target, the integer ID of the box zone is returned. <br> If using qb-target, the string name of the box zone is returned.
local function add_box_zone(data, options)
  if not data then error('bad argument #1 to \'AddBoxZone\' (table expected, got nil)', 2) end
  if not options then error('bad argument #2 to \'AddBoxZone\' (table expected, got nil)', 2) end
  local converted_options = ConvertTargetOptions(options)
  if not converted_options then error('bad argument #2 to \'AddBoxZone\' (options invalid)', 2) end
  return ox_target:addBoxZone({
    coords = data.center,
    size = data.size,
    rotation = data.heading or 0,
    debug = data.debug or false,
    options = converted_options
  })
end

---@param box_zone integer|string The ID of the box zone to remove.
local function remove_box_zone(box_zone) ox_target:removeZone(box_zone) end

--------------------- OBJECT ---------------------

return {
  _TARGET = target,
  _VERSION = version,
  gettarget = get_target,
  getversion = get_version,
  getobject = get_object,
  addlocalentity = add_local_entity,
  removelocalentity = remove_local_entity,
  addboxzone = add_box_zone,
  removeboxzone = remove_box_zone
}
---@diagnostic disable: duplicate-set-field
local TARGET <const> = 'ox_target'
if TARGET ~= GetConvar('bridge:target', 'ox_target') then error('invalid target resource name', 0) end
if not IsResourceValid(TARGET) and IsResourceValid('qb-target') then error('target resource `'..TARGET..'` not valid', 0) end

local ox_target = exports[TARGET] --[[@as ox_target]]
local VERSION <const> = GetResourceMetadata(TARGET, 'version', 0)
if VERSION:gsub('%D', '') < ('1.17.1'):gsub('%D', '') then error('incompatible version of '..TARGET..' detected (expected 1.17.1 or higher, got '..VERSION..')', 0) end

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
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: fun(entity: integer, distance: number)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
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

---@param data {center: vector3, size: vector3, heading: number?, debug: boolean?} The data for the box zone.
---@param options {name: string?, label: string, icon: string?, distance: number?, item: string?, canInteract: (fun(entity: integer, distance: number): boolean?)?, onSelect: fun()?, event_type: string?, event: string?, jobs: string|string[]?, gangs: string|string[]?}[] The options for the target.
---@return integer|string? box_zone The ID of the box zone. <br> If using ox_target, the integer ID of the box zone is returned. <br> If using qb-target, the string name of the box zone is returned.
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
function target.removeboxzone(box_zone) ox_target:removeZone(box_zone) end

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

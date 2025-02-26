local RESOURCE_NAME <const> = GetCurrentResourceName()
local NOTIFY <const> = GetResourceMetadata(RESOURCE_NAME, 'notify', 0)
local load, load_resource_file = load, LoadResourceFile
local dir = 'modules/notify/'..NOTIFY..'/client.lua'
local notify --[[@type CNotify]] = load(load_resource_file(RESOURCE_NAME, dir), '@'..RESOURCE_NAME..'/'..dir, 't', _ENV)()
if NOTIFY ~= 'native' then return end

--------------------- EVENTS ---------------------

RegisterNetEvent('bridge:client:Notify', notify.text)
RegisterNetEvent('bridge:client:ItemNotify', notify.item)
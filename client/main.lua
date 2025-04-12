local RESOURCE <const> = 'bridge'
local NOTIFY <const> = GetConvar('bridge:notify', 'native')
if NOTIFY ~= 'native' then return end
local load, load_resource_file = load, LoadResourceFile
local dir = 'modules/notify/'..NOTIFY..'/client.lua'
local notify = load(load_resource_file(RESOURCE, dir), '@'..RESOURCE..'/'..dir, 't', _ENV)() --[[@module 'bridge.modules.notify.native.client']]

--------------------- EVENTS ---------------------

RegisterNetEvent('bridge:client:Notify', notify.text)
RegisterNetEvent('bridge:client:ItemNotify', notify.item)
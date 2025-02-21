local NOTIFY <const> = GetResourceMetadata('bridge', 'notify', 0)
local load, load_resource_file = load, LoadResourceFile
local dir = 'modules/notify/'..NOTIFY..'/client.lua'
local notify --[[@type CNotify]] = load(load_resource_file('bridge', dir), '@bridge/'..dir, 't', _ENV)()

--------------------- EVENTS ---------------------

RegisterNetEvent('bridge:client:Notify', notify.text)
RegisterNetEvent('bridge:client:ItemNotify', notify.item)
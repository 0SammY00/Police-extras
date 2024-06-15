ESX = exports['es_extended']:getSharedObject()

RegisterServerEvent('checkPlayerJob')
AddEventHandler('checkPlayerJob', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob().name
    TriggerClientEvent('receivePlayerJob', source, job)
end)

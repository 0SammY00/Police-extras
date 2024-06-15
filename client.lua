ESX = exports['es_extended']:getSharedObject()

local locations = {
    vector3(440.2525, -1026.4542, 28.4578),  -- Mission row
    vector3(-473.7588, 6023.2720, 31.0431)  -- Blaine Country Sheriff Officer
}
local isInMarker = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        isInMarker = false

        for _, coords in pairs(locations) do
            if Vdist(playerCoords, coords) < 10.0 then
                DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 0, 155, 255, 100, false, true, 2, false, false, false, false)
                if Vdist(playerCoords, coords) < 1.0 then
                    isInMarker = true
                    ESX.ShowHelpNotification("Stlacte E pre extras menu.")
                    if IsControlJustReleased(0, 38) then -- E key
                        TriggerServerEvent('checkPlayerJob')
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('receivePlayerJob')
AddEventHandler('receivePlayerJob', function(job)
    if job == 'sheriff' or job == 'police' then
        OpenVehicleCustomizationMenu()
    else
        ESX.ShowNotification("Nemas opravnenie na pouzitie.")
    end
end)

function OpenVehicleCustomizationMenu()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle == 0 then
        ESX.ShowNotification("Nie ste vo vozidle.")
        return
    end
    
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_customization',
        {
            title    = "Uprava vozidla",
            align    = 'top-left',
            elements = {
                {label = "Livery", value = 'livery'},
                {label = "Extras", value = 'extras'}
            }
        },
        function(data, menu)
            if data.current.value == 'livery' then
                OpenLiveryMenu(vehicle)
            elseif data.current.value == 'extras' then
                OpenExtrasMenu(vehicle)
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenLiveryMenu(vehicle)
    local elements = {}
    for i = 0, GetVehicleLiveryCount(vehicle) - 1 do
        table.insert(elements, {label = "Livery " .. i, value = i})
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_livery',
        {
            title    = "Vyberte livery",
            align    = 'top-left',
            elements = elements
        },
        function(data, menu)
            SetVehicleLivery(vehicle, data.current.value)
            menu.close()
        end,
        function(data, menu)
            menu.close()
        end
    )
end

function OpenExtrasMenu(vehicle)
    local elements = {}
    for i = 0, 20 do
        if DoesExtraExist(vehicle, i) then
            local label = "Extra " .. i
            local state = IsVehicleExtraTurnedOn(vehicle, i)
            table.insert(elements, {label = label .. (state and " [NASADENE]" or " [NENASADENE]"), value = i, state = state})
        end
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_extras',
        {
            title    = "Vyberte extras",
            align    = 'top-left',
            elements = elements
        },
        function(data, menu)
            local newState = not data.current.state
            SetVehicleExtra(vehicle, data.current.value, newState and 0 or 1)
            data.current.label = "Extra " .. data.current.value .. (newState and " [On]" or " [Off]")
            data.current.state = newState
            menu.refresh()
        end,
        function(data, menu)
            menu.close()
        end
    )
end

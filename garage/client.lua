local _menuPool = NativeUI.CreatePool()

CreateThread(function()
    while true do 
        -- local sleep = 350
        -- if _menuPool:IsAnyMenuOpen() then
            _menuPool:ProcessMenus()
            sleep = 1
        -- end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.garage) do
        local blip = AddBlipForCoord(v.coords)

        SetBlipSprite(blip, v.blip)
        SetBlipScale(blip, v.blipgrose)
        SetBlipColour(blip, v.blipfarbe)
        SetBlipDisplay(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Garage')
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 320
        local playerPed = PlayerPedId()

        for k, v in pairs(Config.garage) do
            local distance = #(GetEntityCoords(playerPed) - v.coords)
            DrawMarker(27, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 65, 160, 255, 100, false, true, 2, true, false, false, false)
            if distance <= 1 then
                ESX.ShowHelpNotification('Drücke ~g~E, ~w~um zu Interagieren')
                if IsControlJustPressed(0, 38) then
                    local garageMenu = NativeUI.CreateMenu(k, 'Parke deine Autos -ein/Aus')

                    garageMenu:Visible(true)




                    local ausparkenItem = _menuPool:AddSubMenu(garageMenu, "Autos Ausparken", "")
                    -- ausparkenItem.Item:RightLabel("→→→")


                    local einparkenItem = _menuPool:AddSubMenu(garageMenu, "Autos Einparken", "")
                    -- ausparkenItem.Item:RightLabel("→→→")



                    vehicles = ESX.Game.GetVehiclesInArea(v.coords, 10.0)
                    for i, vehicle in pairs(vehicles) do
                        local plate = GetVehicleNumberPlateText(vehicle)
                        local props = ESX.Game.GetVehicleProperties(vehicle)
                        ESX.TriggerServerCallback('garage:checkOwner', function(isOwned)
                            if isOwned then 
                                local fahrzeugItem = NativeUI.CreateItem("[ " ..plate.." ] " ..GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), '')
                                einparkenItem:AddItem(fahrzeugItem)
                                fahrzeugItem.Activated = function()
                                    TriggerServerEvent('garage:einparken', props.plate, props)
                                    DeleteVehicle(vehicle)
                                    _menuPool:CloseAllMenus()
                                end
                               
                            end
                        end, props.plate)
                    end


                    ESX.TriggerServerCallback('garage:checkGarage', function(data)
                        
                       for k, carGarage in pairs(data) do
                            local props = json.decode(carGarage.vehicle)
                            local fahrzeuge = NativeUI.CreateItem("[ "..carGarage.plate.. " ] " ..GetDisplayNameFromVehicleModel(props.model), '')
                            ausparkenItem:AddItem(fahrzeuge)
                            fahrzeuge.Activated = function()
                                vehicle = ESX.Game.SpawnVehicle(props.model, v.ausparkcoords[1], v.ausparkcoords[1].w,  function(vehicle) 
                                    ESX.Game.SetVehicleProperties(vehicle, props)
                                end)
                                
                                _menuPool:CloseAllMenus()
                                TriggerServerEvent('garage:ausparken', carGarage.plate)
                            end
                       end
                    end)




                    _menuPool:Add(garageMenu)
                    _menuPool:RefreshIndex()
                    _menuPool:MouseControlsEnabled(false)
                    _menuPool:MouseEdgeEnabled(false)
                    _menuPool:ControlDisablingEnabled(true)

                end
            end

        end

        Wait(0)
    end

end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.impound) do
        local blip = AddBlipForCoord(v.coords)

        SetBlipSprite(blip, v.blip)
        SetBlipScale(blip, v.blipgrose)
        SetBlipColour(blip, v.blipfarbe)
        SetBlipDisplay(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Abschlepphof')
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    while true do 
        local sleep = 250
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for k, v in pairs(Config.impound) do
            local distance = #(playerCoords - v.coords)
            if distance <=  10.0 then 
                sleep = 1
                DrawMarker(27, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 65, 160, 255, 100, false, true, 2, true, false, false, false)
            end
            if distance <= 1.0 then
                ESX.ShowHelpNotification('Drücke ~g~E, ~w~ um zu Interagieren')
                if IsControlJustPressed(0, 38) then 
                    openMenu()
                end
            end

        end
        Wait(sleep)
    end
end)

function openMenu()
    for i, v in pairs(Config.impound) do
        local impoundMenu = NativeUI.CreateMenu(i, 'Abgeschleppte Fahrzeuge')
        _menuPool:Add(impoundMenu)

    
        ESX.TriggerServerCallback('garage:checkImpound', function(data)
                        
            for k, carImpound in pairs(data) do
                 local props = json.decode(carImpound.vehicle)
                 local impoundCars = NativeUI.CreateItem("[ " ..carImpound.plate.. " ] " ..GetDisplayNameFromVehicleModel(props.model), '')
                 impoundMenu:AddItem(impoundCars)
                 impoundCars:RightLabel('250~g~$')
                 impoundCars.Activated = function()
                    TriggerServerEvent('garage:ausparkenImpound', carImpound.plate, props)                     
                 end
            end
         end)

        
        impoundMenu:Visible(true)
        _menuPool:RefreshIndex()
        _menuPool:MouseControlsEnabled (false)
        _menuPool:MouseEdgeEnabled (false)
        _menuPool:ControlDisablingEnabled(false)
    end
end

RegisterNetEvent('garage:changeDbImpound')
AddEventHandler('garage:changeDbImpound', function(props)
    TriggerServerEvent('garage:ImpoundCarOut')
    vehicle = ESX.Game.SpawnVehicle(props.model, vector3(454.29, -1018.74, 28.38), 87.87,  function(vehicle) 
        ESX.Game.SetVehicleProperties(vehicle, props)
    end)
end)
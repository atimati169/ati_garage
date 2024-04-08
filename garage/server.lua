ESX.RegisterServerCallback('garage:checkOwner', function(src, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(src)



    print(plate)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate
    }, function(vehicles)
        for k, v in pairs(vehicles) do 
            if v.plate == plate then 
                cb(true)
            end
        end
    end)
end)


RegisterNetEvent('garage:einparken')
AddEventHandler('garage:einparken', function(plate, props)
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1, vehicle = @props WHERE plate = @plate', {
        ['@props'] = json.encode(props),
        ['@plate'] = plate
    }, function()
    
    end)
end)

ESX.RegisterServerCallback('garage:checkGarage', function(src, cb)
   local xPlayer = ESX.GetPlayerFromId(src)

   
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND stored = 1', {
        ['@owner'] = xPlayer.identifier
    }, function(vehicles)
        cb(vehicles)
    end)

end)

RegisterNetEvent('garage:ausparken')
AddEventHandler('garage:ausparken', function(plate, props)
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = 0 WHERE plate = @plate', {
        ['@plate'] = plate
    }, function()
        
    end)

end)

ESX.RegisterServerCallback('garage:checkImpound', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
 
    
     MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND stored = 0', {
         ['@owner'] = xPlayer.identifier
     }, function(vehicles)
         cb(vehicles)
     end)
 
 end)



RegisterNetEvent('garage:ausparkenImpound')
AddEventHandler('garage:ausparkenImpound', function(plate, props)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= 250 then 
        xPlayer.removeAccountMoney('money', 250)
        xPlayer.showNotification( 'Das Auto mit dem kennzeichen ' ..plate.. ' Wurde ~g~Ausgeparkt')
        TriggerClientEvent('garage:changeDbImpound', source, props)
    else
        xPlayer.showNotification('Du hast nicht so viel ~r~Geld ~w~ dabei')
    end
end)

RegisterNetEvent('garage:ImpoundCarOut')
AddEventHandler('garage:ImpoundCarOut', function(plate, props)
    MySQL.Async.execute('UPDATE owned_vehicles SET stored = 0 WHERE plate = @plate', {
        ['@plate'] = plate
    }, function()
        
    end)
end)

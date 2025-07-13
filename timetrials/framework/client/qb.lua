if GetResourceState('qb-core') ~= 'started' or GetResourceState('qbx_core') == 'started' then return end
if Config.Debug then print('TimeTrials: Using QB Framework') end
local QBCore = exports['qb-core']:GetCoreObject()


function getPlayerData() -- Loads QB player data and sends to data back to client
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData then
        return playerData
    end
end

function notify(text, type)
    if Config.Framework == "standalone" then return end
    if UiIsOpen then
        SendNUIMessage({
            type = "notify",
            data = {
                title = text,
                type = type,
            },
        })
        return
    end
    QBCore.Functions.Notify(text, type)
end

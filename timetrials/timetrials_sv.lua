local json = require('json')
-- Save scores to JSON file
function saveScores(scores)
    local contents = json.encode(scores)
    SaveResourceFile(GetCurrentResourceName(), Config.scoreFileName, contents, -1)
end

-- Load scores from JSON file

function getScores()
    local contents = LoadResourceFile(GetCurrentResourceName(), Config.scoreFileName)
    if contents and contents ~= "" then
        local scores = json.decode(contents)
        return scores
    else
        return {} -- Return an empty table if contents is empty or nil
    end
end


-- Create thread to send scores to clients every 5s
Citizen.CreateThread(function()
    while (true) do
        Citizen.Wait(Config.scoreUpdateTime * 1000)
        TriggerClientEvent('raceReceiveScores', -1, getScores())
    end
end)



-- Save score, give payout, and send chat message when player finishes
RegisterServerEvent('racePlayerFinished')
AddEventHandler('racePlayerFinished', function(source, message, title, newScore, playerID)

    -- Get top car score for this race
    local msgAppend = ""
    local msgSource = source
    local msgColor = Config.color_finish
    local allScores = getScores()
    local raceScores = allScores[title]
    local payout = 0
	local bonus = 0
    if raceScores ~= nil then
        -- Compare top score and update if new one is faster
        local carName = newScore.car
        local carClass = newScore.rating
        local topScore = raceScores[carName]
        if topScore == nil or (topScore.rating == carClass and newScore.time < topScore.time) then
            -- Set new high score
            topScore = newScore
            -- Set message parameters to send to all players for high score
            msgSource = -1
            msgAppend = " (fastest)"
            msgColor = Config.color_highscore
            bonus = Config.Bonus
        end
        raceScores[carName] = topScore
    else
        -- No scores for this race, create struct and set new high score
        raceScores = {}
        raceScores[newScore.car] = newScore
        
        -- Set message parameters to send to all players for high score
        msgSource = -1
        msgAppend = " (fastest)"
        msgColor = Config.color_highscore
    end
    --==============PAYOUT==============
    local totaltime = newScore.time / 1000
    payout = math.floor(bonus + (Config.Reward * totaltime))

    if Config.Framework == "standalone" then
        -- No money for you
    elseif GetResourceState('qb-core') == 'started' then
            local QBCore = exports['qb-core']:GetCoreObject()
            local Player = QBCore.Functions.GetPlayer(playerID)
            Player.Functions.AddMoney("cash", payout)   
    end

        --==================================
    -- Save and store scores back to file
    allScores[title] = raceScores
    saveScores(allScores)
    
    -- Trigger message to all players
    TriggerClientEvent('chatMessage', -1, "[TimeTrials]", msgColor, message .. msgAppend .. "Payout: " .. payout)
    if Config.Debug then
        print("^5[TimeTrials]^6" .. message .. msgAppend)
        print("Payouts: Bonus: " .. bonus .. ". Reward for completing: " .. Config.Reward .. " Time Driven: " .. totaltime .. "|| TOTAL PAYOUT: " .. payout)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    print('^5-TimeTrials 0.8.0 has Started- ')
    if Config.Debug then print("^5[TimeTrials]^6Debug Mode Enabled") end
end)



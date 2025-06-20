local QBCore = exports['qb-core']:GetCoreObject()
-- Filename to store scores
local scoreFileName = "scores.txt"

-- Colors for printing scores
local color_finish = {238, 198, 78}
local color_highscore = {238, 78, 118}


-- Save scores to JSON file
function saveScores(scores)
    local contents = json.encode(scores)
    SaveResourceFile(GetCurrentResourceName(), scoreFileName, contents, -1)
end

-- Load scores from JSON file

function getScores()
    local contents = LoadResourceFile(GetCurrentResourceName(), scoreFileName)
    if contents and contents ~= "" then
        local myTable = json.decode(contents)
        return myTable
    else
        return {} -- Return an empty table if contents is empty or nil
    end
end


-- Create thread to send scores to clients every 5s
Citizen.CreateThread(function()
    while (true) do
        Citizen.Wait(5000)
        TriggerClientEvent('raceReceiveScores', -1, getScores())
    end
end)

-- Save score and send chat message when player finishes
RegisterServerEvent('racePlayerFinished')
AddEventHandler('racePlayerFinished', function(source, message, title, newScore, QBplayer, checkpointTime)

    -- QBCore Setup
    local src = QBplayer
	local xPlayer = QBCore.Functions.GetPlayer(src)
	
    -- Get top car score for this race
    local msgAppend = ""
    local msgSource = source
    local msgColor = color_finish
    local allScores = getScores()
    local raceScores = allScores[title]
    local multiplyer = checkpointTime
    if raceScores ~= nil then
        -- Compare top score and update if new one is faster
        local carName = newScore.car
        local carClass = newScore.rating
        local topScore = raceScores[carName]
        local bonus = 0
        if topScore == nil or (topScore.rating == carClass and newScore.time < topScore.time) then
            -- Set new high score
            topScore = newScore
            -- Set message parameters to send to all players for high score
            msgSource = -1
            msgAppend = " (fastest)"
            msgColor = color_highscore
            bonus = Config.Bonus
        end
        raceScores[carName] = topScore
        xPlayer.Functions.AddMoney("cash", (Config.Bonus + Config.Reward + math.floor(multiplyer)))
    else
        -- No scores for this race, create struct and set new high score
        raceScores = {}
        raceScores[newScore.car] = newScore
        
        -- Set message parameters to send to all players for high score
        msgSource = -1
        msgAppend = " (fastest)"
        msgColor = color_highscore
    end
    
    -- Save and store scores back to file
    allScores[title] = raceScores
    saveScores(allScores)
    
    -- Trigger message to all players
    TriggerClientEvent('chatMessage', -1, "[TimeTrials]", msgColor, message .. msgAppend)
    if Config.Debug == true then
        print("^5[TimeTrials]^6" .. message .. msgAppend)
        print("Payouts: Bonus for fastest time: " .. Config.Bonus .. " Reward for completing: " .. Config.Reward .. " Multiplier: " .. multiplyer)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
        print('^5-TimeTrials 0.7.0 has Started- ')
        print('^5Reward amount is set to ', Config.Reward)
        print('^5Fastest time bonus amount is set to ', Config.Bonus)
        if Config.Debug == true then
            print("^5[TimeTrials]^6Debug Mode Enabled")
        else
            print("^5[TimeTrials]^6Debug Mode Disabled")
        end
end)
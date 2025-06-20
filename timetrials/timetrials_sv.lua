local QBCore = exports['qb-core']:GetCoreObject()
-- Filename to store scores
local scoreFileName = "scores.txt"

-- Colors for printing scores
local color_finish = {238, 198, 78}
local color_highscore = {238, 78, 118}

-- function to reward player
RegisterServerEvent('timetrial:reward')
AddEventHandler('timetrial:reward', function()
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	xPlayer.Functions.AddMoney("cash", Config.Price)
    xPlayer.Functions.AddItem('repairkit', 1)
end)

-- Save scores to JSON file
function saveScores(scores)
    local contents = json.encode(scores)
    SaveResourceFile(GetCurrentResourceName(), scoreFileName, contents, -1)
end

-- Load scores from JSON file
function getScores()
    local contents = ""
    local myTable = {}
    local contents = LoadResourceFile(GetCurrentResourceName(), scoreFileName)
    if contents then
        myTable = json.decode(contents)
		return myTable
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
AddEventHandler('racePlayerFinished', function(source, message, title, newScore)
    -- Get top car score for this race
    local msgAppend = ""
    local msgSource = source
    local msgColor = color_finish
    local allScores = getScores()
    local raceScores = allScores[title]
    if raceScores ~= nil then
        -- Compare top score and update if new one is faster
        local carName = newScore.car
        local carClass = newScore.rating
        local topScore = raceScores[carName]
        if topScore == nil or newScore.time < topScore.time then
            -- Set new high score
            topScore = newScore
            -- Set message parameters to send to all players for high score
            msgSource = -1
            msgAppend = " (fastest)"
            msgColor = color_highscore
            --TriggerServerEvent('ak4y-blackmarket:addXP', 5000)
        end
        raceScores[carName] = topScore
        --TriggerServerEvent('ak4y-blackmarket:addXP', 200)
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
end)


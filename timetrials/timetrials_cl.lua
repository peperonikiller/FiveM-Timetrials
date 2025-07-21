-- State variables
local raceState = {
    cP = 1,
    index = 0 ,
    scores = nil,
    startTime = 0,
    blip = nil,
    checkpoint = nil
}

-- Create preRace thread
Citizen.CreateThread(function()
    preRace()
end)

-- Load Gas Pumps from config, place them on the map if terrain is loaded.
-- Plan to redo this later so it only loads a pump when the player enters the area
Citizen.CreateThread(function()
        for _, coords in ipairs(Config.GasPumpLocations) do
                local object = CreateObject(GetHashKey("prop_gas_pump_1a"), coords[1], coords[2], coords[3], true, false, false)
                FreezeEntityPosition(object, true)   
        end
end)




local function getVehiclePerformanceInfo(vehicle)
    local cwinfo, cwclass, perfRating = exports['cw-performance']:getVehicleInfo(vehicle)
    return cwinfo, cwclass, perfRating
end


-- Function that runs when a race is NOT active
function preRace()
    -- Initialize race state
    raceState.cP = 1
    raceState.index = 0 
    raceState.startTime = 0
    raceState.blip = nil
    raceState.checkpoint = nil
    
    -- While player is not racing
    while raceState.index == 0 do
        -- Update every frame
        Citizen.Wait(0)

        -- Get player
        local player = GetPlayerPed(-1)
        

        -- Loop through all races
        for index, race in pairs(races) do
            if race.isEnabled then
                -- Calculate distance to CP and set marker height
                local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), race.start.x, race.start.y, race.start.z)
                local height = math.min(math.max(distance * 0.1000, 20.0000), 200.0000)
								
                -- Check distance from map marker and draw text if close enough
                if GetDistanceBetweenCoords( race.start.x, race.start.y, race.start.z, GetEntityCoords(player)) < Config.DRAW_TEXT_DISTANCE then
										-- Draw map marker
										DrawMarker(1, race.start.x, race.start.y, race.start.z - 1, 0, 0, 0, 0, 0, 0, 0.2500, 0.2500, height, Config.LOCATION_MARKER[1], Config.LOCATION_MARKER[2], Config.LOCATION_MARKER[3], 255, false, false, 2, false, false, false, false)
                
                    -- Draw race name
                    Draw3DText(race.start.x, race.start.y, race.start.z-0.600, race.title, Config.RACING_HUD_COLOR, 4, 0.3, 0.3)
                    -- Draw "Whitelisted" text if race is whitelisted
                    if race.whitelist then
                        local text = ""
                        for _, vehicleName in pairs(race.whitelistVehicles) do
                            text = text .. vehicleName[1] .. " - "
                        end
                        text = text:sub(1, -4) -- remove trailing - and space
                        Draw3DText(race.start.x, race.start.y, race.start.z-1.500, "Whitelisted: " .. text, {0, 255, 0, 200}, 4, 0.08, 0.08)
                    end

                end

                -- When close enough, draw scores
                if GetDistanceBetweenCoords( race.start.x, race.start.y, race.start.z, GetEntityCoords(player)) < Config.DRAW_SCORES_DISTANCE then
                    -- If we've received updated scores, display them
                    if raceState.scores ~= nil then
                        -- Get scores for this race and sort them
                        raceScores = raceState.scores[race.title]
                        if raceScores ~= nil then
                            local sortedScores = {}
                            for k, v in pairs(raceScores) do
                                table.insert(sortedScores, { key = k, value = v })
                            end
                            table.sort(sortedScores, function(a,b) return a.value.time < b.value.time end)

                            -- Create new list with scores to draw
                            local vehicle = GetVehiclePedIsIn(player, false)
                            local cwinfo, cwclass, perfRating = getVehiclePerformanceInfo(vehicle)
                            local count = 0
                            drawScores = {}
                            for k, v in pairs(sortedScores) do
                                if v.value.rating == cwclass and count < Config.DRAW_SCORES_COUNT_MAX then
                                    count = count + 1
                                    table.insert(drawScores, v.value)
                                end
                            end


                            -- Initialize offset
                            local zOffset = 0
                            if (#drawScores > #Config.raceScoreColors) then
                                zOffset = 0.450*(#Config.raceScoreColors) + 0.300*(#drawScores - #Config.raceScoreColors - 1)
                            else
                                zOffset = 0.450*(#drawScores - 1)
                            end




                            -- DRAW SCORES -- CW-PERFORMANCE ADDITION
                            -- Print scores above title for matching class
                            for k, score in pairs(drawScores) do
                                -- Convert milliseconds to minutes:seconds format
                                -- Draw score text with color coding
                                    if (k > #Config.raceScoreColors) then
                                        -- Draw score in white, decrement offset
                                        Draw3DText(race.start.x, race.start.y, race.start.z+zOffset, string.format("%s %s %02d:%02d:%02d (%s)", score.rating, score.car, math.floor(score.time/60000), math.floor((score.time%60000)/1000), math.floor(score.time%1000), score.player), {255,255,255,255}, 4, 0.13, 0.13)
                                        zOffset = zOffset - 0.300
                                    else
                                        -- Draw score with color and larger text, decrement offset
                                        Draw3DText(race.start.x, race.start.y, race.start.z+zOffset, string.format("%s %s %02d:%02d:%02d (%s)", score.rating, score.car, math.floor(score.time/60000), math.floor((score.time%60000)/1000), math.floor(score.time%1000), score.player), Config.raceScoreColors[k], 4, 0.22, 0.22)
                                        zOffset = zOffset - 0.450
                                    end
                                --end
                            end
                            
                        end
                    end
                end
                
                -- When close enough, prompt player
                if GetDistanceBetweenCoords( race.start.x, race.start.y, race.start.z, GetEntityCoords(player)) < Config.START_PROMPT_DISTANCE then
                    helpMessage(Config.START_PROMPT)
                    if (IsControlJustReleased(1, 51)) then
                        if race.classList then
                            --cw-performance
                            local vehicle = GetVehiclePedIsIn(player, false)
                            local cwinfo, cwclass, perfRating = getVehiclePerformanceInfo(vehicle)
                            -- if class of car is allowed and no whitelist start the race
                            if race.allowedClasses[cwclass] and race.whitelist == false then
                                raceState.index = index
                                raceState.scores = nil
                                raceState.getTime = index
                                TriggerEvent("raceCountdown")
                            elseif race.allowedClasses[cwclass] == false then
                                NotifyNotAllowedClass(cwclass)
                            elseif race.allowedClasses[cwclass] and race.whitelist then
                                local pVeh = GetVehiclePedIsIn(player, false)
                                local pVehModel = GetEntityModel(pVeh)
                                local isWhitelisted = false

                                for _, whitelistedModel in pairs(race.whitelistVehicles) do
                                    if pVehModel == GetHashKey(whitelistedModel[1]) then
                                        isWhitelisted = true
                                    break
                                    end
                                end

                                if isWhitelisted then
                                    raceState.index = index
                                    raceState.scores = nil
                                    raceState.getTime = index
                                    TriggerEvent("raceCountdown")
                                elseif race.whitelistSpawn then
                                    -- Pick a random entry
                                    local randomIndex = math.random(1, #race.whitelistVehicles)
                                    local vehicleName = race.whitelistVehicles[randomIndex][1]
                                    SpawnMyVehicle(vehicleName)
                                    raceState.index = index
                                    raceState.scores = nil
                                    raceState.getTime = index
                                    TriggerEvent("raceCountdown")
                                else
                                    notify("Your vehicle is not whitelisted for this race!", "error")
                                end
                            end
                        elseif  race.classList ~= true then
                            if race.whitelist == false then
                                raceState.index = index
                                raceState.scores = nil
                                raceState.getTime = index
                                TriggerEvent("raceCountdown")
                            elseif race.whitelist then
                                local pVeh = GetVehiclePedIsIn(player, false)
                                local pVehModel = GetEntityModel(pVeh)
                                local isWhitelisted = false

                                for _, whitelistedModel in pairs(race.whitelistVehicles) do
                                    if pVehModel == GetHashKey(whitelistedModel[1]) then
                                        isWhitelisted = true
                                    break
                                    end
                                end

                                if isWhitelisted then
                                    raceState.index = index
                                    raceState.scores = nil
                                    raceState.getTime = index
                                    TriggerEvent("raceCountdown")
                                elseif race.whitelistSpawn then
                                    -- Pick a random entry
                                    local randomIndex = math.random(1, #race.whitelistVehicles)
                                    local vehicleName = race.whitelistVehicles[randomIndex][1]
                                    SpawnMyVehicle(vehicleName)
                                    raceState.index = index
                                    raceState.scores = nil
                                    raceState.getTime = index
                                    TriggerEvent("raceCountdown")
                                else
                                    notify("Your vehicle is not whitelisted for this race!", "error")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local spawnedVehicle = nil
local monitoring = false

-- Call this when you spawn the vehicle
function SpawnMyVehicle(modelName)
    local model = GetHashKey(modelName)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)

    exports["LegacyFuel"]:SetFuel(vehicle, 100)
    SetEntityAsMissionEntity(vehicle, true, true)

    spawnedVehicle = vehicle
    monitoring = true
end

-- Monitor exit and cleanup
CreateThread(function()
    while true do
        Wait(1000)

        if monitoring and spawnedVehicle and DoesEntityExist(spawnedVehicle) then
            local ped = PlayerPedId()
            if not IsPedInVehicle(ped, spawnedVehicle, false) then
                monitoring = false -- stop checking
                Wait(3000) -- wait to ensure they fully exited

                if DoesEntityExist(spawnedVehicle) then
                    DeleteEntity(spawnedVehicle)
                    spawnedVehicle = nil
                    print("Vehicle deleted after exit.")
                end
            end
        end
    end
end)

function NotifyNotAllowedClass(cwclass)
    local text = "Your car is class: " .. cwclass .. " which is not allowed for this race!"
    notify(text, "error")
end

-- Receive race scores from server and print
RegisterNetEvent("raceReceiveScores")
AddEventHandler("raceReceiveScores", function(scores)
    -- Save scores to state
    raceState.scores = scores
end)

-- Countdown race start with controls disabled
RegisterNetEvent("raceCountdown")
AddEventHandler("raceCountdown", function()
    -- Get race from index
    local race = races[raceState.index]
    
    -- Teleport player to start and set heading
    teleportToCoord(race.start.x, race.start.y, race.start.z + 2.0, race.start.heading)
    
    Citizen.CreateThread(function()
        -- Countdown timer
        local time = 0
        function setcountdown(x) time = GetGameTimer() + x*1000 end
        function getcountdown() return math.floor((time-GetGameTimer())/1000) end
        
        -- Count down to race start
        setcountdown(6)
        while getcountdown() > 0 do
            -- Update HUD
            Citizen.Wait(1)
            DrawHudText(getcountdown(), {255, 255, 255, 255},0.5,0.4,4.0,4.0)
            
            -- Disable acceleration/reverse until race starts
            DisableControlAction(2, 71, true)
            DisableControlAction(2, 72, true)
        end
        
        -- Enable acceleration/reverse once race starts
        EnableControlAction(2, 71, true)
        EnableControlAction(2, 72, true)
        
        -- Start race
        TriggerEvent("raceRaceActive")
    end)
end)

-- Main race function
RegisterNetEvent("raceRaceActive")
AddEventHandler("raceRaceActive", function()
    -- Get race from index
    local race = races[raceState.index]

    -- new CP type 44 using reserved parameter of CreateCheckpoint
    local markno = 2
    -- Start a new timer
    raceState.startTime = GetGameTimer()
    local countdownTime = Config.CountdownTime * 1000 -- initial countdown time
    local checkpointTime = GetGameTimer() + countdownTime
    Citizen.CreateThread(function()
        -- Create first checkpoint
        checkpoint = CreateCheckpoint(race.checkpoints[raceState.cP].type, race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z + Config.CHECKPOINT_Z_OFFSET, race.checkpoints[raceState.cP].x,race.checkpoints[raceState.cP].y, race.checkpoints[raceState.cP].z, race.checkpointRadius, Config.CP_COLOR[1], Config.CP_COLOR[2], Config.CP_COLOR[3], Config.CP_COLOR[4], 1)
        raceState.blip = AddBlipForCoord(race.checkpoints[raceState.cP].x, race.checkpoints[raceState.cP].y, race.checkpoints[raceState.cP].z)
        
        -- Set waypoints if enabled
        if race.showWaypoints == true then
            SetNewWaypoint(race.checkpoints[raceState.cP+1].x, race.checkpoints[raceState.cP+1].y)
        end
        
        -- While player is racing, do stuff
        while raceState.index ~= 0 do 
            Citizen.Wait(1)
            
            -- Stop race when L is pressed, clear and reset everything
            if IsControlJustReleased(0, Config.CancelBind) and GetLastInputMethod(0) then
                -- Delete checkpoint and raceState.blip
                DeleteCheckpoint(checkpoint)
                RemoveBlip(raceState.blip)
                -- Set new waypoint 
                SetNewWaypoint(race.start.x, race.start.y)
                if Config.cancelTP == true then
                    teleportToCoord(race.start.x, race.start.y, race.start.z + 4.0, race.start.heading)
                end
                

                -- Clear racing index and break
                raceState.index = 0
                break
            end

            -- Check if countdown time has expired
            if GetGameTimer() > checkpointTime then
                -- Break the script if countdown time has expired
                notify("You ran out of time", "error")
                DeleteCheckpoint(checkpoint)
                RemoveBlip(raceState.blip)
                
                -- Set new waypoint and teleport to the same spot 
                SetNewWaypoint(race.start.x, race.start.y)
                --teleportToCoord(race.start.x, race.start.y, race.start.z + 4.0, race.start.heading)
                
                -- Clear racing index and break
                raceState.index = 0
                break
            end
            -- Draw checkpoint and time HUD above minimap
            local checkpointDist = math.floor(GetDistanceBetweenCoords(race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z, GetEntityCoords(GetPlayerPed(-1))))
            -- Calculate total time in minutes and seconds
            local totalTimeSeconds = (GetGameTimer() - raceState.startTime) / 1000
            local minutes = math.floor(totalTimeSeconds / 60)
            local seconds = totalTimeSeconds % 60

            -- Draw time in minutes and seconds format
            DrawHudText(("%.0f:%02.0f"):format(minutes, seconds), Config.RACING_HUD_COLOR, 0.015, 0.225, 0.7, 0.7)
            -- Draw checkpoint information
            DrawHudText(string.format("Checkpoint %i / %i (%d m)", raceState.cP, #race.checkpoints, checkpointDist), Config.RACING_HUD_COLOR, 0.015, 0.265, 0.5, 0.5)
            -- Draw countdown timer
            local countdownSeconds = math.floor((checkpointTime - GetGameTimer()) / 1000)
            DrawHudText(string.format("Remaining: %02d:%02d", math.floor(countdownSeconds / 60), countdownSeconds % 60), Config.RACING_HUD_COLOR, 0.015, 0.305, 0.4, 0.4)
            
            
            -- Check distance from checkpoint
            if GetDistanceBetweenCoords(race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z, GetEntityCoords(GetPlayerPed(-1))) < race.checkpointRadius then
                -- Delete checkpoint and map raceState.blip, 
                DeleteCheckpoint(checkpoint)
                RemoveBlip(raceState.blip)
                
                -- Play checkpoint sound
                PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")
                
                -- Check if at finish line
                if raceState.cP == #(race.checkpoints) then
                    -- Save time and play sound for finish line
                    local finishTime = (GetGameTimer() - raceState.startTime)
                    PlaySoundFrontend(-1, "ScreenFlash", "WastedSounds")
                                        
                    -- Get vehicle name and create score
                    

                    local aheadVehHash = GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(-1)))
                    local aheadVehNameText = GetLabelText(GetDisplayNameFromVehicleModel(aheadVehHash))
                    local score = {}
                    local tPlayer = getPlayerData()

                    if tPlayer.charinfo == nil then
                        tPlayer.charinfo = {}
                        tPlayer.charinfo.firstname = "Unknown"
                        tPlayer.charinfo.lastname = "Unknown"
                        print("Still FUDGED")
                    end

                    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                    local cwinfo, cwclass, perfRating = getVehiclePerformanceInfo(vehicle)
                    score.player = tPlayer.charinfo.firstname .. " " .. tPlayer.charinfo.lastname
                    score.time = finishTime
                    score.car = aheadVehNameText
                    score.rating = cwclass
                    local playerID = GetPlayerServerId(PlayerId())
                    local message = string.format("Driver " .. score.player .. " finished " .. race.title .. " using " .. aheadVehNameText .. ". Class: ".. cwclass .. " - in " .. (finishTime / 1000) .. "!!")
                    TriggerServerEvent('racePlayerFinished', GetPlayerName(PlayerId()), message, race.title, score, playerID)
                    notify(message, "success")
                    raceState.index = 0
                    if race.spawnVeh == true then
                        --despawn vehicle so player can't get a free ride or clutter the server.
                        Citizen.Wait(5000)
                        DeleteVehicle(vehicle)
                    end
                    break
                end

                -- Increment checkpoint counter and create next checkpoint
                raceState.cP = math.ceil(raceState.cP+1)
                
                if race.checkpoints[raceState.cP].type == Config.cpBlip then
                    -- Create normal checkpoint
                    checkpoint = CreateCheckpoint(race.checkpoints[raceState.cP].type, race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z + Config.CHECKPOINT_Z_OFFSET, race.checkpoints[raceState.cP].x, race.checkpoints[raceState.cP].y, race.checkpoints[raceState.cP].z, race.checkpointRadius, Config.CP_COLOR[1], Config.CP_COLOR[2], Config.CP_COLOR[3], Config.CP_COLOR[4], markno)
                    raceState.blip = AddBlipForCoord(race.checkpoints[raceState.cP].x, race.checkpoints[raceState.cP].y, race.checkpoints[raceState.cP].z)
                    SetNewWaypoint(race.checkpoints[raceState.cP+1].x, race.checkpoints[raceState.cP+1].y)
                    markno = markno + 1
                elseif race.checkpoints[raceState.cP].type == Config.finishBlip then
                    -- Create finish line
                    checkpoint = CreateCheckpoint(race.checkpoints[raceState.cP].type, race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z + 4.0, race.checkpoints[raceState.cP].x, race.checkpoints[raceState.cP].y, race.checkpoints[raceState.cP].z, race.checkpointRadius, Config.CP_COLOR[1], Config.CP_COLOR[2], Config.CP_COLOR[3], Config.CP_COLOR[4], markno)
                    raceState.blip = AddBlipForCoord(race.checkpoints[raceState.cP].x, race.checkpoints[raceState.cP].y, race.checkpoints[raceState.cP].z)
                    SetNewWaypoint(race.checkpoints[raceState.cP].x, race.checkpoints[raceState.cP].y)
                end

                -- Tick countdown timer
                --DEBUG print(GetDistanceBetweenCoords(race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z, GetEntityCoords(GetPlayerPed(-1))) / 10)
                local distance = GetDistanceBetweenCoords(race.checkpoints[raceState.cP].x,  race.checkpoints[raceState.cP].y,  race.checkpoints[raceState.cP].z, GetEntityCoords(GetPlayerPed(-1)))
                checkpointTime = checkpointTime + distance * Config.timeoutMulti
            end
        end
                
        -- Reset race
        preRace()
    end)
end)

-- Create map blips for all enabled tracks
Citizen.CreateThread(function()
    for _, race in pairs(races) do
        if race.isEnabled then
            race.blip = AddBlipForCoord(race.start.x, race.start.y, race.start.z)
            SetBlipSprite(race.blip, race.mapBlipId)
            SetBlipDisplay(race.blip, 4)
            SetBlipScale(race.blip, 1.0)
            SetBlipColour(race.blip, race.mapBlipColor)
            SetBlipAsShortRange(race.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(race.title)
            EndTextCommandSetBlipName(race.blip)
        end
    end
end)

-- Utility function to teleport to coordinates
function teleportToCoord(x, y, z, heading)
    Citizen.Wait(1)
    local player = GetPlayerPed(-1)
    if IsPedInAnyVehicle(player, true) then
        SetEntityCoords(GetVehiclePedIsUsing(player), x, y, z)
        Citizen.Wait(100)
        SetEntityHeading(GetVehiclePedIsUsing(player), heading)
    else
        SetEntityCoords(player, x, y, z)
        Citizen.Wait(100)
        SetEntityHeading(player, heading)
    end
end

-- Utility function to display help message
function helpMessage(text, duration)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

-- Utility function to display 3D text
function Draw3DText(x,y,z,textInput,colour,fontId,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    local colourr,colourg,colourb,coloura = table.unpack(colour)
    SetTextColour(colourr,colourg,colourb, coloura)
    SetTextDropshadow(2, 1, 1, 1, 255)
    SetTextEdge(3, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- Utility function to display HUD text
function DrawHudText(text,colour,coordsx,coordsy,scalex,scaley)
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scalex, scaley)
    local colourr,colourg,colourb,coloura = table.unpack(colour)
    SetTextColour(colourr,colourg,colourb, coloura)
    SetTextDropshadow(0, 0, 0, 0, coloura)
    SetTextEdge(1, 0, 0, 0, coloura)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(coordsx,coordsy)
end



exports("GetRaceState", function()
    return raceState
end)

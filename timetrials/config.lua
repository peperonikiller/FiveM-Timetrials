-------------------
-- CONFIG --
-------------------
Config = {}

Config.START_PROMPT_DISTANCE = 10.0              -- distance to prompt to start race

Config.Debug = true                             -- Set to true to enable debug messages (console messages for timetrials completions and payouts)

--[[ ================INFO================= 

Some settings are located in tracks.lua
    This allows for track specific settings such as whitelisting classes, GPS blip coloring, checkpoint transparency, etc..

    

-- ================REWARDS=================
-- How much money will the player recieve upon completion. (Will update with math later) ]]
Config.Bonus = 2000 --Cash rewarded for setting the fastest time for your class
Config.Reward = 200 -- Reward for completing a timetrial.
-- A third reward is added and given for remaining time left.

-- ================ COLORING =================
Config.LOCATION_MARKER = {0, 244, 255}           -- color for location marker pylon {Red, Green, Blue} 
Config.RACING_HUD_COLOR = {194, 0, 20, 200}    -- color for racing HUD above map {Red, Green, Blue, Transparency}
Config.CP_COLOR = {255, 172, 0, 100}                 -- color for checkpoints {Red, Green, Blue, Transparency}



-- ================SCORING=================
Config.DRAW_SCORES_COUNT_MAX = 6                -- Maximum number of scores to draw above race title
Config.DRAW_TEXT_DISTANCE = 100.0                -- distance to start rendering the race name text
Config.DRAW_SCORES_DISTANCE = 25.0               -- Distance to start rendering the race scores


-- ================ CHECKPOINTS =================
-- Checkpoint Style https://docs.fivem.net/docs/game-references/checkpoints/
Config.cpBlip = 44 -- Do not change, this is now setup for CP 44 which uses an extra flag in the DrawMarker field to include the CP number your at.
Config.CHECKPOINT_Z_OFFSET = -1.00               -- Offset in Z axis if CP is above or below ground, negative is down, positive is up. 1 increment is about a characters arm length. No need to mess with
Config.finishBlip = 16
Config.CountdownTime = 30 -- initial countdown time before failure
Config.timeoutMulti = 35 -- multiplier for timeout counter. Lower this for less time added each CP. Default value tuned for Vanilla speeds.
-- Go by 5's to feel out a good timeout for your handling settings. You can change the initial countdown time to fine tune the timeout counter as well.


-- ================ FUEL =================
-- Define coordinates for adding fuel pumps (For LegacyFuel etc.)
-- 
Config.GasPumpLocations = {
    vector3(3640.43, -6555.53, 2188.5),
    vector3(3604.0, -6594.84, 2188.5),
    vector3(3575.13, -6624.31, 2188.5),
    vector3(3701.25, -6543.38, 2190)
} -- so far these add pumps to the Nurburgring resource.

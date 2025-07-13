--[[-----------------
-- CONFIG --
-- Updated July 12th 2025
-- Random urge to code. 

================INFO================= 

Some settings are located in tracks.lua    This allows for track specific settings such as whitelisting classes, GPS blip coloring, checkpoint transparency, etc..]]
   
Config = {}

Config.scoreFileName = "scores.json"
Config.scoreUpdateTime = 5 -- In seconds how often does the client recieve scores from the server. With a popular server you may have to increase this as scores populate.  Would recommend a leaderboard wipe if it does slow down, until I can build something in.

--==devtesting
Config.LastAwards = ""
--=============== GENERAL =================

Config.Framework = "auto" -- "auto, standalone" Only QB supported atm. Standalone should work just fine.
Config.START_PROMPT = "Press ~INPUT_CONTEXT~ to start the time trial!"
Config.CancelBind = 182 -- 182 = L key. See https://docs.fivem.net/docs/game-references/controls/#controls      Pressing L while in a timetrial will cancel it and set the waypoint back to the start. 
Config.cancelTP = true -- If true, when a player cancels a TimeTrial it will teleport them back to the start.
Config.START_PROMPT_DISTANCE = 10.0             -- distance to prompt to start race
Config.Debug = true                             -- Set to true to enable debug messages (console messages for timetrials completions and payouts)

-- ================REWARDS=================
-- How much money will the player recieve upon completion. (Will update with better math later)
Config.Bonus = 1000                 --Cash rewarded for setting the fastest time for your class, server economy will be wierd at first with so few records. Suggest raising this after a lot of records have been made.
Config.Reward = 10                 -- Reward multipler for completing a timetrial. 

-- ================ COLORING =================

Config.LOCATION_MARKER = {0, 244, 255}          -- color for location marker pylon {Red, Green, Blue} 
Config.RACING_HUD_COLOR = {255, 139, 15, 200}     -- color for racing HUD above map {Red, Green, Blue, Transparency}
Config.CP_COLOR = {0, 244, 255, 100}            -- color for checkpoints {Red, Green, Blue, Transparency}
Config.color_finish = {238, 198, 78}            -- color for printing score to chat
Config.color_highscore = {238, 78, 118}         -- color for printing high score to chat
Config.raceScoreColors = {                      -- Array of colors to display scores, top to bottom and scores out of range will be white
    {214, 175, 54, 255},  --First place color
    {167, 167, 173, 255}, --Second Place
    {167, 112, 68, 255}   --Third Place
}

-- ================SCORING=================

Config.DRAW_SCORES_COUNT_MAX = 6                -- Maximum number of scores to draw above race title
Config.DRAW_TEXT_DISTANCE = 75.0               -- distance to start rendering the race name text
Config.DRAW_SCORES_DISTANCE = 75.0              -- Distance to start rendering the race scores

-- ================ CHECKPOINTS =================
-- Checkpoint Style https://docs.fivem.net/docs/game-references/checkpoints/
Config.cpBlip = 44                 -- Do not change, this is now setup for CP 44 which uses an extra flag in the DrawMarker field to include the CP number your at.
Config.CHECKPOINT_Z_OFFSET = -1.00 -- Offset in Z axis if CP is above or below ground, negative is down, positive is up. 1 increment is about a characters arm length. No need to mess with, if just one track is off, fix in tracks.lua
Config.finishBlip = 16             -- Finish line checkpoint style, refer to fivem docs if you want to change the type for some reason.
Config.CountdownTime = 60          -- initial countdown time before failure
Config.timeoutMulti = 30           -- multiplier for timeout counter. Lower this for less time added each CP. Default value tuned for Vanilla speeds.
-- Go by 5's to feel out a good timeout for your handling settings. You can change the initial countdown time to fine tune the timeout counter as well.
-- programmatically after we hit a new CP this is the math for adding time every checkpoint... checkpointTime = current checkpointTime remaining + distance to next CP * Config.timeoutMulti

-- ================ FUEL =================
-- Define coordinates for adding fuel pumps (For LegacyFuel etc.)
-- so far these add pumps custom map additions.

Config.PumpDistance = 100  -- Distance until pumps are spawned. Helps with custom ymaps where the terrain is not loaded, especially if you use teleports. Still a WIP. 
Config.GasPumpLocations = {
    vector3(3640.43, -6555.53, 2188.5), --Nurburgring
    vector3(3604.0, -6594.84, 2188.5),	--Nurburgring
    vector3(3575.13, -6624.31, 2188.5),	--Nurburgring
    vector3(3701.25, -6543.38, 2190),	--Nurburgring
	vector3(911.37, -2347.59, 21.21) 	--Underground Car Meet Garage Resource
} 																			

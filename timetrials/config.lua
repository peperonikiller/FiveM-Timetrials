-------------------
-- CONFIG --
-------------------
Config = {}

Config.Framework = "esx"    --// esx or qb-core

-- How much money will the player recieve upon completion. (Will update with math later)
Config.Price = 2000


-- Checkpoint Style https://docs.fivem.net/docs/game-references/checkpoints/
Config.cpBlip = 14
Config.cpZoffset = "Not in use yet" -- Z axis offset if CP is above or below ground
Config.finishBlip = 16
Config.finishoffset = "Not in use yet" -- Z axis offset if CP is above or below ground

Config.CountdownTime = 30 -- initial countdown time before failure

Config.timeoutMulti = 35 -- multiplier for timeout counter. Lower this for less time added each CP. Default value tuned for Vanilla speeds.
-- Go by 5's to feel out a good timeout for your handling settings. You can change the initial countdown time to fine tune the timeout counter as well.

-- Define coordinates for adding fuel pumps (For LegacyFuel etc.)
Config.GasPumpLocations = {
    vector3(3640.43, -6555.53, 2188.5),
    vector3(3604.0, -6594.84, 2188.5),
    vector3(3575.13, -6624.31, 2188.5),
    vector3(3701.25, -6543.38, 2190)
} -- so far these add pumps the the Nurburgring resource.

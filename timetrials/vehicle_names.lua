--===============================================================================
-- Vehicle Names
-- If you get NULL for the vehicle name on a custom vehicle model, add the following line to the vehicle_names.lua file:
--===============================================================================
-- AddTextEntry("1", "2")
-- 1.  This is the vehicle name located in the vehicles.meta file. Look for the <gameName> tag.
-- 2.  This is the vehicle name shown in the game.

Citizen.CreateThread(function()
    AddTextEntry("KCM", "2015 Viper GTS")
    AddTextEntry("mazrx7fb", "1985 Mazda RX-7")
    AddTextEntry("Mirage", "Bordeaux SP3 Mirage (LMP3)")
    AddTextEntry("ST185R", "Toyota Celica ST185 4WD")
    AddTextEntry("Pr911_992", "2021 Pfister 911 Turbo S 992")
    AddTextEntry("JIRO", "Entara Jiro (LMP2)")
    AddTextEntry("aa_pr911_992_21", "2021 Pfister 911 Turbo S 992")
    
end)
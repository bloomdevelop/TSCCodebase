plr = game:GetService("Players"):GetPlayerFromCharacter(script.Parent)
char = plr.Character
hum = char:FindFirstChildOfClass("Humanoid")
local newhelth = 300 -- you can change this btw if you wanna
hum.MaxHealth = newhelth
hum.Health = newhelth
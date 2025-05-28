script.Parent.Parent.Enabled = true

local stg = game:GetService("StarterGui")
local ss = game:GetService("SoundService")

local plr = game.Players.LocalPlayer

local menuFrame = script.Parent

for i,module in pairs(script:GetChildren()) do
	require(module)
end
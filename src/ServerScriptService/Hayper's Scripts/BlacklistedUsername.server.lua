-- Requested by Scarlett~
local Players = game:GetService("Players")

local banList = {
	"GlennSteward",
	"Wanwood",
	"MaxDuncan",
	"JackDuncan",
	"JackStewart",
	"GabrielSanchez",
	"TimothyDavenport",
	"MathewWong",
	"TimothyWilkerson",
	"ElizabethAcevedo",
	"JesusColeman",
}

Players.PlayerAdded:Connect(function(plr)
	for _, name in ipairs(banList) do
		if string.lower(name) ~= string.lower(plr.Name) then continue end
		plr:Kick(":: Adonis :: Banned Username")
	end
end)
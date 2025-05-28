local char = script.Parent

local Latexs = {
	"WhiteLatex",
	"DarkLatex",
	"DarkDragon",
	"SnowLeopard",
	"ConeLizard"
}

local Player = game:GetService("Players"):GetPlayerFromCharacter(char)
if (Player) then
	_G.InfectPlayer(Player, 300, Latexs[math.random(1, #Latexs)], false, Color3.new(255,255,255))
end

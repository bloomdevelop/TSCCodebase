local ServerScriptService = game:GetService("ServerScriptService")

local HaypersScript = ServerScriptService:WaitForChild("Hayper's Scripts")

return function(playerWhoHug: Player)
	HaypersScript["Handler"]["SadCISHandler"]["OnHug"]:Fire(playerWhoHug)
end
local ServerScriptService = game:GetService("ServerScriptService")

local HaypersScript = ServerScriptService:WaitForChild("Hayper's Scripts")

return function(playerWhoShot: Player)
	HaypersScript["Handler"]["SadCISHandler"]["OnGunHit"]:Fire(playerWhoShot)
end
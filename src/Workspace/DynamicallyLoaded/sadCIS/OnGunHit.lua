local ServerScriptService = game:GetService("ServerScriptService")

local HaypersScript = ServerScriptService:WaitForChild("Hayper's Scripts")

return function(playerWhoShot: Player, gunData: {[any]: any}, damage: number)
	HaypersScript["Handler"]["SadCISHandler"]["OnGunHit"]:Fire(playerWhoShot, gunData, damage)
end
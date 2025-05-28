Typing = require(script.Parent.Typing)

return function(Framework: Typing.FrameworkType)
	-- INITILAIZATION
	local PlayerHandler = {
		
	}

	-- PUBLIC FUNCTIONS
	
	function PlayerHandler.RemoveCoreRobloxCharcaterScripts(Character: Model)
		local Animate = Character:FindFirstChild("Animate") or Character:WaitForChild("Animate")
		if (Animate) then
			Animate:Destroy()
		end
		
		local Health = Character:FindFirstChild("Health") or Character:WaitForChild("Health")
		if (Health) then
			Health:Destroy()
		end
		
		Framework.Logger.debug('[ PLAYERHANDLER / DEBUG ]', 'player '..Character.Name.." core scripts removed and registered.")
	end
	
	function PlayerHandler.HealthRegen(Humanoid: Humanoid): nil
		if Humanoid.Health < Humanoid.MaxHealth and Humanoid.Health > 0 then
			Humanoid.Health = math.min(Humanoid.Health + 1, Humanoid.MaxHealth)
		end
	end
	
	-- FINALIZE
	
	Framework.Services.Players.PlayerAdded:connect(function(Player)
		Player.CharacterAdded:Connect(PlayerHandler.RemoveCoreRobloxCharcaterScripts)
	end)
	
	for _,Player in pairs(Framework.Services.Players:GetPlayers()) do
		local Char = Player.Character
		if (Char) then
			PlayerHandler.RemoveCoreRobloxCharcaterScripts(Char)
		end
		Player.CharacterAdded:Connect(PlayerHandler.RemoveCoreRobloxCharcaterScripts)
	end
	
	task.spawn(function()
		while task.wait(1) do
			for _,Player in pairs(Framework.Services.Players:GetPlayers()) do
				task.spawn(function()
					local Char = Player.Character
					if (Char) then
						local Humanoid = Char:FindFirstChildOfClass("Humanoid") or Char:WaitForChild("Humanoid")
						if (Humanoid) then
							PlayerHandler.HealthRegen(Humanoid)
						end
					end
				end)
			end
		end
	end)
	
	Framework.Logger.debug('[ PLAYERHANDLER / DEBUG ]', 'Initialized animator, watching over player.')

	return PlayerHandler
end
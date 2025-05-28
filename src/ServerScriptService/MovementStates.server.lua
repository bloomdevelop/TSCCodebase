-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")

local remotesFolder = rst.Remotes

remotesFolder.Movement.RegisterMovementState.OnServerEvent:Connect(function(plr : Player, pos)
	if pos == "sprint" then
		plr:SetAttribute('State', 'Running')
	elseif pos == "crouch" then
		plr:SetAttribute('State', 'Crouching')
	elseif pos == "crawl" then
		plr:SetAttribute('State', 'Crawling')
	else
		plr:SetAttribute('State', 'None')
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	plr:SetAttribute('State', 'None')
	
	plr.CharacterAdded:Connect(function()
		plr:SetAttribute('State', 'None')
	end)
end)

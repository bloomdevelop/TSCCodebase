local Players = game:GetService("Players")

local tool = script.Parent

local storage = tool.Stored

local plr = nil
local taking = false

local diedConnection

local function destroyTools()
	for i,pointer in pairs(storage:GetChildren()) do
		local tool = pointer.Value
		if not tool then continue end
		tool:Destroy()
	end
end

tool.Equipped:Connect(function()
	local char = tool.Parent
	
	plr = Players:GetPlayerFromCharacter(tool.Parent)
	
	if diedConnection then diedConnection:Disconnect() end
	diedConnection = char:WaitForChild("Humanoid").Died:Connect(destroyTools)
end)

tool.Take.OnServerEvent:Connect(function(requestPlr)
	if requestPlr == plr and taking == false then
		taking = true
		
		for i,pointer in pairs(storage:GetChildren()) do
			local tool = pointer.Value
			if not tool then continue end
			tool.Parent = plr.Backpack
		end
		
		tool:Destroy()
	end
end)

tool.Delete.OnServerEvent:Connect(function(requestPlr)
	if requestPlr == plr then
		destroyTools()
		
		if plr.Team.Name == "Utility & Maintenance" then
			local cash = plr.leaderstats.Cash
			cash.Value = cash.Value + 200
		end
		
		tool:Destroy()
	end
end)

Players.PlayerRemoving:Connect(function(plrLeaving)
	if plrLeaving == plr then
		destroyTools()
	end
end)
local PS = game:GetService("Players")
local WS = game:GetService("Workspace")
local PhyS = game:GetService("PhysicsService")

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local remotesFolder = RS:WaitForChild("Remotes")
local bindablesFolder = SS:WaitForChild("Bindables")

local remote = remotesFolder:WaitForChild("Cuffs"):WaitForChild("CuffRemote")

local diableScript = script["1"]

local connections = {}

local function moveChar(plr,targetPlr)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {plr.Character,targetPlr.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	while targetPlr and targetPlr:GetAttribute('cuffed') == true do
		targetPlr.Character.Humanoid:UnequipTools()
		targetPlr.Character.Humanoid.PlatformStand = true
		local rayResult = WS:Raycast(plr.Character.HumanoidRootPart.Position,plr.Character.HumanoidRootPart.CFrame.LookVector * 5,params)
		if rayResult then
			bindablesFolder.Anticheat.AuthorizeTeleport:Fire(targetPlr, CFrame.new(rayResult.Position.X-0.5,rayResult.Position.Y,rayResult.Position.Z))
		else
			bindablesFolder.Anticheat.AuthorizeTeleport:Fire(targetPlr, plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-5))
		end
		task.wait()
	end
end

local function disableInv(targetPlr,action)
	local c = diableScript:Clone()
	if action == 2 then
		c.Name = "2"
	end
	if targetPlr:FindFirstChild("PlayerGui") then
		c.Parent = targetPlr.PlayerGui
		c.Disabled = false
		wait(5)
	end
	c:Destroy()
end

local function discconectFunc(plr,targetPlr,tool)
	if tool then
		tool:SetAttribute("target",false)
	end
	if targetPlr then
		targetPlr:SetAttribute("cuffed",false)
		local c = coroutine.wrap(disableInv)
		c(targetPlr,2)
	end
	if targetPlr.Character then
		for _,v in pairs(targetPlr.Character:GetChildren()) do
			if v:IsA("BasePart") then
				PhyS:SetPartCollisionGroup(v,"Players")
			end
		end
		targetPlr.Character.Humanoid.PlatformStand = false
		targetPlr.Character.HumanoidRootPart.Anchored = false
	end

	if connections[plr] and connections[plr][1] and connections[plr][1].Connected == true then
		connections[plr][1]:Disconnect()
	end
	if connections[plr] and connections[plr][2] and connections[plr][2].Connected == true then
		connections[plr][2]:Disconnect()
	end
	if connections[targetPlr] and connections[targetPlr][1] and connections[targetPlr][1].Connected == true then
		connections[targetPlr][1]:Disconnect()
	end
	if connections[targetPlr] and connections[targetPlr][2] and connections[targetPlr][2].Connected == true then
		connections[targetPlr][2]:Disconnect()
	end

	connections[plr] = nil
	connections[targetPlr] = nil
end

local f = {
	[1] = function(plr,tool,target)

		if tool:GetAttribute("target") == true then return end
		if target == nil then return end
		local targetPlr = nil

		--------------------------------------------------

		for _,v in pairs(PS:GetPlayers()) do

			if v and v.Character and target and target:IsDescendantOf(v.Character) then

				if (target.Position - plr.Character.HumanoidRootPart.Position).Magnitude > 10 then break end
				if v:GetAttribute("cuffed") == true then break end
				if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health ~= 0 and v.Character:FindFirstChild("HumanoidRootPart") then
					targetPlr = v
				end

				break
			end
		end

		--------------------------------------------------

		if targetPlr then
			if targetPlr:GetAttributes()["cuffed"] == nil then
				targetPlr:SetAttribute("cuffed",false)
			end
			if targetPlr:GetAttribute("cuffed") == true then return end

			--------------------------------------------------

			tool:SetAttribute("target",true)
			targetPlr:SetAttribute("cuffed",true)
			targetPlr.Character.Humanoid.PlatformStand = true
			targetPlr.Character.HumanoidRootPart.Anchored = true

			for _,v in pairs(targetPlr.Character:GetChildren()) do
				if v:IsA("BasePart") then
					PhyS:SetPartCollisionGroup(v,"Cuff")
				end
			end

			--------------------------------------------------

			local c1 = plr.Character.Humanoid.Died:Connect(function()
				discconectFunc(plr,targetPlr,tool)
			end)
			local c2 = plr.CharacterRemoving:Connect(function()
				discconectFunc(plr,targetPlr,tool)
			end)
			local c3 = targetPlr.Character.Humanoid.Died:Connect(function()
				discconectFunc(plr,targetPlr,tool)
			end)
			local c4 = targetPlr.CharacterRemoving:Connect(function()
				discconectFunc(plr,targetPlr,tool)
			end)
			connections[plr] = {c1,c2,targetPlr,tool}
			connections[targetPlr] = {c3,c4,plr,tool}

			--------------------------------------------------

			local c = coroutine.wrap(moveChar)
			c(plr,targetPlr)

			local c = coroutine.wrap(disableInv)
			c(targetPlr)

			wait(1)
		else
			wait(0.5)
		end
	end,
	[2] = function(plr,tool)
		if not connections[plr] or tool:GetAttribute("target") == false then return end
		local targetPlr = connections[plr][3]
		discconectFunc(plr,targetPlr,tool)
		wait(0.5)
	end,
	[3] = function(plr,tool)
		if not connections[plr] or tool:GetAttribute("target") == false then return end
		local targetPlr = connections[plr][3]
		wait(0.5)
	end,
}

remote.OnServerEvent:Connect(function(plr,tool,action,target)
	if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health ~= 0 and plr.Character:FindFirstChild("HumanoidRootPart") then else return end
	if not typeof(tool) == "Instance" then return end
	if not plr.Character:FindFirstChild("Cuffs") then return end
	if not typeof(action) == "number" then return end
	if action < 1 or action > 3 then return end
	if not typeof(target) == "Instance" then return end

	--------------------------------------------------

	if tool:GetAttribute("db") == false then
		tool:SetAttribute("db",true)

		--------------------------------------------------

		f[action](plr,tool,target)

		--------------------------------------------------

		tool:SetAttribute("db",false)
	end
end)

PS.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		wait()
		for _,v in pairs(char:GetChildren()) do
			if v:IsA("BasePart") then
				PhyS:SetPartCollisionGroup(v,"Players")
			end
		end
	end)
end)

PS.PlayerRemoving:Connect(function(LeavingPlr)
	if connections[LeavingPlr] and LeavingPlr:GetAttribute("cuffed") == true then
		discconectFunc(connections[LeavingPlr][3],LeavingPlr,connections[LeavingPlr][4])
	elseif connections[LeavingPlr] then
		discconectFunc(LeavingPlr,connections[LeavingPlr][3],connections[LeavingPlr][4])
	end
end)
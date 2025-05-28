-- // Steven_Scripts, 2022
-- // Edited by DevKrazes, 2022

local rst = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")
local physic = game:GetService("PhysicsService")
local debris = game:GetService("Debris")

local modulesFolder = rst.Modules
local remotesFolder = rst.Remotes

local ventTools = require(modulesFolder.VentTools)

local plrVentInteractions = {}

local ventInteractable = {}
ventInteractable.__index = ventInteractable

local ventInteractableList = {}

function ventInteractable.new(model)
	local self = setmetatable({}, ventInteractable)

	local primaryPart = model.PrimaryPart

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Open"
	proximityPrompt.ObjectText = model.Name
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

	local difficulty = model:GetAttribute("Difficulty")
	if difficulty == nil then
		difficulty = 1
		model:SetAttribute("Difficulty", difficulty)
	end

	local timeMultiplier = model:GetAttribute("TimeMultiplier")
	if timeMultiplier == nil then
		timeMultiplier = 1
		model:SetAttribute("TimeMultiplier", timeMultiplier)
	end

	local stayOpenTime = model:GetAttribute("StayOpenTime")
	if stayOpenTime == nil then
		stayOpenTime = 15
		model:SetAttribute("StayOpenTime", stayOpenTime)
	end

	local parts = {}
	local originalPartTransparencies = {}
	for i,part in pairs(model:GetChildren()) do
		if part:IsA("BasePart") then
			originalPartTransparencies[part] = part.Transparency
			table.insert(parts, part)
		end
	end

	local minimumOpenTime = 1 / ((.2*0.9)/difficulty) * timeMultiplier

	---- Finishing
	proximityPrompt.Parent = model

	self.Prompt = proximityPrompt
	self.MinimumOpenTime = minimumOpenTime
	self.Model = model
	self.Parts = parts
	self.OriginalPartTransparencies = originalPartTransparencies
	self.Opened = false

	ventInteractableList[model] = self

	return self
end

function ventInteractable:Open(plr)
	self.Opened = true
	self.Model.PrimaryPart.Open:Play()

	if self.Model.PrimaryPart then
		local fakeVent = self.Model:Clone()
		local primaryPart = fakeVent.PrimaryPart

		cs:RemoveTag(fakeVent,"VentInteractable")

		for i,v in pairs(fakeVent:GetAttributes()) do
			fakeVent:SetAttribute(i,nil)	
		end

		for i,v in pairs(fakeVent:GetDescendants()) do
			if v:IsA("Sound") then
				v:Destroy()
			elseif v:IsA("BasePart") then
				if v ~= primaryPart then
					local weld = Instance.new("Weld")
					weld.Part1 = primaryPart
					weld.Part0 = v
					weld.C1 = primaryPart.CFrame:Inverse()
					weld.C0 = v.CFrame:Inverse()
					weld.Parent = v
				end
			end
		end
		
		for i,v in pairs(fakeVent:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
				physic:SetPartCollisionGroup(v, "OnlyDefault")
			end
		end
		
		fakeVent.Archivable = false
		fakeVent.Parent = workspace

		if primaryPart and plr.Character then
			local FlingSound = script.Fling:Clone()
			FlingSound.Parent = primaryPart
			FlingSound:Play()
			debris:AddItem(FlingSound,FlingSound.TimeLength/FlingSound.PlaybackSpeed)
			
			if plr.Character:FindFirstChild("HumanoidRootPart") then
				local fling = Instance.new("BodyVelocity")
				fling.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				fling.Velocity = plr.Character.HumanoidRootPart.CFrame.LookVector*50
				fling.Parent = primaryPart
				debris:AddItem(fling,0.03)
			end
		end

		debris:AddItem(fakeVent,self.Model:GetAttribute("StayOpenTime"))
	end

	for i,part in pairs(self.Parts) do
		part.Transparency = 1
		part.CanCollide = false
		for i,v in pairs(part:GetChildren()) do
			if v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("SurfaceGui") then
				v.Enabled = false
			end
		end
	end
end

function ventInteractable:Close()
	self.Opened = false
	for i,part in pairs(self.Parts) do
		part.Transparency = self.OriginalPartTransparencies[part]
		part.CanCollide = true
		for i,v in pairs(part:GetChildren()) do
			if v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 0
			elseif v:IsA("SurfaceGui") then
				v.Enabled = true
			end
		end
	end
end

local function hasTool(plr, toolName)
	local char = plr.Character
	if char then
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			if tool.Name == toolName then
				return true
			end
		end
	end

	if plr.Backpack:FindFirstChild(toolName) then
		return true
	end

	return false
end

local function getModifiers(plr)
	local highestPriority = 0
	local selectedToolName, selectedInfo
	for toolName, info in pairs(ventTools) do
		if hasTool(plr, toolName) then
			if info.Priority > highestPriority then
				selectedToolName = toolName
				selectedInfo = info
			end
		end
	end
	if selectedToolName then
		return selectedToolName, selectedInfo
	end

	-- Has no vent tool
	return "None", {
		SpeedMultiplier = 1,
		DecayMultiplier = 1,
		AreaMoveSpeedMultiplier = 1,
		FailPenalty = -0.1,
		FailCooldown = 3,
	}
end

local function stopVentInteraction(userid)
	plrVentInteractions[userid] = {
		Vent = nil,
		Timestamp = os.clock()
	}
end

local function ventInteractionRequest(plr, vent)
	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if vent == nil then
		stopVentInteraction(plr.UserId)
	else		
		local primaryPart = vent.PrimaryPart

		local distance = (primaryPart.Position - root.Position).Magnitude
		if distance < 15 then
			plrVentInteractions[plr.UserId] = {
				Vent = vent,
				Timestamp = os.clock()
			}
		end
	end
end

local function ventOpenRequest(plr, vent)
	local ventInteractable = ventInteractableList[vent]
	if ventInteractable then
		if ventInteractable.Opened == false then
			local lastVentInteraction = plrVentInteractions[plr.UserId]
			if lastVentInteraction.Vent == vent then
				local openTime = os.clock() - lastVentInteraction.Timestamp

				local toolName, modifiers = getModifiers(plr)

				local minimumOpenTime = ventInteractable.MinimumOpenTime/modifiers.SpeedMultiplier

				if openTime > minimumOpenTime-5 then
					-- Up to 5 seconds of inaccuracy will be forgiven.
					-- Sure, that's a lot, but this game also lags a lot.

					ventInteractable.Prompt.MaxActivationDistance = 0

					for userid,interaction in pairs(plrVentInteractions) do
						if interaction.Vent == vent then
							stopVentInteraction(userid)
							local interactplr = game.Players:GetPlayerByUserId(userid)
							remotesFolder.Vents.Interaction:FireClient(interactplr, nil)
						end
					end

					ventInteractable:Open(plr)
					task.wait(ventInteractable.Model:GetAttribute("StayOpenTime"))
					ventInteractable:Close()

					ventInteractable.Prompt.MaxActivationDistance = 10
				end
			end
		end
	end
end

local function ventFailRequest(plr, vent)
	local ventInteractable = ventInteractableList[vent]
	if ventInteractable then
		if ventInteractable.Opened == false then
			local lastVentInteraction = plrVentInteractions[plr.UserId]
			if lastVentInteraction.Vent == vent then
				-- Yea, we can fail.
				ventInteractable.Model.PrimaryPart.Fail:Play()
			else
				-- Player is not interacting with this vent.
				plr:Kick()
			end
		end
	end
end

local function playerAdded(plr)
	plrVentInteractions[plr.UserId] = {
		Vent = nil,
		Timestamp = os.clock(),
	}
end

local function playerRemoving(plr)
	plrVentInteractions[plr.UserId] = nil
end

---- Finishing
local vents = cs:GetTagged("VentInteractable")
for i,vent in pairs(vents) do
	ventInteractable.new(vent)
end

cs:GetInstanceAddedSignal("VentInteractable"):Connect(function(vent)
	ventInteractable.new(vent)
end)

game.Players.PlayerAdded:Connect(playerAdded)
game.Players.PlayerRemoving:Connect(playerRemoving)

remotesFolder.Vents.Interaction.OnServerEvent:Connect(ventInteractionRequest)
remotesFolder.Vents.Open.OnServerEvent:Connect(ventOpenRequest)
remotesFolder.Vents.Fail.OnServerEvent:Connect(ventFailRequest)
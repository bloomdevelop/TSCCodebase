-- // Steven_Scripts, 2022

local cs = game:GetService("CollectionService")
local sst = game:GetService("ServerStorage")
local rst = game:GetService("ReplicatedStorage")

local remotesFolder = rst.Remotes
local questDir = rst.Quests

local deadDropLocationsFolder = workspace.DeadDropLocations

local deadDropNPCs = cs:GetTagged("DeadDropNPC")

local riskPayoutMultipliers = {
	0.5, -- None
	1, -- Low
	1.5, -- Medium
	2, -- High
	3 -- Lethal
}

local basePayouts = {
	0, -- None
	100, -- Low
	200, -- Medium
	500, -- High
	2000 -- Lethal
}

local maximumQuestsAvailable = 8

local rng = Random.new()

local lowPlayerCount = 20
local highPlayerCount = 50

local function addQuest(npcName, locationName)
	local locationPart = deadDropLocationsFolder[locationName]

	local npc
	for i,checkingNPC in pairs(deadDropNPCs) do
		if checkingNPC.Name == npcName then
			npc = checkingNPC
			break
		end
	end

	local folder = Instance.new("Folder")
	folder.Name = locationName

	local root = npc.PrimaryPart

	local distance = (root.Position - locationPart.Position).Magnitude
	local risk

	local alignment = npc:GetAttribute("Alignment")
	if alignment == "Staff" then
		risk = locationPart.StaffRisk.Value
	elseif alignment == "TS" then
		risk = locationPart.TSRisk.Value
	end

	local payout = distance * 0.25
	payout = payout*riskPayoutMultipliers[risk]
	payout = math.ceil(payout/10)*10 + basePayouts[risk]

	local distanceVal = Instance.new("NumberValue")
	local riskVal = Instance.new("IntValue")
	local payoutVal = Instance.new("IntValue")
	local currentPlr = Instance.new("ObjectValue")

	distanceVal.Name = "Distance"
	riskVal.Name = "Risk"
	payoutVal.Name = "Payout"
	currentPlr.Name = "CurrentPlayer"

	distanceVal.Value = distance
	riskVal.Value = risk
	payoutVal.Value = payout

	distanceVal.Parent = folder
	riskVal.Parent = folder
	payoutVal.Parent = folder
	currentPlr.Parent = folder

	folder.Parent = questDir.DeadDrops[npcName]
end

local function addRandomQuest(npcName)
	local npc
	for i,checkingNPC in pairs(deadDropNPCs) do
		if checkingNPC.Name == npcName then
			npc = checkingNPC
			break
		end
	end

	local alignment = npc:GetAttribute("Alignment")

	local unavailableQuests = {}
	for i,locationPart in pairs(deadDropLocationsFolder:GetChildren()) do
		-- If one of these things doesn't match up, then it isn't a valid dead drop location for this team alignment
		if (alignment == "TS" and locationPart:FindFirstChild("TSRisk") ~= nil) or (alignment == "Staff" and locationPart:FindFirstChild("StaffRisk") ~= nil) then
			table.insert(unavailableQuests, locationPart.Name)
		end
	end

	local availableQuests = questDir.DeadDrops[npcName]:GetChildren()
	for _,questEntry in pairs(availableQuests) do
		local index = table.find(unavailableQuests, questEntry.Name)
		table.remove(unavailableQuests, index)
	end

	local selectedIndex = rng:NextInteger(1, #unavailableQuests)

	addQuest(npcName, unavailableQuests[selectedIndex])
end

local function stopQuest(plr)
	local currentQuest = plr.CurrentQuest

	currentQuest.Value.CurrentPlayer.Value = nil
	currentQuest:Destroy()

	-- Get rid of old tool
	local tool = plr.Backpack:FindFirstChild("Package")
	if tool == nil then
		tool = plr.Character:FindFirstChild("Package")
	end

	if tool ~= nil then
		tool:Destroy()
	end
end

local function onAcceptQuestRequest(plr : Player, questEntry : Folder)
	if questEntry == nil then return false end
	if questEntry.Parent.Parent ~= questDir.DeadDrops then return false end
	if questEntry.CurrentPlayer.Value ~= nil then return false end

	local npcName = questEntry.Parent.Name
	local npc
	for i,checkingNPC in pairs(deadDropNPCs) do
		if checkingNPC.Name == npcName then
			npc = checkingNPC
			break
		end
	end

	local char = plr.Character
	if not char then return false end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health == 0 then return false end
	local distance = (root.Position - npc.PrimaryPart.Position).Magnitude
	if distance > 15 then return false end

	local currentQuest = plr:FindFirstChild("CurrentQuest")
	if currentQuest ~= nil then
		stopQuest(plr)
	end

	-- Start quest
	currentQuest = Instance.new("ObjectValue")
	currentQuest.Name = "CurrentQuest"

	currentQuest.Value = questEntry

	questEntry.CurrentPlayer.Value = plr
	currentQuest.Parent = plr

	-- Give new tool
	local tool = sst.Tools.Package:Clone()
	tool.Quest.Value = questEntry
	tool.ToolTip = "Package for "..questEntry.Name
	tool.Parent = plr.Backpack

	return true
end

local function onFinishQuestRequest(plr : Player)
	local currentQuest = plr:FindFirstChild("CurrentQuest")
	if currentQuest == nil then return false end

	local char = plr.Character
	if not char then return false end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	local questEntry = currentQuest.Value
	local locationPart = deadDropLocationsFolder[questEntry.Name]

	local distance = (root.Position - locationPart.Position).Magnitude
	if distance < 15 then
		-- Finish quest
		stopQuest(plr)

		local cash = plr.leaderstats.Cash
		
		local payout = questEntry.Payout.Value
		
		local playerCount = #game.Players:GetPlayers()

		local lowPlayerCountPenalty = math.min(playerCount/lowPlayerCount, 1)
		local highPlayerCountBonus = math.max(playerCount/50, 1)
		
		cash.Value = cash.Value + math.ceil(payout*lowPlayerCountPenalty*highPlayerCountBonus)

		addRandomQuest(questEntry.Parent.Name)
		questEntry:Destroy()

		return true
	else
		return false
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			if plr:FindFirstChild("CurrentQuest") then
				stopQuest(plr)
			end
		end)
	end)
end)

game.Players.PlayerRemoving:Connect(function(plr)
	if plr:FindFirstChild("CurrentQuest") then
		stopQuest(plr)
	end
end)

---- Initializing
for i,npc in pairs(deadDropNPCs) do
	local questFolder = Instance.new("Folder")
	questFolder.Name = npc.Name
	questFolder.Parent = questDir.DeadDrops

	for i=1, maximumQuestsAvailable do
		addRandomQuest(npc.Name)
	end
end

for i,locationPart in pairs(deadDropLocationsFolder:GetChildren()) do
	locationPart.Transparency = 1
end

remotesFolder.DeadDrops.AcceptQuest.OnServerInvoke = onAcceptQuestRequest
remotesFolder.DeadDrops.FinishQuest.OnServerInvoke = onFinishQuestRequest
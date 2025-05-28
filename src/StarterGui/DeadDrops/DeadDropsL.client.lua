-- // Steven_Scripts, 2022

local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")

local assetsFolder = rst.Assets
local questsDir = rst.Quests
local remotesFolder = rst.Remotes

local deadDropLocationsFolder = workspace.DeadDropLocations

local ui = script.Parent
local main = ui.Main

local plr = game.Players.LocalPlayer

local questFrames = {}

local highestExpectedDistance = 1500

local lowPlayerCount = 20
local highPlayerCount = 50

local riskLevelNames = {
	"NONE",
	"LOW",
	"MODERATE",
	"HIGH",
	"LETHAL"
}

local riskLevelColors = {
	Color3.new(0, 0.65098, 1),
	Color3.new(0, 1, 0),
	Color3.new(1, 1, 0),
	Color3.new(1, 0, 0),
	Color3.new(0.615686, 0, 1),
}

local currentNPC = nil

local finishQuestPrompt = Instance.new("ProximityPrompt")
finishQuestPrompt.ObjectText = "Dead Drop Location"
finishQuestPrompt.ActionText = "Finish quest"
finishQuestPrompt.RequiresLineOfSight = false
finishQuestPrompt.MaxActivationDistance = 15
finishQuestPrompt.Style = Enum.ProximityPromptStyle.Custom

local updateQuestList
local selectNPC

local function addQuestUI(questEntry)
	local payout = questEntry:WaitForChild("Payout").Value
	local risk = questEntry:WaitForChild("Risk").Value
	local distance = questEntry:WaitForChild("Distance").Value
	
	local frame = assetsFolder.UI.DeadDropQuest:Clone()
	frame.Location.Text = questEntry.Name
	
	local playerCount = #game.Players:GetPlayers()

	local lowPlayerCountPenalty = math.min(playerCount/lowPlayerCount, 1)
	local highPlayerCountBonus = math.max(playerCount/50, 1)
	
	if lowPlayerCountPenalty < 1 then
		frame.Details.Payout.Text = "PAYOUT: <s>"..payout.."</s> <font color='rgb(255,0,0)'>"..math.ceil(payout*lowPlayerCountPenalty).." CREDITS</font>"
	elseif highPlayerCountBonus > 1 then
		frame.Details.Payout.Text = "PAYOUT: <s>"..payout.."</s> <font color='rgb(0,255,0)'>"..math.ceil(payout*highPlayerCountBonus).." CREDITS</font>"
	else
		frame.Details.Payout.Text = "PAYOUT: "..payout.." CREDITS"
	end
	
	frame.Details.Risk.Text = "RISK: "..riskLevelNames[risk]
	frame.Details.Risk.TextColor3 = riskLevelColors[risk]
	
	frame.Details.Distance.Text = "DISTANCE: "..math.round(distance).." STUDS"
	frame.Details.Distance.TextColor3 = Color3.fromHSV(.33333 - (.33333 * math.clamp(distance/highestExpectedDistance, 0, 1)), 1, 1)
	
	frame.QuestEntry.Value = questEntry
	
	frame.Parent = main.List
	
	frame.LayoutOrder = payout
	
	frame.Accept.Activated:Connect(function()
		local success = remotesFolder.DeadDrops.AcceptQuest:InvokeServer(questEntry)
		updateQuestList()
		
		if success then
			ui.ClaimQuest:Play()
		end
	end)
end

local function clearQuestUI()
	for i,v in pairs(main.List:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

updateQuestList = function()
	clearQuestUI()
	
	if currentNPC ~= nil then
		local quests = questsDir.DeadDrops[currentNPC.Name]:GetChildren()
		for i,questEntry in pairs(quests) do
			if questEntry.CurrentPlayer.Value == nil then
				addQuestUI(questEntry)
			end
		end
	end
end

selectNPC = function(npc)
	if currentNPC == npc then return end
	
	currentNPC = npc
	if npc == nil then
		clearQuestUI()
		main.Visible = false
	else
		main.Header.Quote.Text = npc:GetAttribute("Quote") or ""
		main.Header.ShopName.Text = npc.Name
		
		updateQuestList()
		
		main.Visible = true
		
		local playerCount = #game.Players:GetPlayers()
		
		local lowPlayerCountPenalty = math.min(playerCount/lowPlayerCount, 1)
		local highPlayerCountBonus = math.max(playerCount/50, 1)
		
		if lowPlayerCountPenalty < 1 then
			main.PlayerCount.Text = "Payouts decreased by "..math.ceil((1-lowPlayerCountPenalty)*100).."% due to low player count"
			main.PlayerCount.TextColor3 = Color3.new(1, 0, 0)
			main.PlayerCount.Visible = true
		elseif highPlayerCountBonus > 1 then
			main.PlayerCount.Text = "Payouts increased by "..math.ceil((highPlayerCountBonus-1)*100).."% due to high player count"
			main.PlayerCount.TextColor3 = Color3.new(0, 1, 0)
			main.PlayerCount.Visible = true
		else
			main.PlayerCount.Visible = false
		end
		
		while currentNPC == npc do
			task.wait(.0333)
			if plr.Character == nil then break end
			if plr.Character:FindFirstChild("HumanoidRootPart") == nil then break end
			
			local distance = (plr.Character.HumanoidRootPart.Position - npc.PrimaryPart.Position).Magnitude
			if distance > 13 then
				break
			end
		end
		
		if currentNPC == npc then
			selectNPC(nil)
		end
	end
end

local function onQuestStarted(questEntryPointer)
	while questEntryPointer.Parent ~= nil do
		local locationPart = deadDropLocationsFolder:FindFirstChild(questEntryPointer.Value.Name)
		if locationPart ~= nil then
			finishQuestPrompt.Parent = locationPart
			break
		end
		task.wait(10)
	end
end

local function onQuestEnded()
	finishQuestPrompt.Parent = nil
end

main.Header.Exit.Activated:Connect(function()
	selectNPC(nil)
end)

plr.ChildRemoved:Connect(function(child)
	if child.Name == "CurrentQuest" then
		onQuestEnded(child)
	end
end)

plr.ChildAdded:Connect(function(child)
	if child.Name == "CurrentQuest" then
		onQuestStarted(child)
	end
end)

finishQuestPrompt.Triggered:Connect(function()
	local originalParent = finishQuestPrompt.Parent
	
	finishQuestPrompt.Parent = nil
	local success = remotesFolder.DeadDrops.FinishQuest:InvokeServer()
	
	if success then
		ui.FinishQuest:Play()
	else
		finishQuestPrompt.Parent = originalParent
	end
end)

---- Initializing
local function setUpDeadDropNPC(npc)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = npc.Name
	prompt.ActionText = "View quests"
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Style = Enum.ProximityPromptStyle.Custom

	prompt.Parent = npc.PrimaryPart

	prompt.Triggered:Connect(function()
		selectNPC(npc)
	end)

	prompt.Parent = npc.PrimaryPart
end

local deadDropNPCs
while true do
	deadDropNPCs = cs:GetTagged("DeadDropNPC")
	
	for i,npc in pairs(deadDropNPCs) do
		if npc.PrimaryPart ~= nil then
			if npc.PrimaryPart:FindFirstChildOfClass("ProximityPrompt") == nil then
				setUpDeadDropNPC(npc)
			end
		end
	end
	task.wait(10)
end
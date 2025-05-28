local marketplaceService = game:GetService("MarketplaceService")
local PhysicsService = game:GetService("PhysicsService")
local runService = game:GetService('RunService')
local ServerStorage = game:GetService("ServerStorage")
local Cards = ServerStorage.Cards
local OutfitModule = require(script.OutfitModule)
local radioModule = require(script.RadioModule)
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local remotesFolder = replicatedStorage.Remotes
local ServerStorage = game:GetService("ServerStorage")
local StraightJacket = script.StraightJacket
local serverRemoteFolder = replicatedStorage.ServerRemotes

local GetRankInGroup: (Who:Player, GroupId:number) -> number
do --Safe GetRank
	local RankCache = {}

	function GetRankInGroup(Who:Player, GroupId:number): number
		local Rank = RankCache[GroupId]
		Rank = Rank and Rank[Who]
		if not Rank then
			repeat
				local Succ, Why = pcall(Who.GetRankInGroup, Who, GroupId)
				Rank = Why
				task.wait(.3)
			until Succ

			local Cache = RankCache[GroupId]
			if Cache then
				Cache[Who] = Rank
			else
				Cache = {
					[Who] = Rank
				}
				RankCache[GroupId] = Cache
			end
		end

		return Rank
	end

	local function ClearCache(Who:Player)
		for i, v in next, RankCache do
			v[Who] = nil
		end
	end
	Players.PlayerRemoving:Connect(ClearCache)
end

--TEAM JOIN
local MainGroup = {
	[0] = {Teams["Test Subject"]}, ---Test Subject
	[1] = {Teams["Test Subject"]}, ---Test Subject
	--[2] = {Teams["High Class Test Subject"]},  ---High Class
	[2] = {Teams["CIS Solitary"],true},  ---CIS
	[3] = {Teams["Contained Infected Subject"],true},  ---CIS
	[4] = {Teams["Solitary Confinement"], true},
	[9] = {Teams["Administrative Department"]}, ---AD	
	[253] = {Teams["Site Engineer"],true}, -- Devs
	[255] = {Teams["Administrative Department"],true} --- Owner team UwU
}
----------------------------------------------------------SD GROUP 
local groupTable = {
	[12026513] = Teams["Recontainment Unit"],
	[12026669] = Teams["Special Operations"],
	[11608337] = Teams["Security Department"],
	[12045972] = Teams["Internal Security Bureau"],
	[11648519] = Teams["Scientific Department"],
	[12022092] = Teams["Utility & Maintenance"],
	[11649027] = Teams["Medical Department"],
	[12330631] = Teams["UNSDF"],
	[12267029] = Teams["BWD"]
}
--local teamItems = {
--    ["TEAMNAME"] = {ServerStorage.Items.ITEMONE, ServerStorage.Items.ITEMTWO}
--}

--AGE LIMIT
local MIN_AGE = 45 -- days

local groupWhitelist = { --GROUP WHITELIST
	[11577231] = 0,
}


--CARDS

local cardTable = {
	-----------------------------------------------------------------------High Ranks
	[255] = "Card-L5",
	---owner
	[254] = "Card-L5",---co owner
	[253] = "Card-L5",---dev
	[12] = "Card-L5",---admin
	----------------------------------------------------------------------- Almost High Ranks
	[11] = "Card-L5",---dept admin
	[10] = "Card-L5",---dept intern
	----------------------------------------------------------------------- Clearnaces
	[9] = "Card-L5",---L-5 Clearance
	[8] = "Card-L4",---L-4 Clearance
	[7] = "Card-L3",---L-3 Clearance
	[6] = "Card-L2",---L-2 Clearance
	[5] = "Card-L1"---L-1 Clearance
	------------------------------------------------------------------------- Funni Monsters
	--[3] = "Card-L0",---L-1 Clearance
	------------------------------------------------------------------------- Class D
	--[1] = "Card-L0",---L-0 Clearance


}

local cardBlacklistedTeams = {
	["Contained Infected Subject"] = true,
	["Test Subject"] = true,
	["Solitary Confinement"] = true,
	["CIS Solitary"] = true
}

local teamChangeBlackList = {
	["CIS Solitary"] = true,
	["Solitary Confinement"] = true,
	["Latex"] = true
}

local function getValidSpawns(player)
	local spawns = {}
	for i,v in pairs(workspace.TeamSpawns:GetDescendants()) do
		if v:IsA("Model") then
			local allowedTeams = v:FindFirstChild("AllowedTeams")
			if allowedTeams and allowedTeams:FindFirstChild(player.Team.Name) then
				table.insert(spawns,v)
			end
		end
	end
	return spawns
end

local function playSpawnIntro(player)
	local spawns = getValidSpawns(player)
	if #spawns > 0 then
		local selectedSpawn =  spawns[math.random(#spawns)]
		local character = player.Character or player.CharacterAdded:Wait()

		local rootpart = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:WaitForChild("Humanoid")

		rootpart.CFrame = selectedSpawn.PrimaryPart.CFrame
		rootpart.Anchored = true
		
		if selectedSpawn:FindFirstChild("OnSpawn") then
			if selectedSpawn:FindFirstChild("OnSpawn"):IsA("ModuleScript") then
				require(selectedSpawn.OnSpawn)(player)
			end
		end
		
		humanoid.AutoRotate = false
		local anim = humanoid:WaitForChild("Animator"):LoadAnimation(selectedSpawn.SpawnAnimation)
		anim:Play()

		anim.Stopped:Wait()

		humanoid.AutoRotate = true

		rootpart.Anchored = false
	end
end

remotesFolder.Teams.TeamChanger.OnServerEvent:Connect(function(player,TeamName)	
	if TeamName == "Start" then
		player:LoadCharacter()
		playSpawnIntro(player)
		return
	end
	if teamChangeBlackList[player.Team.Name] then
		return
	end
	TeamName = TeamName.Name
	local selectedTeam
	for i,v in pairs(replicatedStorage.TeamChangeList:GetDescendants())do
		if v.Name == TeamName then
			selectedTeam = v
			break
		end
	end
	if selectedTeam then
		local Overwrite = false
		local UserIDs = selectedTeam:FindFirstChild("UserIDs") and require(selectedTeam.UserIDs)
		local rankInGroup = selectedTeam:FindFirstChild("GroupId") and serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, selectedTeam.GroupId.Value)

		if UserIDs then
			for _,v in pairs(UserIDs) do
				if v == player.UserId then
					Overwrite = true
					break
				end
			end
		end

		if (((selectedTeam:FindFirstChild("MinRank") and rankInGroup >= selectedTeam.MinRank.Value)) or (selectedTeam:FindFirstChild("SetRank") and rankInGroup == selectedTeam.SetRank.Value)) or Overwrite or (serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, 11577231) >= 253) then
			player.Team = Teams[TeamName]	
		end
	end
end)

itemCooldown = {}
local function giveItems(playerReceivingItems)
	if playerReceivingItems:FindFirstChild("Backpack") == nil then
		warn("Backpack is nil!!")
	end
	if itemCooldown[playerReceivingItems] == nil then
		itemCooldown[playerReceivingItems] = true
		delay(3,function()
			local duplicateList = {}
			for i,v in pairs(playerReceivingItems.Backpack:GetChildren())do
				if duplicateList[v.Name] then
					v:Destroy()
				else
					duplicateList[v.Name] = true
				end
			end
		end)
		playerReceivingItems:WaitForChild("Backpack")
		local rank = serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(playerReceivingItems, 11577231)
		--print(#playerReceivingItems.Team:GetChildren(),#playerReceivingItems.Backpack:GetChildren())
		for i,v in pairs(playerReceivingItems.Team:GetChildren())do
			if v:IsA("Tool") and playerReceivingItems.Backpack:FindFirstChild(v.Name) == nil then
				v:Clone().Parent = playerReceivingItems.Backpack
			end
		end

		if cardTable[rank] and Cards:FindFirstChild(cardTable[rank]) and playerReceivingItems.Backpack:FindFirstChild(cardTable[rank]) == nil and not cardBlacklistedTeams[playerReceivingItems.Team.Name]  then
			Cards[cardTable[rank]]:Clone().Parent = playerReceivingItems.Backpack
		end
		if playerReceivingItems.Backpack:FindFirstChild("Hug") == nil then
			ServerStorage.Tools.Hug:Clone().Parent = playerReceivingItems.Backpack
		end
		if playerReceivingItems.Backpack:FindFirstChild("Fists") == nil then
			ServerStorage.Tools.Fists:Clone().Parent = playerReceivingItems.Backpack
		end

		if serverRemoteFolder.PlayerData.GetOwnsGamePass:Invoke(playerReceivingItems.UserId, 22981213) and not playerReceivingItems.Backpack:FindFirstChild("Boombox") then
			ServerStorage.Tools.Boombox:Clone().Parent = playerReceivingItems.Backpack
		end
		if serverRemoteFolder.PlayerData.GetOwnsGamePass:Invoke(playerReceivingItems.UserId, 27993886) and not playerReceivingItems.Backpack:FindFirstChild("Sign") then
			ServerStorage.Tools.Sign:Clone().Parent = playerReceivingItems.Backpack
		end
		if playerReceivingItems.UserId == 161210860 then
			ServerStorage.Tools["Indestructible Vent"]:Clone().Parent = playerReceivingItems.Backpack
		end
		itemCooldown[playerReceivingItems] = nil
	end
end


local Attachments = {
	{"NeckHeadAttachment",Vector3.new(0,-0.6,0),"Head"}	,
	{"RightHipAttachment",Vector3.new(0,1,0),"Right Leg"},
	{"LeftHipAttachment",Vector3.new(0,1,0),"Left Leg"},
	{"RightWaistAttachment",Vector3.new(-0.6,-1,0),"Torso"},
	{"LeftWaistAttachment",Vector3.new(0.6,-1,0),"Torso"}
}

local TextService = game:GetService("TextService")
local function getTextObject(fromPlayerId, msg)
	local textObject
	local success, errorMessage = pcall(function()
		textObject = TextService:FilterStringAsync(msg, fromPlayerId)
	end)
	if success then
		return textObject
	else
		warn(errorMessage)
	end

	return false
end 

local function characterAdded(player,character)
	local forcefield = Instance.new("ForceField")
	forcefield.Parent = character

	game.Debris:AddItem(forcefield, 12)

	local rootpart=	character:WaitForChild("HumanoidRootPart")
	rootpart.RootPriority = 5
	local humanoid  = character:WaitForChild("Humanoid")
	humanoid.BreakJointsOnDeath = false
	for i,v in pairs(Attachments)do
		local Attachement = Instance.new("Attachment",character[v[3]])
		Attachement.Name = v[1]
		Attachement.Position = v[2]
	end
	local offset = {
		["Neck"] = {character.Head.NeckHeadAttachment,character.Torso.NeckAttachment},
		["Right Shoulder"] = {character["Right Arm"].RightShoulderAttachment,character.Torso.RightCollarAttachment},
		["Left Shoulder"] = {character["Left Arm"].LeftShoulderAttachment,character.Torso.LeftCollarAttachment},
		["Right Hip"] = {character["Right Leg"].RightHipAttachment,character.Torso.RightWaistAttachment},
		["Left Hip"] = {character["Left Leg"].LeftHipAttachment,character.Torso.LeftWaistAttachment}} --
	for i,v in pairs(character:GetDescendants())do
		if v:IsA("Motor6D") and v.Name ~="Tool" then
			local Ball = Instance.new("BallSocketConstraint",v.Parent)
			local a =  offset[v.Name]
			if a then
				Ball.Attachment0 = a[1]
				Ball.Attachment1 = a[2]
			else
				local attachment0 = Instance.new("Attachment",v.Part0)
				local attachment1 = Instance.new("Attachment",v.Part1)
				Ball.Attachment0 = attachment0
				Ball.Attachment1 = attachment1
				Ball.Name = v.Name
				attachment0.Position = v.Part0.Position - v.Part1.Position
			end
			Ball.Enabled = true
			Ball.LimitsEnabled = false
			--Ball.UpperAngle = 360
		end
		if v:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(v, "Players")
		end
	end

	humanoid.Died:Connect(function()
		itemCooldown[player] = nil
		for i, v in pairs(character:GetDescendants()) do
			if v:IsA("Motor6D")  then
				v.Enabled = false
			elseif v:IsA("BasePart") and v.Parent == character then
				v.CanCollide = true
				--elseif v:IsA("Attachment") and v.Name == "HatAttachment" then

			end
		end
	end)


	if player.Team == Teams["Solitary Confinement"] then
		remotesFolder.Backpack:FireClient(player,false)
		local straightTrack = humanoid.Animator:LoadAnimation(StraightJacket)
		task.spawn(function()
			repeat
				straightTrack:Play()
				task.wait()
			until player.Character == nil  
		end)
	else
		-- remotesFolder.Backpack:FireClient(player,true)
	end

	local spawns = getValidSpawns(player)
	if #spawns > 0 then
		local selectedSpawn = spawns[math.random(#spawns)]
		rootpart.CFrame = selectedSpawn.PrimaryPart.CFrame
	end
end

local function characterAppearance(player,character)
	if player.Team.Name == "Test Subject" then
		for _, i: Instance in next, character:GetChildren() do
			if i:IsA("CharacterMesh") then
				if i.MeshId ~= 48112070 then
					i:Destroy()
				end
			elseif i:IsA('ShirtGraphic') then
				i:Destroy()
			end
		end
	end
	giveItems(player)
	--OutfitModule(player, player.Character)
end

Players.PlayerAdded:Connect(function(player)

	---///---///---///---EXTERNAL GROUPS---///---///---///---

	local accountAge = player.AccountAge
	local difference = math.floor(MIN_AGE - accountAge)
	local isWhitelisted = false
	
	if table.find(whitelistedUserId, player.UserId) then
		isWhitelisted = true
	end

	--for id, rank in next, groupWhitelist do
	--	if player:IsInGroup(id) and player:GetRankInGroup(id) >= rank then
	--		isWhitelisted = true
	--	end
	--end

	--if (difference > 1) and not runService:IsStudio() and not isWhitelisted then
	--if (difference > 1) and not runService:IsStudio() then
	--^These two lines are for save

	if (difference > 1) and not (runService:IsStudio() or isWhitelisted) then
		local format = ('Your account age [%s] is below the min account age [%s].')

		player:Kick(format:format(accountAge, MIN_AGE))
	end
	--if player.Character then
	--	characterAdded(player,player.Character)
	--end
	player.CharacterAdded:Connect(function(char)
		characterAdded(player,char)
	end)
	player.CharacterAppearanceLoaded:Connect(function(char)
		characterAppearance(player,char)
	end)
	player.Chatted:Connect(function(msg)
		if player.Character and player.Character.PrimaryPart then
			radioModule(player,msg)
		end
		--local filteredMsg = getTextObject(player.UserId,msg)
		--if filteredMsg ~= "false" then
		--	replicatedStorage.Remotes.ChatEvent:FireAllClients(player,msg)
		--end
	end)
	--player:LoadCharacter()
	player.CharacterAdded:Wait()

	---///---///---///---EXTERNAL GROUPS---///---///---///---
	--check for UNSDF
	if serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, 12330631) > 0 then
		player.Team = Teams["UNSDF"]
	end

	--check for BWD
	if serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, 12267029) > 0 then
		player.Team = Teams["BWD"]
	end

	--check for Blackwater
	if serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, 12658917) > 0 then
		player.Team = Teams["Blackwater"]
	end

	local blocked =  false
	local rankData = MainGroup[serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, 11577231)]
	if rankData then
		player.Team = rankData[1]
		if rankData[2] then
			blocked = true
		end
	end
	if not blocked then
		for groupId,groupTeam in pairs(groupTable)do		
			if serverRemoteFolder.PlayerData.GetPlayerRankInGroup:Invoke(player, groupId) > 0 then			
				player.Team = groupTeam
			end 
		end
	end
end)

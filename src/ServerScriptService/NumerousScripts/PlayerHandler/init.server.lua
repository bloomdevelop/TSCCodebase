-- SERVICES
local DebrisService = game:GetService('Debris')
local WorkspaceService = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local PhysicsService = game:GetService('PhysicsService')
local PlayersService = game:GetService('Players')
local TeamService = game:GetService('Teams')
local RunService = game:GetService('RunService')
local ServerStorage = game:GetService('ServerStorage')

-- MODULES
local PlayerData = require(script.PlayerData)
local Constants = require(script.Constants)
local Radios = require(script.RadioModule)
local GroupInfo = require(script.GroupInfo)
local ToolInfo = require(script.ToolInfo)
local Blacklists = {
	Groups = require(script.GroupBlacklists),
	Users = require(script.UserBlacklists)
}

local Resize = require(script.Resize)
local Create = require(ReplicatedStorage.Modules.Create)

-- FOLDERS
local Remotes = ReplicatedStorage.Remotes
local Bindables = ServerStorage.Bindables

local Cards = ServerStorage.Cards
local Chars = ServerStorage.Chars
local Tools = ServerStorage.Tools
local RestrictedTools = ServerStorage.RestrictedTools

-- TYPES
export type GroupData = {
	Emblem: number | string,
	IsInClan: boolean,
	IsPrimary: boolean,
	Name: string,
	Rank: number,
	Role: string
}

export type GroupDatas = {
	[number]: GroupData
}

export type AssetData = {
	[number]: boolean
}

export type PlayerDataType = {
	UserId: number,
	Refreshs: {[string]: number},
	GroupData: GroupDatas,
	AssetData: AssetData,
	SelectedTeam: string,
	FetchGroups: (self: any) -> nil,
	GetGroups: (self: any) -> GroupDatas,
	GetRankInGroup: (self: any, GroupId: number | string) -> number,
	GetRoleInGroup: (self: any, GroupId: number | string) -> string,
	GetOwnsGamePass: (self: any, AssetId: number) -> boolean
}

-- VARIABLES
local Datas: {[Player | string]: PlayerDataType} = {}
local Cooldown = {}
local UserBlacklist = {}

-- FUNCTIONS
local function DeepCopy<K, V>(table:{ [K]: V }): { [K]: V }
	local copy: { [K]: V } = {}
	for k, v in pairs(table) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function getValidSpawns(team: string)
	local spawns = {}
	for _, i in next, WorkspaceService.TeamSpawns:GetDescendants() do
		if i.Name == "AllowedTeams" and i.Parent:IsA('Model') and i:FindFirstChild(team) then
			table.insert(spawns, i.Parent)
		end
	end
	return spawns
end

function playSpawnIntro(player: Player, team)
	if not team and not player.Team then return end
	local spawns = getValidSpawns(team or (player.Team :: Team).Name)
	if #spawns > 0 then
		local selected_spawn: Model & { SpawnAnimation: Animation } = spawns[Random.new():NextInteger(1, #spawns)]
		if selected_spawn.PrimaryPart == nil then
			return
		end
		player.ReplicationFocus = selected_spawn.PrimaryPart
		local character = player.Character or player.CharacterAdded:Wait()

		local root_part: BasePart? = character:WaitForChild("HumanoidRootPart", 10)
		local humanoid: Humanoid? = character:WaitForChild("Humanoid", 10)

		if root_part and humanoid then
			--player:SetAttribute('__Spawned', true)
			player:RequestStreamAroundAsync((selected_spawn.PrimaryPart :: BasePart).Position)

			root_part.Anchored = true
			humanoid.AutoRotate = false
			humanoid:ChangeState(Enum.HumanoidStateType.Seated)
			--root_part.CFrame = (selected_spawn.PrimaryPart :: BasePart).CFrame
			Bindables.Anticheat.AuthorizeTeleport:Fire(player, selected_spawn.PrimaryPart.CFrame)
			
			pcall(function()
				local track: AnimationTrack = (humanoid :: any):LoadAnimation(selected_spawn.SpawnAnimation)
				track:Play()
				
				if selected_spawn:FindFirstChild("OnSpawn") then
					if selected_spawn:FindFirstChild("OnSpawn"):IsA("ModuleScript") then
						require(selected_spawn.OnSpawn)(player,track)
					end
				end
			end)
			
			task.wait(6)

			root_part.Anchored = false
			humanoid.AutoRotate = true
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			--humanoid.Died:Connect(function()
			--	player:SetAttribute('__Spawned', false)
			--end)
		end
		task.delay(5, function() -- remove it lol
			player.ReplicationFocus = nil
		end)
	end
end

function giveItem(player, item)
	if player.Backpack:FindFirstChild(item.Name) then
		return
	else
		item:Clone().Parent = player.Backpack
	end
end

local forced_rank = 252

function assignMorph(player: Player, character: Model)
	local team = player.Team
	character = character or player.Character
	if not team or not character then return end

	--// Apply default tools
	for _, toolname in next, ToolInfo.DefaultTools do
		if ServerStorage.Tools:FindFirstChild(toolname) then
			if toolname == "Fists" and player:GetAttribute("FistsTrained") == true then
				giveItem(player, ServerStorage.Tools["Trained Fists"])
			else
				giveItem(player, ServerStorage.Tools[toolname])
			end
		end
	end

	--// Apply team tools
	for _, toolname in next, (team:GetAttribute('Tools')):split(",") do
		if ServerStorage.Tools:FindFirstChild(toolname) then
			giveItem(player, ServerStorage.Tools[toolname])
		elseif ServerStorage.Cards:FindFirstChild(toolname) then
			giveItem(player, ServerStorage.Cards[toolname])
		end
	end

	--// Apply card tools
	if GroupInfo.CardBlacklistTeams[team.Name] == nil then
		for _, cardinfo in next, ToolInfo.CardLevels do
			if cardinfo.Levels[Datas[player]:GetRankInGroup(GroupInfo.MainGroup)] then
				giveItem(player, ServerStorage.Cards[cardinfo.Card])
			end
		end
	end

	--// Apply rewarded items
	for _, i in next, ToolInfo.ToolGrants do
		if i.AssetId then
			local owns_it = Datas[player]:GetOwnsGamePass(i.AssetId)
			if owns_it then
				giveItem(player, ServerStorage.Tools[i.ToolName])
			end
		end
		if i.UserIDs and table.find(i.UserIDs, player.UserId) then
			giveItem(player, ServerStorage.Tools[i.ToolName])
		end
	end

	--// Remove unwanted body meshes
	for _, i: Instance in next, character:GetChildren() do
		if i:IsA("CharacterMesh") then
			if i.MeshId ~= 48112070 then
				i:Destroy()
			end
		elseif i:IsA('ShirtGraphic') then
			i:Destroy()
		end
	end
	--// Morph Checks //--
	local TeamFolder = Chars:FindFirstChild(team.Name)
	if not TeamFolder then
		warn("Team \"" .. team.Name .. "\" not found in character storage!")
		return
	end
	local Outfit = TeamFolder:FindFirstChild('Default')
	local Overwrite: boolean = false
	local GroupId: string | number = TeamFolder:GetAttribute('GroupId')
	local UserID: string = tostring(player.UserId)
	--print(GroupId)
	--print(player.Team)
	for _, Morph in next, TeamFolder:GetChildren() do
		local UserIDs: string? = Morph:GetAttribute('UserIDs') -- get morph userids if existing
		if UserIDs then
			for _, id in next, UserIDs:split(",") do
				if id == UserID then
					--print('overwriting with '.. Morph.Name)
					Overwrite = true
					Outfit = Morph
				end
			end
		end
		if GroupId and not Overwrite then
			local Rank: string = Morph:GetAttribute('Rank') -- get morph rank
			local GroupId: string | number = Morph:GetAttribute('GroupId') or TeamFolder:GetAttribute('GroupId') -- get morph groupid, or the team groupid
			if Rank and type(Rank) == "string" and Datas[player].GroupData[tonumber(GroupId) :: number] then -- if morph rank exists
				local playerRank: number | string = Datas[player]:GetRankInGroup(GroupId)
				for _, rank: string in next, Rank:split(',') do
					if tonumber(playerRank) == tonumber(Rank) then -- if the player is in the group and has equal rank
						Outfit = Morph
					end
				end
			end
		end
	end
	
	--// CIS Latex Selection
	if team == TeamService["Contained Infected Subject"] then
		local CIS = player:GetAttribute("CISLatex")
		if CIS == nil and Overwrite then
			CIS = "Custom"
		elseif CIS == nil and not Overwrite then
			CIS = "DarkLatex"
		end
		if CIS == "Custom" and not Overwrite then
			CIS = "DarkLatex"
		end
		if CIS ~= "Custom" then
			local Latex = game:GetService("ServerScriptService").LatexSystem.Infected:FindFirstChild(CIS)
			if (Latex) then
				character.Head.face.Texture = Latex.face.Texture
				while not player:HasAppearanceLoaded() do task.wait() end
				task.wait()
				for i,v in pairs(character:GetChildren()) do
					if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
						v:Destroy()
					elseif v:IsA("Accessory") then
						local isHair = v.AccessoryType == Enum.AccessoryType.Hair or v.Handle:FindFirstChild("HairAttachment") ~= nil
						local isHat = v.AccessoryType == Enum.AccessoryType.Hat or v.Handle:FindFirstChild("HatAttachment") ~= nil
						if not isHat and not isHair then
							v:Destroy()
						else
							local Mesh = v.Handle:FindFirstChildOfClass("SpecialMesh")
							if (Mesh) then
								Mesh.VertexColor = Vector3.new(Latex:GetAttribute("Color").R, Latex:GetAttribute("Color").G, Latex:GetAttribute("Color").B)
								Mesh.TextureId = "rbxassetid://5614579544"
							else
								v:Destroy()
							end
							Mesh = nil
						end
					end
				end
				for i,v in pairs(Latex:GetChildren()) do
					if v:IsA("Accessory") or v:IsA("BodyColors") then
						v:Clone().Parent = character
					end
				end
				local LatexValues = character:WaitForChild("LatexValues")
				if CIS == "SquidDog" or "TigerShark" then
					LatexValues.LatexType.Value = "WhiteLatex"
				else
					LatexValues.LatexType.Value = CIS
				end
				if Latex:GetAttribute("NoWeapon") then
					LatexValues.NoWeapon.Value = true
				end
				if CIS == "HypnoCat" then
					--Tools.Hypno:Clone().Parent = player.Backpack
				elseif CIS == "SpiderWolf" then
					--Tools["Web Trap"]:Clone().Parent = player.Backpack
				end
				for i,v in pairs(Chars["Contained Infected Subject"].Default:GetChildren()) do
					if v:IsA("Shirt") or v:IsA("Pants") then
						v:Clone().Parent = character
					end
				end
				character.Humanoid.MaxHealth = 250
				character.Humanoid.Health = character.Humanoid.MaxHealth
				return
			end
		end
	end
	--print(Outfit and Outfit.Name or "No Outfit Given")

	if Outfit then
		local Humanoid = character:FindFirstChild('Humanoid') :: Humanoid
		local Head = character:FindFirstChild('Head') :: Instance

		--// Appearance Checks //--
		-- Health, Resize, ClearChar, UserIDs, GroupId, RemoveFace, Tools, FaceId
		local Attributes = {
			H = Outfit:GetAttribute('Health'),
			R = Outfit:GetAttribute('Resize'),
			C = Outfit:GetAttribute('ClearChar'),
			F = Outfit:GetAttribute('RemoveFace'),
			S = Outfit:GetAttribute('Speed'),
			T = Outfit:GetAttribute('Tools'),
			FI = Outfit:GetAttribute("FaceId"),
			L = Outfit:GetAttribute("LatexType"),
			CIP = Outfit:GetAttribute("CIP"),
			Immunity = Outfit:GetAttribute("Immunity"),
			FullImmunity = Outfit:GetAttribute("FullImmunity")
		}

		--// Health
		if Humanoid and Attributes.H then
			Humanoid.MaxHealth = Attributes.H
			Humanoid.Health = Attributes.H
		end
		
		Humanoid:SetAttribute("DefaultMaxHealth", Humanoid.MaxHealth)

		--// Speed
		if Humanoid and Attributes.S then
			Create("NumberValue", Humanoid)({
				Value = tonumber(Attributes.S),
				Name = "MorphAssigned"
			})
		end

		--// RemoveFace
		if Head and Attributes.F then
			--for _, i in next, Head:GetChildren() do
			--	if i:IsA('Decal') then
			--		i:Destroy()
			--	end
			--end
			Head.face:Destroy()
		end

		--// FaceId
		if Head and not Attributes.F and Attributes.FI then
			Head.face.Texture = Attributes.FI
		end
		
		--// ClearCharacter
		if Attributes.C then
			while not player:HasAppearanceLoaded() do task.wait() end
			Humanoid:RemoveAccessories()
			for _, i in next, character:GetChildren() do
				if i:IsA("BodyColors") then
					i:Destroy()
				end
			end
		end

		--// Apply New Shirts and pants
		if Outfit:FindFirstChildOfClass('Shirt') and character:FindFirstChildOfClass('Shirt') then
			(character:FindFirstChildOfClass('Shirt') :: Shirt):Destroy()
		end
		if Outfit:FindFirstChildOfClass('Pants') and character:FindFirstChildOfClass('Pants') then
			(character:FindFirstChildOfClass('Pants') :: Pants):Destroy()
		end

		--// Apply Morph
		for _, i in next, Outfit:GetChildren() do
			if not i:GetAttribute("NoResize") then
				i:Clone().Parent = character
			end
		end

		--// Resize
		if Attributes.R then
			--task.delay(5, function()
			Resize(character, math.clamp(Attributes.R, 0.5, 2))
			--end)
		end
		
		--// Apply (NoResize Morph)
		for _, i in next, Outfit:GetChildren() do
			if i:IsA("Accessory") and i:GetAttribute("NoResize") then
				i:Clone().Parent = character
			end
		end
		
		--// Apply LatexType
		if Attributes.L then
			local LatexValues = character:WaitForChild("LatexValues")
			LatexValues:WaitForChild("LatexType").Value = Attributes.L
		end
		
		--// Apply CIP
		if Attributes.CIP then
			local LatexValues = character:WaitForChild("LatexValues")
			LatexValues:WaitForChild("IsCIP").Value = Attributes.CIP
			LatexValues:WaitForChild("LatexType").Value = "WhiteLatex"
			
			if Humanoid then
				Humanoid.MaxHealth = 200
				Humanoid.Health = 200
				Humanoid:SetAttribute("DefaultMaxHealth", Humanoid.MaxHealth)
			end
		end
		
		--// Apply Immunity
		if Attributes.Immunity then
			local LatexValues = character:WaitForChild("LatexValues")
			LatexValues:WaitForChild("MaxInfectionValue").Value = Attributes.Immunity
		end
		
		--// Apply Full Immunity
		if Attributes.FullImmunity then
			local LatexValues = character:WaitForChild("LatexValues")
			LatexValues:WaitForChild("FullImmunity").Value = Attributes.FullImmunity
		end

		--// Apply tools
		if Attributes.T then
			for _, toolname in next, Attributes.T:split(',') do
				if ServerStorage.Tools:FindFirstChild(toolname) then
					giveItem(player, ServerStorage.Tools[toolname])
				elseif ServerStorage.Cards:FindFirstChild(toolname) then
					giveItem(player, ServerStorage.Cards[toolname])
				end
			end
		end
	else
		warn("Default outfit missing from \"" .. team.Name .. "\" folder!")
	end

	--// Apply team folder tools
	if TeamFolder:GetAttribute('Tools') then
		for _, toolname in next, (TeamFolder:GetAttribute('Tools')):split(',') do
			if ServerStorage.Tools:FindFirstChild(toolname) then
				giveItem(player, ServerStorage.Tools[toolname])
			elseif ServerStorage.Cards:FindFirstChild(toolname) then
				giveItem(player, ServerStorage.Cards[toolname])
			end
		end
	end
end

function CharacterAdded(player: Player, character: Model)
	if not Datas[player] then
		player:Kick('\n\nInternal Server Error [50001]\n\nPlayer registery failure')
		return
	end
	(player:FindFirstChildOfClass("Backpack") :: Backpack):ClearAllChildren()

	--print('Loading character of [' .. player.Name .. ']')
	local Humanoid = character:WaitForChild('Humanoid', 10) :: Humanoid
	local RootPart = character:WaitForChild('HumanoidRootPart', 10) :: Instance

	--// forcefield
	local ForceField = Create("ForceField", character)({})

	DebrisService:AddItem(ForceField, 10)

	--// rootpart
	if RootPart ~= nil then
		RootPart.RootPriority = 5
	end

	----// Team reset
	--if Humanoid ~= nil then
	--	Humanoid.Died:Connect(function()
	--		player.Team = TeamService:FindFirstChild('Menu') or nil
	--	end)
	--end

	task.wait(1) -- Avoid unforeseen consequences

	if player.Team and (player.Team :: Team).Name == "Solitary Confinement" then
		ReplicatedStorage.Remotes.Backpack:FireClient(player, false)
		if Humanoid ~= nil then
			Humanoid:LoadAnimation(script.StraightJacket):Play()
		end
	end
	
	--if player:GetAttribute('__Spawned') ~= true then
		task.spawn(function()
			-- removed because it works in the function loool
			--if not player.Character then player.CharacterAdded:Wait() end
			playSpawnIntro(player)
		end)	
	--end
	assignMorph(player, character)
end

function Chatted(player: Player, msg: string)
	if player.Character and player.Character.PrimaryPart then
		Radios.Chatted(player, msg)
	end
end

local spawning = {}

-- SWITCHES
local RemoteSwitches = {
	["Start"] = function(player)
		if (spawning[player] ~= nil) and (spawning[player] > tick()) then
			return false
		end
		spawning[player] = tick() + 5
		player.Team = game.Teams[Datas[player].SelectedTeam]
		player:LoadCharacter()
		--if not player.Character then player.CharacterAdded:Wait() end
		--playSpawnIntro(player)
		return true
	end,
	["SwitchTeam"] = function(player, team, CIS)
		if
			GroupInfo.TeamChangeBlacklist[team] == nil and
			(Datas[player].GroupData[GroupInfo.MainGroup] == nil or -- if the rank does't exist
				Datas[player].GroupData[GroupInfo.MainGroup] ~= nil and -- if the rank exists
				(
					Datas[player]:GetRankInGroup(GroupInfo.MainGroup) ~= 4 -- solitary rank
				))
		then
			local selected_team = ReplicatedStorage.TeamChangeList:FindFirstChild(team, true)
			if selected_team then
				local rank_in_team =
					selected_team:FindFirstChild('GroupId') and -- does groupid object exists?
					Datas[player]:GetRankInGroup(selected_team.GroupId.Value)
				if
					( -- has min rank
						selected_team:FindFirstChild('MinRank') and
							(rank_in_team >= selected_team.MinRank.Value)
					) or ( -- has set rank
						selected_team:FindFirstChild('SetRank') and
							(rank_in_team >= selected_team.SetRank.Value)
					) or ( -- has developer rank+
						Datas[player]:GetRankInGroup(GroupInfo.MainGroup) and
							Datas[player]:GetRankInGroup(GroupInfo.MainGroup) > 250
					)
				then
					if (CIS) then
						player:SetAttribute("CISLatex", CIS)
					end
					Datas[player].SelectedTeam = team
					player.Team = TeamService:FindFirstChild(team)
					return true
				end
			end
		end
		return false
	end,
}

-- CORE

ReplicatedStorage.Remotes.Teams.TeamChanger.OnServerInvoke = function(player, eventType, ...)
	Cooldown[player] = (Cooldown[player] ~= nil) and Cooldown[player] + 1 or 1
	if Cooldown[player] > 10 then
		player:Kick("\n\nUnexpected Client Behaviour [1005]\n\nToo many requests")
		return
	elseif Cooldown[player] > 5 then
		return
	end
	if RemoteSwitches[eventType] ~= nil then
		return RemoteSwitches[eventType](player, ...)
	end
	return false
end

ReplicatedStorage.ServerRemotes.PlayerData.GetPlayerRankInGroup.OnInvoke = function(Player: Player | string, GroupId: number): number | nil
	if type(Player) == "string" then
		Player = PlayersService:FindFirstChild(Player)
	end
	if Player == nil then
		return nil
	end
	if Datas[Player] ~= nil then
		local rank: number = Datas[Player]:GetRankInGroup(GroupId)
		return rank
	end
	return nil
end

ReplicatedStorage.ServerRemotes.PlayerData.GetPlayerRoleInGroup.OnInvoke = function(Player: Player | string, GroupId: number): string | nil
	if type(Player) == "string" then
		Player = PlayersService:FindFirstChild(Player)
	end
	if Player == nil then
		return nil
	end
	if Datas[Player] ~= nil then
		local role: string = Datas[Player]:GetRoleInGroup(GroupId)
		return role
	end
	return nil
end

ReplicatedStorage.ServerRemotes.PlayerData.GetOwnsGamePass.OnInvoke = function(Player: Player | string, AssetId: number): boolean
	if type(Player) == "string" then
		Player = PlayersService:FindFirstChild(Player)
	end
	if Player == nil then
		return false
	end
	if Datas[Player] ~= nil then
		local ownsAsset: boolean = Datas[Player]:GetOwnsGamePass(AssetId)
		return ownsAsset
	end
	return false
end

ReplicatedStorage.ServerRemotes.PlayerData.UpdatePlayerGroupData.OnInvoke = function(Player: Player | string, Force: boolean): any?
	if type(Player) == "string" then
		Player = PlayersService:FindFirstChild(Player)
	end
	if Player == nil then return end
	if Datas[Player] ~= nil then
		if Force then Datas[Player]:FetchGroups() else Datas[Player]:GetGroups() end
		return
	end
	return
end


local whitelistedUserId = {3635305041, 3728301645}
local testDevs = {3379366931}

function playerAdded(Player: Player)
	local isAgeWhitelisted = false
	
	if table.find(whitelistedUserId, Player.UserId) then
		isAgeWhitelisted = true
	end
	
	local AgeBlacklisted = Constants.MIN_AGE > Player.AccountAge
	if AgeBlacklisted and not (RunService:IsStudio() or isAgeWhitelisted) then
		Player:Kick(('Your account age [%s] is below the min account age [%s].'):format(tostring(Player.AccountAge), Constants.MIN_AGE))
	end

	if Datas[Player] == nil then
		Datas[Player] = PlayerData(Player.UserId) -- we're making a weak link here on purpose so if the player dies, the PlayerDataObject is deleted
	end

	Player.CharacterAdded:Connect(function(a) CharacterAdded(Player, a) end)
	Player.Chatted:Connect(function(a) Chatted(Player, a) end)
	
	if RunService:IsStudio() then
		if table.find(testDevs, Player.UserId) then
			Player.Team = game.Teams["!Testing Zone"] 
		end
	end

	task.spawn(function()
		Datas[Player]:FetchGroups()
	end)
end

PlayersService.PlayerAdded:Connect(playerAdded)
for _, p: Player in next, PlayersService:GetPlayers() do
	playerAdded(p)
end

for _, i: Instance in next, Chars:GetDescendants() do
	if i:IsA('BasePart') then
		i.CanQuery = true
		i.CanTouch = false
		i.CanCollide = false
		i.Massless = true
		i.RootPriority = 0
	end
end

-- COOLDOWN HANDLING
local currentBeat = 0
RunService.Heartbeat:Connect(function(dt)
	if currentBeat < 5 then
		currentBeat = 0
		for p, i in next, Cooldown do
			if i > 0 then
				Cooldown[p] -= 1
			end
		end
	else
		currentBeat += dt
	end
end)
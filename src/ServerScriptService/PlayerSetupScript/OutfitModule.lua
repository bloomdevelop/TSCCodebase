local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerRemotes = ReplicatedStorage:WaitForChild("ServerRemotes")
local PlayerData = ServerRemotes:WaitForChild("PlayerData")
local GetPlayerRankInGroup = PlayerData:WaitForChild("GetPlayerRankInGroup")

local OutfitDir = game.ServerStorage.Chars

function resize(char, num)
	local motors = {}
	table.insert(motors, char.HumanoidRootPart:FindFirstChild("RootJoint"))
	for _, motor in next, char.Torso:GetChildren() do
		if motor:IsA("Motor6D") then
			table.insert(motors, motor)
		end
	end
	for _, motor in next, motors do
		motor.C0 = CFrame.new((motor.C0.Position * num)) * (motor.C0 - motor.C0.Position)
		motor.C1 = CFrame.new((motor.C1.Position * num)) * (motor.C1 - motor.C1.Position)
	end
	for _, v in next, char:GetDescendants() do
		if v:IsA("BasePart") then
			v.Size *= num
		elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
			local handle = v.Handle
			handle.AccessoryWeld.C0 = CFrame.new((handle.AccessoryWeld.C0.Position * num)) * (handle.AccessoryWeld.C0 - handle.AccessoryWeld.C0.Position)
			handle.AccessoryWeld.C1 = CFrame.new((handle.AccessoryWeld.C1.Position * num)) * (handle.AccessoryWeld.C1 - handle.AccessoryWeld.C1.Position)
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			if mesh then
				mesh.Scale *= num
			end
		elseif v:IsA("SpecialMesh") and v.Parent.Name ~= "Handle" and v.Parent.Name ~= "Head" then
			v.Scale *= num
		end
	end
end

function AssignOutfit(Folder,player)
	local char = player.Character or player.CharacterAdded:Wait()
	
	--// Appearance Checks //--
	
	--// ClearCharacter
	local ClearChar = Folder:FindFirstChild('ClearChar', true)
	if ClearChar and ClearChar.Value then
		local humanoid = char:WaitForChild("Humanoid")
		humanoid:RemoveAccessories()
	end
	--// RemoveFace
	local RemoveFace = Folder:FindFirstChild('RemoveFace', true)
	if RemoveFace then
		local head = char:WaitForChild('Head')
		for _, i in next, head:GetChildren() do
			if i:IsA('Decal') then
				i:Destroy()
			end
		end
	end
	--// Resize
	local Resize = Folder:FindFirstChild('Resize', true)
	if Resize then
		task.delay(5, function()
			resize(char, Resize.Value)
		end)
	end
	--// Health
	local Health = Folder:FindFirstChild('Health', true)
	if Health then
		task.delay(1, function()
			local humanoid = char:WaitForChild('Humanoid')
			humanoid.MaxHealth = Health.Value
			humanoid.Health = Health.Value
		end)
	end
	
	--// Update Appearance // --
	
	--// Remove Player's Outfit
	local KeepClohting = Folder:FindFirstChild('KeepClohting', true)
	if KeepClohting == nil then
		local shirt = char:FindFirstChild("Shirt") 
		local pants = char:FindFirstChild("Pants")
		if shirt then shirt:Destroy() end
		if pants then pants:Destroy() end
	end
	
	local CDlabel = Folder:FindFirstChild('cdLabel') --// Assign Class-D label if present in outfit
	if CDlabel then
		local CDclone = CDlabel:Clone()
		CDclone.Parent = char.Torso
		CDclone.Adornee = char.Torso
		CDclone.TextLabel.Text = ("D-"..player.UserId)
	end 
	
	for _, ITEM in ipairs(Folder:GetChildren()) do --// Getting dressed
		if ITEM:IsA("Folder") or ITEM:IsA("Configuration") or ITEM:IsA("ValueBase") then continue end
		ITEM:Clone().Parent = not ITEM:IsA("Tool") and char or player.Backpack
	end
	
end

module = function(player)
	local TeamFolder = OutfitDir:FindFirstChild(player.Team.Name)
	if not TeamFolder then
		warn("Team not found in config! Source: ".. script:GetFullName())
		return
	end
	local OutfitFolder = TeamFolder:FindFirstChild('Default') --// Use default folder before we decide if player deserves better
	--print(TeamFolder)
	-- Get Group ID
	local GroupId = TeamFolder:FindFirstChild('GroupId') and TeamFolder.GroupId.Value or nil
	if GroupId then
		local Overwrite = false
		for _,Folder in pairs(TeamFolder:GetChildren()) do
			local UserIDs = Folder:FindFirstChild('UserIDs',true)
			if not (UserIDs and UserIDs:IsA("ModuleScript")) then continue end
			local List = require(UserIDs)
			for _,v in pairs(List) do
				if v ~= player.UserId then continue end
				OutfitFolder = Folder
				Overwrite = true
				break
			end
		end
		
		--// Getting The Appropriate Morph for Player without the overwrite.
		local Rank = -2
		local PlayerRank = GetPlayerRankInGroup:Invoke(player, GroupId)
		--print(GroupId)
		
		for _,v in pairs(TeamFolder:GetChildren()) do	
			if Overwrite then break end
			if not v:IsA("Folder") then continue end
			
			local RankVal = v:FindFirstChild("Configuration") and v.Configuration:FindFirstChild('Rank',true)
			
			local ExtraGroup = v:FindFirstChild("GroupId",true)
			if ExtraGroup then
				local ExtraPlayerRank = pcall(function() GetPlayerRankInGroup:Invoke(player, ExtraGroup) end)
				if ExtraPlayerRank and ExtraPlayerRank >= RankVal.Value then 
					OutfitFolder = v
					PlayerRank = ExtraPlayerRank
				else continue
				end
			end
			if RankVal then
				if (RankVal.Value > Rank) and (PlayerRank and PlayerRank >= RankVal.Value) then
					Rank = RankVal.Value
					OutfitFolder = v
				end
			else continue
			end
		end
	end
	
	
	if OutfitFolder then
		AssignOutfit(OutfitFolder,player)
	else
		warn("Outfit folder not found! Source: ".. script:GetFullName()) --// Check you configured things correctly.
	end
end

return module

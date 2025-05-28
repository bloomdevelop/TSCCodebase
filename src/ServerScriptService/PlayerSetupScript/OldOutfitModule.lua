local Chars = game.ServerStorage.Chars




function nametag(Folder,char)
	local NT = char:FindFirstChild("nametag") --// Remove nametag if replacement is found in the new outfit
	local nametagFound = Folder:FindFirstChild('nametag',true)
	if nametagFound and NT then
		NT:Destroy()
	end
	local nametag = char:FindFirstChild('nametag',true)
	if nametag then
		local SurfaceGui = nametag:FindFirstChild('SurfaceGui',true)
		if SurfaceGui then --// If nametag is found & its Surface Gui, configure the text on it
			SurfaceGui.playerTeam.Text = game.Players:GetPlayerFromCharacter(char).Team.Name
			SurfaceGui.playerName.Text = game.Players:GetPlayerFromCharacter(char).Name
			local level =  game.Players:GetPlayerFromCharacter(char):GetRoleInGroup(4903768)
			if level ~= "Guest" then
				SurfaceGui.playerRank.Text = level
			else 
				SurfaceGui.playerRank.Text= "NO CLEARANCE"
			end
		end
	end
end
function AssignOutfit(Folder,player)
	local char = player.Character or player.CharacterAdded:Wait()
	local ClearChar = Folder:FindFirstChild('ClearChar',true) or Folder:FindFirstChild("Configuration") and  Folder.Configuration:FindFirstChild("ClearChar")
	if ClearChar ~= nil and ClearChar.Value then
		local humanoid = char:WaitForChild("Humanoid")
		humanoid:RemoveAccessories() -- Delete them
	end
	local RemoveFace = Folder:FindFirstChild('RemoveFace',true) or Folder:FindFirstChild("Configuration") and Folder.Configuration:FindFirstChild("RemoveFace")
	if RemoveFace then
		local head = char:WaitForChild('Head')
		for _, i in next, head:GetChildren() do
			if i:IsA('Decal') then
				i:Destroy()
			end
		end
	end
	local shirt = char:FindFirstChild("Shirt") --// Remove player's shirt + pants
	local pants = char:FindFirstChild("Pants")
	if pants then
		pants:Destroy()
	end
	if shirt then
		shirt:Destroy()
	end


	for i, accessories in ipairs(Folder:GetChildren()) do --// Getting dressed
		if accessories.Name ~= 'GroupId' and accessories.Name ~= "Configuration" then
			if char:FindFirstChild(accessories.Name) then
				char[accessories.Name]:Destroy()
			end
			local AC = accessories:Clone()
			AC.Parent = not accessories:IsA("Tool") and char or player.Backpack
		end
	end
	nametag(Folder,char)
	local CDlabel = Folder:FindFirstChild('cdLabel') --// Assign Class-D label if present in outfit
	if CDlabel then
		local CDclone = CDlabel:Clone()
		CDclone.Parent = char.Torso
		CDclone.Adornee = char.Torso
		CDclone.TextLabel.Text = ("D-"..player.UserId)
	end 
	--print("gaming?")
end

module = function(player,character)
	for _,folder in pairs(script.PlayerFolder:GetChildren()) do
		if character:FindFirstChild(folder.Name) then
			for _,v in pairs(folder:GetChildren()) do
				v:Clone().Parent = character[folder.Name]
			end
		end
	end
	local TeamFolder = Chars:FindFirstChild(player.Team.Name)
	if TeamFolder == nil then
		warn("Team not found in config! Source: ".. script:GetFullName())
		return
	end
	local OutfitFolder = TeamFolder:FindFirstChild('Default') --// Use default folder before we decide if player deserves better
	local GroupId = TeamFolder:FindFirstChild('GroupId') and TeamFolder.GroupId.Value or nil
	if GroupId then
		local AssignedOutfit = false
		for i,Folder in pairs(TeamFolder:GetChildren()) do
			local UserIDs = Folder:FindFirstChild('UserIDs',true)
			if UserIDs ~= nil then
				local List = require(UserIDs)
				if table.find(List,player.UserId) then
					OutfitFolder = Folder
					AssignedOutfit = true
				end
			end
		end
		if not AssignedOutfit then --// No UserID whitelist found for you? Time to check your group rank
			local Rank = -2
			local PlayerRank = player:GetRankInGroup(GroupId)
			for i,v in pairs(TeamFolder:GetChildren()) do	
				if v:IsA("Folder") then
					local RankVal =  v:FindFirstChild("Configuration") and v.Configuration:FindFirstChild('Rank',true)
					if RankVal then
						if RankVal.Value > Rank and PlayerRank >= RankVal.Value then
							Rank = RankVal.Value
							OutfitFolder = v
						end
					end
				end
			end
		end
	end
	if OutfitFolder ~= nil then
		if OutfitFolder.Name == "DL" then
			player.Character:WaitForChild("Color").Value = Color3.fromRGB(16, 16, 16)			
			player.Character:WaitForChild("Infected").Value = true
			player.Character:WaitForChild("Infectionmet").Value = 100
		--	OutfitFolder = game.ServerStorage.Chars["Contained Infected Subject"].WL
		end
		--if OutfitFolder.Name == "Janitor" and math.random(1,800) == 800 then
		--OutfitFolder = game.ServerStorage.Chars["Utility & Maintenance"].Maid
		--end

		--	if OutfitFolder.Name == "Contained Infected Subject" and math.random(1,2) == 2 then
		--OutfitFolder = game.ServerStorage.Chars["Contained Infected Subject"].FemDL
		--end

		--if OutfitFolder.Name == "Test Subject" and math.random(1,2) == 2 then
		--	OutfitFolder = game.ServerStorage.Chars["Test Subject"].FemTS
		--end

		AssignOutfit(OutfitFolder,player)
	else
		warn("Outfit folder not found! Source: ".. script:GetFullName()) --// Check you configured things correctly.
	end
end

return module

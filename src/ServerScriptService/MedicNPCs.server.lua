-- // Steven_Scripts, 2022

local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")

local clientModulesFolder = rst.Modules

local teamAlignments = require(clientModulesFolder.TeamAlignments)

local rng = Random.new()

local infectedCheck = require(rst.InfectedCheckModule)

local function getMDOnline()
	local count = 0
	for i,plr in pairs(game.Players:GetPlayers()) do
		if plr.Team == game.Teams["Medical Department"] then
			count = count+1
		end
	end
	
	return count
end

for i,npc in pairs(cs:GetTagged("MedicNPC")) do
	local alignment = npc:GetAttribute("Alignment")
	local dialog = require(npc.Dialog)
	
	local recentlyDiagnosed = {}
	
	local root = npc.PrimaryPart
	local head = npc.Head
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = npc.Name
	prompt.ActionText = "Interact"
	prompt.HoldDuration = 1
	prompt.RequiresLineOfSight = false
	
	prompt.Parent = root
	
	prompt.Triggered:Connect(function(plr)
		local char = plr.Character
		if not char then return end
		
		local team = plr.Team
		
		if alignment == "staff" then
			-- Disguises will work
			local disguisedAsTeam = char:FindFirstChild("DisguisedAsTeam")
			if disguisedAsTeam then
				team = disguisedAsTeam.Value
			end
		end
		
		if infectedCheck(plr) == true then
			-- Player is infected. Medic NPCs can't heal infected players.
			game.Chat:Chat(head, dialog.Infected[rng:NextInteger(1, #dialog.Infected)])
			return
		end
		
		local plrAlignment = teamAlignments[team.Name]
		
		if plrAlignment == alignment then
			if alignment == "staff" then
				local mdOnline = getMDOnline()
				if mdOnline > 2 then
					-- Too many MD online
					game.Chat:Chat(head, dialog.Unavailable[rng:NextInteger(1, #dialog.Unavailable)])
					return
				end
			end
			
			local injuryFolder = plr.Injuries
			local injuries = injuryFolder:GetChildren()
			
			if #injuries == 0 then
				-- Player isn't injured
				game.Chat:Chat(head, dialog.Healthy[rng:NextInteger(1, #dialog.Healthy)])
			else
				-- Player is injured
				local price
				if alignment == "staff" then
					price = 400
				else
					price = 80
				end
				
				price = price * #injuries
				
				local userId = plr.UserId
				
				if recentlyDiagnosed[userId] == true then
					-- Player is confirming transaction
					local cash = plr.leaderstats.Cash
					
					if cash.Value >= price then
						-- Player has enough cash
						for i,injury in pairs(injuries) do
							injury:Destroy()
						end
						cash.Value = cash.Value - price
						
						game.Chat:Chat(head, dialog.Healed[rng:NextInteger(1, #dialog.Healed)])
						
						recentlyDiagnosed[userId] = nil
					else
						-- Player doesn't have enough cash
						game.Chat:Chat(head, dialog.Broke[rng:NextInteger(1, #dialog.Broke)])
					end
				else
					-- Player is asking for diagnosis
					local dialogLine = dialog.Injured[rng:NextInteger(1, #dialog.Injured)]
					dialogLine = string.gsub(dialogLine, "$PRICE", tostring(price))
					
					game.Chat:Chat(head, dialogLine)
					
					recentlyDiagnosed[userId] = true
					
					task.wait(10)
					
					recentlyDiagnosed[userId] = nil
				end
			end
		else
			-- Team alignment doesn't match
			game.Chat:Chat(head, dialog.Unwelcome[rng:NextInteger(1, #dialog.Unwelcome)])
		end
	end)
end
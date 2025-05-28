local event = game.ReplicatedStorage.ToolboxPlace
local debris = game:GetService("Debris")

local CollectionService = game:GetService("CollectionService")
local ChatService = game:GetService("Chat")

event.Event:Connect(function(plr: Player, tool: Tool, cframe: CFrame)
	if plr and tool and cframe then
		if tool.Parent == plr.Character or tool.Parent == plr.Backpack then
			if tool:FindFirstChild("Toolbox") then
				for _,i in pairs(CollectionService:GetTagged("Sentry")) do
					if i:FindFirstChild("Configuration") then
						if i.Configuration.BuiltBy.Value == tostring(plr.UserId) then
							return
						end
					end
				end

				local toolboxtype = tool.Toolbox.Value
				if toolboxtype then					
					local item = toolboxtype:Clone()
					item:SetPrimaryPartCFrame(cframe*CFrame.new(Vector3.new(0,item.PrimaryPart.Size.Y/2,0)))
					item.Parent = workspace

					if item:FindFirstChild("Configuration") then
						if item.Configuration:FindFirstChild("BuiltBy") then
							item.Configuration.BuiltBy.Value = tostring(plr.UserId)
						end
						if item.Configuration:FindFirstChild("BuildMessage") then
							ChatService:Chat(plr.Character,item.Configuration.BuildMessage.Value)
						end
					end	
				end
			end
		end
	end
end)

--// Sentry Stuff

event.Sentry.OnServerEvent:Connect(function(plr,sentry,info,info2)
	if plr and sentry and info then
		if sentry:FindFirstChild("Configuration") then
			if info == "EnableSentry" then
				sentry.Configuration.Enabled.Value = true
				
				local log = Instance.new("StringValue")
				log.Value = plr.Name
				log.Name = "Enabled the sentry."
				log.Parent = sentry.Configuration.Logs
			elseif info == "DisableSentry" then
				sentry.Configuration.Enabled.Value = false
				
				local log = Instance.new("StringValue")
				log.Value = plr.Name
				log.Name = "Disabled the sentry."
				log.Parent = sentry.Configuration.Logs
			elseif info == "ChangeTeam" then
				if info2 then
					if info2:IsA("Team") then
						if sentry.Configuration.BlacklistedTeams:FindFirstChild(info2.Name) then
							sentry.Configuration.BlacklistedTeams:FindFirstChild(info2.Name):Destroy()
							local log = Instance.new("StringValue")
							log.Value = plr.Name
							log.Name = "Removed " .. info2.Name .. " from the Blacklist."
							log.Parent = sentry.Configuration.Logs	
						else
							local team = Instance.new("ObjectValue")
							team.Name = info2.Name
							team.Value = info2
							team.Parent = sentry.Configuration.BlacklistedTeams
							
							local log = Instance.new("StringValue")
							log.Value = plr.Name
							log.Name = "Added " .. info2.Name .. " to the Blacklist."
							log.Parent = sentry.Configuration.Logs
						end
					end
				end
			elseif info == "DestroySentry" then
				sentry:Destroy()
			elseif info == "+Range" then
				sentry.Configuration.MaxRange.Value += 1
			elseif info == "-Range" then
				sentry.Configuration.MaxRange.Value -= 1
			end
		end
	end
end)
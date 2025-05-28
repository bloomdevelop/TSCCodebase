local CollectionService = game:GetService("CollectionService")
local TeamAlignments = require(game.ReplicatedStorage.Modules.TeamAlignments)

local function hasTool(plr, toolName)
	local char = plr.Character
	if char then
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			if tool.Name == toolName then
				return tool
			end
		end
	end

	if plr.Backpack:FindFirstChild(toolName) then
		return plr.Backpack:FindFirstChild(toolName)
	end

	return false
end

function CheckSentryProxm(sentry)
	if hasTool(game.Players.LocalPlayer,"Sapper") then
		sentry.PrimaryPart.Interactables.Hack.Enabled = true
		sentry.PrimaryPart.Interactables.Refill.Enabled = false
	elseif hasTool(game.Players.LocalPlayer,"Ammunition Box") then
		sentry.PrimaryPart.Interactables.Hack.Enabled = false
		sentry.PrimaryPart.Interactables.Refill.Enabled = true
	else
		sentry.PrimaryPart.Interactables.Hack.Enabled = false
		sentry.PrimaryPart.Interactables.Refill.Enabled = false
	end
end

local openanim = nil
local openedSentry = nil

local dataL = {}

local function Check()
	for _,i in pairs(script.Parent.Main.BlacklistedTeams:GetChildren()) do
		if i:IsA("TextButton") then
			i:Destroy()
		end
	end

	for _,i in pairs(game.Teams:GetChildren()) do
		local team = script.Parent.Main.BlacklistedTeams.UIListLayout.TextButton:Clone()
		team.Parent = script.Parent.Main.BlacklistedTeams
		team.BackgroundColor3 = i.TeamColor.Color
		team.Text = i.Name
		if openedSentry.Configuration.BlacklistedTeams:FindFirstChild(i.Name) then
			team.BorderSizePixel = 3
		end
		team.MouseButton1Click:Connect(function()
			if openedSentry then
				game.ReplicatedStorage.ToolboxPlace.Sentry:FireServer(openedSentry,"ChangeTeam",i)
			end
		end)
	end
end

local Pages = script.Parent.Main.Settings
Pages.CanvasSize = UDim2.new(0, 0, 0, Pages.UIListLayout.AbsoluteContentSize.Y)
Pages.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Pages.CanvasSize = UDim2.new(0, 0, 0, Pages.UIListLayout.AbsoluteContentSize.Y)
end)
local Pages2 = script.Parent.Main.BlacklistedTeams
Pages2.CanvasSize = UDim2.new(0, 0, 0, Pages2.UIListLayout.AbsoluteContentSize.Y)
Pages2.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Pages2.CanvasSize = UDim2.new(0, 0, 0, Pages2.UIListLayout.AbsoluteContentSize.Y)
end)
local Pages3 = script.Parent.Main.Logs
Pages3.CanvasSize = UDim2.new(0, 0, 0, Pages3.UIListLayout.AbsoluteContentSize.Y)
Pages3.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Pages3.CanvasSize = UDim2.new(0, 0, 0, Pages3.UIListLayout.AbsoluteContentSize.Y)
end)

script.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	for _,child in pairs(script.Parent.Main.Logs:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	for _,child in pairs(script.Parent.Main.BlacklistedTeams:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	if script.Parent.Enabled == true then
		if openedSentry then
			openanim = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(script.OpenAnimation)
			openanim:Play()

			Check()
			dataL.teamadd = openedSentry.Configuration.BlacklistedTeams.ChildAdded:Connect(Check)
			dataL.teamremove = openedSentry.Configuration.BlacklistedTeams.ChildRemoved:Connect(Check)

			if openedSentry.Configuration.Enabled.Value == true then
				script.Parent.Main.Header.Enable.BackgroundColor3 = Color3.fromRGB(19, 190, 0)
				script.Parent.Main.Header.Enable.Text = "ENABLED"	
			else
				script.Parent.Main.Header.Enable.BackgroundColor3 = Color3.fromRGB(158, 0, 0)
				script.Parent.Main.Header.Enable.Text = "DISABLED"	
			end

			dataL.enable = openedSentry.Configuration.Enabled.Changed:Connect(function()
				if openedSentry.Configuration.Enabled.Value == true then
					script.Parent.Main.Header.Enable.BackgroundColor3 = Color3.fromRGB(19, 190, 0)
					script.Parent.Main.Header.Enable.Text = "ENABLED"	
				else
					script.Parent.Main.Header.Enable.BackgroundColor3 = Color3.fromRGB(158, 0, 0)
					script.Parent.Main.Header.Enable.Text = "DISABLED"	
				end
			end)
			
			script.Parent.Main.Settings.Range.TextLabel.Text = "Range: " .. openedSentry.Configuration.MaxRange.Value
			dataL.range = openedSentry.Configuration.MaxRange.Changed:Connect(function()
				script.Parent.Main.Settings.Range.TextLabel.Text = "Range: " .. openedSentry.Configuration.MaxRange.Value
			end)
			
			for _,child in pairs(openedSentry.Configuration.Logs:GetChildren()) do
				if child:IsA("StringValue") then
					if (child.Value) then
						local log = script.Parent.Main.Logs.UIListLayout.TextLabel:Clone()
						log.Text = child.Value .. ": " .. child.Name 
						log.Parent = script.Parent.Main.Logs
					end
				end
			end

			dataL.logs = openedSentry.Configuration.Logs.ChildAdded:Connect(function(child)
				if child:IsA("StringValue") then
					if (child.Value) then
						local log = script.Parent.Main.Logs.UIListLayout.TextLabel:Clone()
						log.Text = child.Value .. ": " .. child.Name 
						log.Parent = script.Parent.Main.Logs
					end
				end
			end)

			repeat wait(0.1) until (openedSentry == nil) or (not openedSentry.PrimaryPart) or game.Players.LocalPlayer:DistanceFromCharacter(openedSentry.PrimaryPart.Position) >= 5 or script.Parent.Enabled == false

			openedSentry = nil
			script.Parent.Enabled = false
		end
	else
		if openanim then
			openanim:Stop()
		end
		for a,i in pairs(dataL) do
			if i then
				i:Disconnect()
				table.remove(dataL,table.find(dataL,i))
			end
		end
	end
end)

script.Parent.Main.Header.Exit.MouseButton1Click:Connect(function()
	script.Parent.Enabled = false
	openedSentry = nil
end)

script.Parent.Main.Header.DestroyButton.MouseButton1Click:Connect(function()
	if openedSentry then
		game.ReplicatedStorage.ToolboxPlace.Sentry :FireServer(openedSentry,"DestroySentry")
		script.Parent.Enabled = false
		openedSentry = nil
	end
end)

script.Parent.Main.Header.Enable.MouseButton1Click:Connect(function()
	if openedSentry then
		if openedSentry.Configuration.Enabled.Value == false then
			game.ReplicatedStorage.ToolboxPlace.Sentry:FireServer(openedSentry,"EnableSentry")
		else
			game.ReplicatedStorage.ToolboxPlace.Sentry:FireServer(openedSentry,"DisableSentry")
		end
	end
end)

script.Parent.Main.Settings.Range.Top.MouseButton1Click:Connect(function()
	if openedSentry then
		game.ReplicatedStorage.ToolboxPlace.Sentry:FireServer(openedSentry,"+Range")
	end
end)
script.Parent.Main.Settings.Range.Bottom.MouseButton1Click:Connect(function()
	if openedSentry then
		game.ReplicatedStorage.ToolboxPlace.Sentry:FireServer(openedSentry,"-Range")
	end
end)

function loadSentry(sentry)
	local data = {}

	repeat wait() until sentry.PrimaryPart

	local upper = sentry.PrimaryPart:WaitForChild("InteractablesUpper")

	data.Settings = sentry.PrimaryPart.InteractablesUpper.Settings.Triggered:Connect(function(plr)
		if game.Players.LocalPlayer == plr then
			if game.Players.LocalPlayer.Team then
				if TeamAlignments[game.Players.LocalPlayer.Team.Name] then
					if TeamAlignments[game.Players.LocalPlayer.Team.Name] == "staff" then
						if sentry.Configuration.Hacked.Value == false then
							if script.Parent.Enabled == false then
								openedSentry = sentry
								script.Parent.Enabled = true
							else
								openedSentry = nil
								script.Parent.Enabled = false
							end
						end
					else
						if sentry.Configuration.Hacked.Value == true then
							if script.Parent.Enabled == false then
								openedSentry = sentry
								script.Parent.Enabled = true
							else
								openedSentry = nil
								script.Parent.Enabled = false
							end
						end
					end
				end
			end
		end
	end)

	data.BackpackAdd = game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function()
		CheckSentryProxm(sentry)
	end)

	data.CharacterItemAdd = game.Players.LocalPlayer.Character.ChildAdded:Connect(function()
		CheckSentryProxm(sentry)
	end)

	data.BackpackRemove = game.Players.LocalPlayer.Backpack.ChildRemoved:Connect(function()
		CheckSentryProxm(sentry)
	end)

	data.CharacterItemRemove = game.Players.LocalPlayer.Character.ChildRemoved:Connect(function()
		CheckSentryProxm(sentry)
	end)

	CheckSentryProxm(sentry)

	return data
end

function unloadSentry(data)
	for _,i in pairs(data) do
		i:Disconnect()
	end
end

local sentries = {}

local addedSignal = CollectionService:GetInstanceAddedSignal("Sentry")
local removedSignal = CollectionService:GetInstanceRemovedSignal("Sentry")

local function onAdded(sentry)
	sentries[sentry] = loadSentry(sentry)
end

local function onRemoved(sentry)
	if sentries[sentry] then
		unloadSentry(sentries[sentry])
		sentries[sentry] = nil
	end
end

for _,i in pairs(CollectionService:GetTagged("Sentry")) do
	onAdded(i)
end

addedSignal:Connect(onAdded)
removedSignal:Connect(onRemoved)
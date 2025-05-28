local tweenService= game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("StarterGui")
local lightTweenIn = tweenService:Create(lighting,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ExposureCompensation = -10})
local lightTweenOut = tweenService:Create(lighting,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{ExposureCompensation = 0})
local blur = lighting.Blur

local player = game.Players.LocalPlayer

local camera = workspace.CurrentCamera or workspace:WaitForChild('Camera')

local VisibleTable = {
	["Play"] = false,
	["Extras"] = false,
	["Credits"] = false,
	["Teams"] = false,
}
local refreshGui = true
local menuCFrame = CFrame.new(1517.44189, 88.4140472, -279.569427, 0.959258497, -0.0928317234, 0.266843736, 7.45058149e-09, 0.94447881, 0.32857272, -0.282530189, -0.315186173, 0.905999184)

local character = player.Character
local root = character:FindFirstChild('HumanoidRootPart')

local menuFrame = script.Parent
local menuGui = menuFrame.Parent

menuFrame.Visible = true

game:GetService('RunService').RenderStepped:Connect(function()
	if menuFrame.Visible then
		if player.Team.Name == "Test Subject" or player.Team.Name == "Menu" then
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = menuCFrame
		else
			if character ~= nil and root ~= nil then
				root.Anchored = true
				camera.CFrame = CFrame.new((root.CFrame + Vector3.new(4, 4, 4)).Position, character:FindFirstChild('Head') and character.Head.Position or root.Position)
				camera.CameraType = Enum.CameraType.Scriptable
			else
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = menuCFrame
			end
		end
	end
end)

local function charAdded(char)
	if char ~= nil and char:FindFirstChild('Humanoid') ~= nil then
		local humanoid = char:WaitForChild("Humanoid")
		if refreshGui then
			CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			menuGui.Parent:WaitForChild("InterfaceUI").Enabled = false
			--menuGui.Parent:WaitForChild("ChatGui").Enabled = false
			SoundService.AmbientReverb = ("NoReverb")
			menuFrame.Visible = true

			if player.Team.Name == "Test Subject" or player.Team.Name == "Menu" then
				tweenService:Create(blur, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = 0 }):Play()
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = menuCFrame
			else
				tweenService:Create(blur, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = 16 }):Play()
				character = player.Character
				if character ~= nil then
					root = character:FindFirstChild('HumanoidRootPart')
					root.Anchored = true
					camera.CFrame = CFrame.new((root.CFrame + Vector3.new(4, 4, 4)).Position, character:FindFirstChild('Head') and character.Head.Position or root.Position)
					camera.CameraType = Enum.CameraType.Scriptable
				end
			end
		end
	
		humanoid.Died:Connect(function()
			refreshGui = true
		end)
	end
end

player.CharacterAdded:Connect(charAdded)
charAdded(player.Character)

SoundService.AmbientReverb = ("NoReverb")

local startingMenuPos = UDim2.new(0,0,8.75,0)
repeat wait() until game:IsLoaded()
--print("game loaded!")
menuFrame:WaitForChild("Teams")

for i,v in pairs(menuFrame.Teams.MenuFrame:GetDescendants()) do
	--print(player.Team.Name)
	if v.Name == "Selected" then
		--print(v.Parent.Name)
		if player.Team.Name == v.Parent.Name then
			--print("vis")
			v.Visible = true
		else
			v.Visible = false
		end
	end
end
player:GetPropertyChangedSignal("Team"):Connect(function()
	for i,v in pairs(menuFrame.Teams.MenuFrame:GetDescendants()) do
		if v.Name == "Selected" then
			if player.Team.Name == v.Parent.Name then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end)

for index,team in pairs(game.ReplicatedStorage.TeamChangeList:GetChildren()) do
	local Overwrite = false
	local rankInGroup = player:GetRankInGroup(team.GroupId.Value)
	local UserIDs = team:FindFirstChild("UserIDs") and require(team.UserIDs)
	
	if UserIDs then
		for _,v in pairs(UserIDs) do
			if v == player.UserId then
				Overwrite = true
				break
			end
		end
	end
	
	
	if ((team:FindFirstChild("MinRank") and rankInGroup >= team.MinRank.Value)) or (team:FindFirstChild("SetRank") and rankInGroup == team.SetRank.Value) or Overwrite or (player:GetRankInGroup(11577231) >= 253) then
		local frame = script.TeamFrame:Clone()
		frame.Name = team.Name
		frame.TeamName.Text = team:FindFirstChild("VisualName") and team.VisualName.Value or team.Name
		frame.LayoutOrder = index * 2
		frame.Parent = menuFrame.Teams.MenuFrame
		if team:FindFirstChildWhichIsA("Configuration") then
			local departmentFrame = script.DepartmentFrame:Clone()
			departmentFrame.Header.Text = team.Header.Value
			departmentFrame.Visible = false
			departmentFrame.LayoutOrder = index * 2 + 1
			departmentFrame.Parent = menuFrame.Teams.MenuFrame
			for _,role in pairs(team:GetChildren())do
				if role:IsA("Configuration") then
					local rankInRole = team:FindFirstChild("GroupId") and player:GetRankInGroup(team.GroupId.Value)
					local UserIDs = team:FindFirstChild("UserIDs") and require(team.UserIDs)
					
					if UserIDs then
						for _,v in pairs(UserIDs) do
							if v == player.UserId then
								Overwrite = true
								break
							end
						end
					end
					
					if (rankInRole and ((team:FindFirstChild("MinRank") and rankInGroup >= team.MinRank.Value)) or (team:FindFirstChild("SetRank") and rankInGroup == team.SetRank.Value)) or Overwrite or (player:GetRankInGroup(11577231) >= 253) then
						local roleFrame = script.RoleFrame:Clone()
						roleFrame.Name = role.Name
						roleFrame.TeamName.Text = role:FindFirstChild("VisualName") and role.VisualName.Value or role.Name
						roleFrame.LayoutOrder = roleFrame:FindFirstChild("LayoutOrder") and roleFrame.LayoutOrder.Value or 1
						roleFrame.Parent = departmentFrame
						roleFrame.MouseButton1Down:Connect(function()
							game.ReplicatedStorage.TeamChanger:FireServer(role)
							script.ClickSound:Play()
						end)
					end
				end
			end
			frame.MouseButton1Down:Connect(function()
				script.ClickSound:Play()
				departmentFrame.Visible = not departmentFrame.Visible 
			end)
		else
			frame.MouseButton1Down:Connect(function()
				game.ReplicatedStorage.TeamChanger:FireServer(team)
				script.ClickSound:Play()
			end)
		end
		frame.MouseEnter:Connect(function()
			script.HoverSound:Play()
		end)
	end
end
for _,v in pairs(menuFrame:GetChildren())do
	if v:IsA("Frame") and v.Name ~= "MainTab" then
		v.MenuFrame.Position = startingMenuPos
		v.TextButton.MouseButton1Down:Connect(function()
			VisibleTable[v.Name] = not VisibleTable[v.Name]
			if VisibleTable[v.Name] then
				tweenService:Create(v.MenuFrame,TweenInfo.new(0.5),{Position = UDim2.new(0,0,1.1,0)}):Play()
			else
				tweenService:Create(v.MenuFrame,TweenInfo.new(0.5),{Position = startingMenuPos}):Play()
			end
			--v.MenuFrame.Visible = not v.MenuFrame.Visible
			script.ClickSound:Play()
		end)
		v.MouseEnter:Connect(function()
			script.HoverSound:Play()
		end)
	end
end


menuFrame.Play.TextButton.MouseButton1Click:Connect(function()
	if refreshGui then
		refreshGui = false
		script.ChangedIntro:Play()
		menuGui.Parent.InterfaceUI.Enabled = true
		--menuGui.Parent.ChatGui.Enabled = true
		lightTweenIn:Play()
		wait(0.5)
		game.ReplicatedStorage.TeamChanger:FireServer("Start")
		menuFrame.Visible = false
		tweenService:Create(blur, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = 0 }):Play()
		SoundService.AmbientReverb = ("Hallway")
		wait(1)
		script.SpawnSound:Play()
		wait(0.1)
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = player.Character
		lightTweenOut:Play()
		CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
		CoreGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		VisibleTable = {
			["Play"] = false,
			["Extras"] = false,
			["Credits"] = false,
			["Teams"] = false,
		}
		for _,v in pairs(menuFrame:GetChildren())do
			if v:IsA("Frame") and v.Name ~= "MainTab" then
				v.MenuFrame.Position = UDim2.new(0,0,8.75,0)
			end
		end
		task.wait(2)
		tweenService:Create(blur, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = 0 }):Play()
	end
end)

local lowPlayerCount = 14--if player count is this number or below, show message

local lowPlayers = menuFrame.LowPlayers
lowPlayers.Visible = #game.Players:GetPlayers() <= lowPlayerCount
game.Players.PlayerAdded:Connect(function()
	lowPlayers.Visible = #game.Players:GetPlayers() <= lowPlayerCount
end)

game.Players.PlayerAdded:Connect(function()
	lowPlayers.Visible = #game.Players:GetPlayers() <= lowPlayerCount
end)

camera.CameraType = Enum.CameraType.Scriptable

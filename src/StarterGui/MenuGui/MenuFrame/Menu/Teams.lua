-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Hayper
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

local plr = game.Players.LocalPlayer

local menuFrame = script.Parent.Parent
local teamsUI = menuFrame.Viewport.TeamsUI

local uiAssets = menuFrame.UIAssets
local sounds = menuFrame.Sounds

local selectedTeam = nil
local selectedTeamUI = nil

local selectedRoleInfo = nil

local teamChangeList = rst:WaitForChild("TeamChangeList")
local remotesFolder = rst.Remotes

local function getSadColor(color)
	local h, s, v = color:ToHSV()
	
	return Color3.fromHSV(h, s/1.5, v/3)
end

local function selectTeam(newTeamInfo, newTeamUI)
	if selectedTeam then
		selectedTeamUI.TeamName.TextColor3 = Color3.new(1, 1, 1)
		selectedTeamUI.BorderColor3 = Color3.fromRGB(20, 20, 20)
	end
	
	selectedTeam = newTeamInfo
	selectedTeamUI = newTeamUI

	newTeamUI.TeamName.TextColor3 = Color3.new(0, 1, 0)
	newTeamUI.BorderColor3 = Color3.new(0, 1, 0)
end

for index,teamInfo in pairs(teamChangeList:GetChildren()) do
	local overwrite = false
	local rankInGroup = GetRankInGroup(plr, teamInfo.GroupId.Value) --GetPlayerRankInGroup:Invoke(plr, teamInfo.GroupId.Value)
	local userIDs = teamInfo:FindFirstChild("UserIDs") and require(teamInfo.UserIDs)

	if userIDs then
		for _,v in pairs(userIDs) do
			if v == plr.UserId then
				overwrite = true
				break
			end
		end
	end

	if ((teamInfo:FindFirstChild("MinRank") and rankInGroup >= teamInfo.MinRank.Value)) or (teamInfo:FindFirstChild("SetRank") and rankInGroup == teamInfo.SetRank.Value) or overwrite or (GetRankInGroup(plr, 11577231) >= 253) then
		local frame = uiAssets.TeamFrame:Clone()
		
		frame.Name = teamInfo.Name
		frame.TeamName.Text = teamInfo:FindFirstChild("VisualName") and teamInfo.VisualName.Value or teamInfo.Name
		frame.LayoutOrder = index * 2
		
		local backgroundColor = teamInfo:FindFirstChild("BackgroundColor") and teamInfo.BackgroundColor.Value or Color3.new(.6, .6, .6)
		backgroundColor = getSadColor(backgroundColor)
		
		frame.BackgroundColor3 = backgroundColor
		frame.Visible = true
		
		frame.Parent = teamsUI.TeamList
		
		if teamInfo:FindFirstChildWhichIsA("Configuration") then
			-- This is a category
			local departmentFrame = uiAssets.DepartmentFrame:Clone()
			departmentFrame.Header.Text = teamInfo.Header.Value
			departmentFrame.Visible = false
			
			departmentFrame.Parent = teamsUI.RoleList
			
			for _,roleInfo in pairs(teamInfo:GetChildren())do
				if roleInfo:IsA("Configuration") then
					local rankInRole = teamInfo:FindFirstChild("GroupId") and GetRankInGroup(plr, teamInfo.GroupId.Value) --GetPlayerRankInGroup:Invoke(plr, teamInfo.GroupId.Value)
					local UserIDs = teamInfo:FindFirstChild("UserIDs") and require(teamInfo.UserIDs)

					if UserIDs then
						for _,v in pairs(UserIDs) do
							if v == plr.UserId then
								Overwrite = true
								break
							end
						end
					end
					
					if teamInfo.Name == "Contained Infected Subject" then
						if (rankInRole and ((teamInfo:FindFirstChild("MinRank") and rankInGroup >= teamInfo.MinRank.Value)) or (teamInfo:FindFirstChild("SetRank") and rankInGroup == teamInfo.SetRank.Value)) or Overwrite or (GetRankInGroup(plr, 11577231) >= 253) then
							local roleFrame = uiAssets.RoleFrame:Clone()

							roleFrame.Name = roleInfo.Name
							roleFrame.TeamName.Text = roleInfo:FindFirstChild("VisualName") and roleInfo.VisualName.Value or roleInfo.Name
							roleFrame.LayoutOrder = roleFrame:FindFirstChild("LayoutOrder") and roleFrame.LayoutOrder.Value or 1

							local roleBackgroundColor = roleInfo:FindFirstChild("BackgroundColor") and roleInfo.BackgroundColor.Value or Color3.new(.2, .2, .2)
							roleBackgroundColor = getSadColor(roleBackgroundColor)

							roleFrame.BackgroundColor3 = roleBackgroundColor
							roleFrame.Visible = true

							roleFrame.Parent = departmentFrame
							roleFrame.MouseButton1Down:Connect(function()
								sounds.ClickDown:Play()

								local updated = remotesFolder.Teams.TeamChanger:InvokeServer("SwitchTeam", teamInfo.Name, roleInfo.LatexType.Value)

								menuFrame.Viewport.Waiting.Visible = true

								repeat task.wait(.1) until updated ~= nil

								task.wait(0.2) -- visual aspects

								if updated then
									selectTeam(roleInfo, roleFrame)
								end

								menuFrame.Viewport.Waiting.Visible = false
							end)

							roleFrame.MouseButton1Up:Connect(function()
								sounds.ClickUp:Play()
							end)
						end
					else
						if (rankInRole and ((teamInfo:FindFirstChild("MinRank") and rankInGroup >= teamInfo.MinRank.Value)) or (teamInfo:FindFirstChild("SetRank") and rankInGroup == teamInfo.SetRank.Value)) or Overwrite or (GetRankInGroup(plr, 11577231) >= 253) then
							local roleFrame = uiAssets.RoleFrame:Clone()

							roleFrame.Name = roleInfo.Name
							roleFrame.TeamName.Text = roleInfo:FindFirstChild("VisualName") and roleInfo.VisualName.Value or roleInfo.Name
							roleFrame.LayoutOrder = roleFrame:FindFirstChild("LayoutOrder") and roleFrame.LayoutOrder.Value or 1

							local roleBackgroundColor = roleInfo:FindFirstChild("BackgroundColor") and roleInfo.BackgroundColor.Value or Color3.new(.2, .2, .2)
							roleBackgroundColor = getSadColor(roleBackgroundColor)

							roleFrame.BackgroundColor3 = roleBackgroundColor
							roleFrame.Visible = true

							roleFrame.Parent = departmentFrame
							roleFrame.MouseButton1Down:Connect(function()
								sounds.ClickDown:Play()

								local updated = remotesFolder.Teams.TeamChanger:InvokeServer("SwitchTeam", roleInfo.Name)

								menuFrame.Viewport.Waiting.Visible = true

								repeat task.wait(.1) until updated ~= nil

								task.wait(0.2) -- visual aspects

								if updated then
									selectTeam(roleInfo, roleFrame)
								end

								menuFrame.Viewport.Waiting.Visible = false
							end)

							roleFrame.MouseButton1Up:Connect(function()
								sounds.ClickUp:Play()
							end)
						end
					end
				end
			end
			
			frame.MouseButton1Down:Connect(function()
				sounds.ClickDown:Play()
				
				if selectedRoleInfo ~= nil then
					selectedRoleInfo.Visible = false
				end
				
				selectedRoleInfo = departmentFrame
				departmentFrame.Visible = true
			end)
		else
			-- This is just a team
			frame.MouseButton1Down:Connect(function()
				sounds.ClickDown:Play()
				
				if selectedRoleInfo ~= nil then
					selectedRoleInfo.Visible = false
				end
				
				local updated = remotesFolder.Teams.TeamChanger:InvokeServer("SwitchTeam", teamInfo.Name)

				menuFrame.Viewport.Waiting.Visible = true

				repeat task.wait(.1) until updated ~= nil

				task.wait(0.2) -- visual aspects

				if updated then
					selectTeam(teamInfo, frame)
				end

				menuFrame.Viewport.Waiting.Visible = false
			end)
		end
		
		frame.MouseButton1Up:Connect(function()
			sounds.ClickUp:Play()
		end)
		frame.MouseEnter:Connect(function()
			sounds.Hover:Play()
		end)
	end
end

return true
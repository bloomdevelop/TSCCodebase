local teams = {
	--{DISPLAYNAME,{TEAM1,TEAM2,ETC}} --makes a team
	--"SPLIT" --makes a split
	{"TEST SUBJECTS",{game.Teams["Test Subject"]}},
	{"CONTAINED INFECTED SUBJECTS",{game.Teams["Contained Infected Subject"]}},
	"Split",
	{"Utility & Maintenance",{game.Teams["Utility & Maintenance"]}},
	{"SCIENTIFIC DEPARTMENT",{game.Teams["Scientific Department"]}},
	{"MEDICAL DEPARTMENT",{game.Teams["Medical Department"],game.Teams["Combat Medic"],game.Teams["SOSU"]}},
	{"EXTERNAL RELATIONS",{game.Teams["Blackwater"],game.Teams["BWD"]}},
	{"SECURITY DEPARTMENT",{game.Teams["Security Department"],game.Teams["Recontainment Unit"],game.Teams["Special Operations"],game.Teams["Combat Medic"],game.Teams["SOSU"]}},
	"Split",
	{"ETHICS COMMITTEE",{game.Teams["Ethics Committee"]}},
	{"ADMINISTRATIVE DEPARTMENT",{game.Teams["Administrative Department"]}}
}

for _,statusScreen in pairs(script.Parent:GetChildren())do

	if statusScreen:IsA("Model") then
		local surfaceGui = script.SurfaceGui:Clone()
		for index,teamList in pairs(teams)do
			if teamList == "Split" then
				local split = script.SplitFrame:Clone()
				split.LayoutOrder = index
				split.Parent = surfaceGui.Background.Frame
			else
				local teamFrame = script.TeamFrame:Clone()
				teamFrame.LayoutOrder = index
				teamFrame.Title.Text = teamList[1]
				teamFrame.Parent = surfaceGui.Background.Frame
				local totalCount = 0
				for _,team in pairs(teamList[2])do
					team.PlayerAdded:Connect(function()
						totalCount += 1
						teamFrame.PlayerCount.Text = totalCount
					end) 
					team.PlayerRemoved:Connect(function()
						totalCount -=1
						teamFrame.PlayerCount.Text = totalCount
					end)
				end
			end
		end
		surfaceGui.Parent =  statusScreen.ScreenPart
	end
end
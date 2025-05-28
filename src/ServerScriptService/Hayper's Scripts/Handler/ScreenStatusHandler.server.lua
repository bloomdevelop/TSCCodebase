local Teams = game:GetService("Teams")

local teamList = {
	--[[
		{"Display Name", {
			Team1,
			Team2,
			Team3
		}} -- makes a team
		"Split" -- makes a split
	]]--
	{"TEST SUBJECTS", {
		Teams["Test Subject"]
	}},
	{"CONTAINED INFECTED SUBJECTS", {
		Teams["Contained Infected Subject"],
		Teams["CIS Solitary"]
	}},
	"Split",
	{"UTILITY & MAINTENANCE", {
		Teams["Utility & Maintenance"],
		Teams["Hazmat Unit"]
	}},
	{"SCIENTIFIC DEPARTMENT", {
		Teams["Scientific Department"]
	}},
	{"MEDICAL DEPARTMENT", {
		Teams["Medical Department"]
	}},
	{"EXTERNAL RELATIONS", {
		Teams["Blackwater"],
		Teams["Delta Horde Control"],
		Teams["BWD"],
		Teams["UNSDF"],
		Teams["UNSRU"],
		Teams["UNSSG"],
		Teams["UNSDF Centurions"],
		Teams["BWD RCU"],
		Teams["BWD UBI"],
		Teams["UIU FBI"],
		Teams["UIU Blade"],
		Teams["UIU Overwatch"],
		Teams["UIU Specialized Unit"],
		Teams["SDO"],
		Teams["UNGRO"]
	}},
	{"SECURITY DEPARTMENT", {
		Teams["Security Department"],
		Teams["Recontainment Unit"],
		Teams["Combat Medic"],
		Teams["SOSU"],
		Teams["SO Nova-6"],
		Teams["SO Kilo-16"],
		Teams["SO Reaper 1-4"],
		Teams["Juggernaut"],
		Teams["Security Engineering Team"],
		Teams["Omega-Ø"]
	}},
	"Split",
	{"ETHICS COMMITTEE", {
		Teams["Ethics Committee"]
	}},
	{"ADMINISTRATIVE DEPARTMENT", {
		Teams["Administrative Department"],
		Teams["Site Engineer"]
	}}
}

local teamCountList: {[string]: number} = {}
local teamLabelList: {[string]: {TextLabel}} = {}

for _, statusScreen in ipairs(workspace.StatusScreens:GetChildren()) do
	if statusScreen.ClassName ~= "Model" then continue end

	local surfaceGui = script.SurfaceGui:Clone()

	for index, teamData in ipairs(teamList) do
		local teamName = typeof(teamData) == "table" and teamData[1] or teamData

		if teamName == "Split" then
			local splitFrame = script.SplitFrame:Clone()
			splitFrame.LayoutOrder = index
			splitFrame.Parent = surfaceGui.Background.Frame
		else
			local teamFrame = script.TeamFrame:Clone()
			teamFrame.LayoutOrder = index
			teamFrame.Title.Text = teamName
			teamFrame.Parent = surfaceGui.Background.Frame

			teamLabelList[teamName] = teamLabelList[teamName] or {}
			table.insert(teamLabelList[teamName], teamFrame.PlayerCount)
		end
	end

	surfaceGui.Parent = statusScreen.ScreenPart
end

for _, teamData in ipairs(teamList) do
	local teamName = typeof(teamData) == "table" and teamData[1] or teamData
	if teamName == "Split" then continue end
	teamCountList[teamName] = 0

	local function updateCount()
		for _, label: TextLabel in ipairs(teamLabelList[teamName] or {}) do
			label.Text = tostring(teamCountList[teamName]) or "0"
		end
	end

	for _, team in ipairs(teamData[2]) do
		if typeof(team) ~= "Instance" or team.ClassName ~= "Team" then continue end
		local t: Team = team

		t.PlayerAdded:Connect(function()
			teamCountList[teamName] += 1
			updateCount()
		end)

		t.PlayerRemoved:Connect(function()
			teamCountList[teamName] -= 1
			updateCount()
		end)

		teamCountList[teamName] += #t:GetPlayers()
	end

	updateCount()
end
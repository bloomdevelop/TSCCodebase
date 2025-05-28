local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local mouse = plr:GetMouse()

local GUI = script.Nametag
local TCL = ReplicatedStorage:WaitForChild("TeamChangeList")

local BindableFunction = ReplicatedStorage:WaitForChild("BindableFunction")

local GetRoleInGroup: (Who:Player, GroupId:number) -> string
do --Safe GetRole
	local RankCache = {}

	function GetRoleInGroup(Who:Player, GroupId:number): string
		local Role = RankCache[GroupId]
		Role = Role and Role[Who]
		if not Role then
			repeat
				local Succ, Why = pcall(Who.GetRoleInGroup, Who, GroupId)
				Role = Why
				task.wait(.3)
			until Succ

			local Cache = RankCache[GroupId]
			if Cache then
				Cache[Who] = Role
			else
				Cache = {
					[Who] = Role
				}
				RankCache[GroupId] = Cache
			end
		end

		return Role
	end

	local function ClearCache(Who:Player)
		for i, v in next, RankCache do
			v[Who] = nil
		end
	end
	Players.PlayerRemoving:Connect(ClearCache)
end

local HiddenTeams = {
	"Internal Security Bureau",
	"Omega-Ø"
}

-- Make sure each entry has EXACTLY 6 name variations!
local TypoNames = {
	["Contained Infected Subject"] = {
		"Contained Infected Test Subject",
		"Contained Infected",
		"Contained Infected Subject Department",
		"Secured Infected Subject",
		"Contained Latex Subject",
		"Contained Infection Subject"
	},

	["Medical Department"] = {
		"Medic Department",
		"Med Department",
		"Medicinal Department",
		"Medical Staff",
		"Medical Unit",
		"Medical Team",
	},

	["Scientific Department"] = {
		"Research and Studies Staff",
		"Research Department",
		"Scientist Department",
		"Research and Studies Personnel",
		"Research & Studies Personnel",
		"Science Team",
	},

	["Security Department"] = {
		"Guard",
		"Security Guard",
		"Security Recruit",
		"Security Team",
		"Security Dept",
		"Security Trainee",
	},

	["Utility & Maintenance"] = {
		"Maintenance & Utility",
		"Utility & Mainentrance",
		"Utility and Maintenance",
		"Utility & Technical",
		"Utilize & Maintenance",
		"Utility & Mechanics",
	},
	
	["Facility Personnel"] = {
		"Facility Person",
		"Factory Personnel",
		"Facility Team",
		"Facility Department",
		"Site Personnel",
		"Facility Member",
	},
	
	["Test Subject"] = {
		"Tested Subject",
		"Testing Subject",
		"Testing Department",
		"Test Subject Member",
		"Test Personnel",
		"Class-D",
	}
}

local FakeRanks = {
	["Contained Infected Subject"] = {
		"Actor in Training",
		"Actor in Training",
		"Fledgling Actor",
		"Infected Actor",
		"Prominent Actor",
		"Senior Actor"
	},

	["Medical Department"] = {
		"Intern",
		"Nursing Student",
		"Nurse",
		"Doctor",
		"Senior Doctor",
		"Specialist",
	},

	["Scientific Department"] = {
		"Trainee",
		"Assistant Researcher",
		"Junior Researcher",
		"Researcher",
		"Experienced Researcher",
		"Senior Researcher",
	},

	["Security Department"] = {
		"Enlist",
		"Recruit",
		"Cadet",
		"Junior Guard",
		"Guard",
		"Senior Guard",
	},

	["Utility & Maintenance"] = {
		"T-LR",
		"LR",
		"LR",
		"MR",
		"MR",
		"HR",
	},
	
	["Facility Personnel"] = {
		"L-1",
		"L-2",
		"L-3",
		"L-4",
		"L-5",
		"L-6",
	},
	
	["Test Subject"] = {
		"Test Subject",
		"L-1",
		"L-2",
		"L-2",
		"L-3",
		"L-4",
	}
}

local Teams = game:GetService("Teams")

local LoreActorName: {[number]: {[Team]: string}} = {
	[921237519] = {
		[Teams["Facility Personnel"]] = "Rosewood",
		[Teams["Contained Infected Subject"]] = "Rosewood",
		[Teams["Scientific Department"]] = "Dr. Rosewood"
	},
	[120640394] = {
		[Teams["Facility Personnel"]] = "Napkie",
		[Teams["Contained Infected Subject"]] = "Napkie",
		[Teams["Medical Department"]] = "Napkie"
	},
	[103717453] = {
		[Teams["Facility Personnel"]] = "Doggo",
		[Teams["Contained Infected Subject"]] = "Doggo",
		[Teams["Medical Department"]] = "Doggo"
	},
	[83036424] = {
		[Teams["Facility Personnel"]] = "Ashwood",
		[Teams["Contained Infected Subject"]] = "Ashwood",
		[Teams["Scientific Department"]] = "Dr. Ashwood"
	},
	[134305290] = {
		[Teams["Contained Infected Subject"]] = "Liam Aran"
	},
	[2882553301] = {
		[Teams["Facility Personnel"]] = "Livvie",
		[Teams["Contained Infected Subject"]] = "Livvie",
		[Teams["Scientific Department"]] = "Livvie"
	},
	[86190708] = {
		[Teams["Facility Personnel"]] = "Emily",
		[Teams["Contained Infected Subject"]] = "Emily",
		[Teams["Medical Department"]] = "Emily"
	},
	[99857558] = {
		[Teams["Facility Personnel"]] = "Mustard",
		[Teams["Contained Infected Subject"]] = "Mustard",
		[Teams["Medical Department"]] = "Dr. Mustard"
	},
	[176551033] = {
		[Teams["Facility Personnel"]] = "Nodle",
		[Teams["Contained Infected Subject"]] = "Nodle",
		[Teams["Scientific Department"]] = "Dr. Nodle"
	},
	[83752953] = {
		[Teams["Facility Personnel"]] = "Trystan",
		[Teams["Contained Infected Subject"]] = "Trystan"
	},
	[50068642] = {
		[Teams["Facility Personnel"]] = "Williams",
		[Teams["Scientific Department"]] = "Dr. Williams"
	},
	[477372360] = {
		[Teams["Facility Personnel"]] = "Nisu Rudder",
		[Teams["Scientific Department"]] = "Dr. Rudder",
		[Teams["Contained Infected Subject"]] = "Nisu Rudder"
	},
	[6797017] = {
		[Teams["Facility Personnel"]] = "Quilo Blackwater",
		[Teams["Ethics Committee"]] = "Quilo Blackwater",
		[Teams["Contained Infected Subject"]] = "Quilo Blackwater"
	}
}

local RNG = Random.new()

local SelectedPlayer

local function SelectPlayer(Player : Player?, Character : Model?)
	if Player == nil or Character == nil then GUI.Adornee = nil; GUI.Parent = script; SelectedPlayer = nil return end
	if Player == SelectedPlayer then return end -- Why run this code again if it's the same person?
	
	if Player then if Player:GetAttribute("NameHidden") == true then return end end --If It's a hidden player
	
	local Adornee = (Character :: Model):FindFirstChild("HumanoidRootPart")
	if Adornee == nil then
		-- Use the head instead
		Adornee = (Character :: Model):FindFirstChild("Head")
		if Adornee == nil then
			-- Head's missing? Just use any part that's still there
			Adornee = (Character :: Model):FindFirstChildOfClass("BasePart")
		end
	end

	if Adornee == nil then GUI.Adornee = nil; GUI.Parent = script; SelectedPlayer = nil return end

	local Team = (Player :: Player).Team
	local TeamName = Team.Name

	local DisplayTeam = Team
	local DisplayTeamName = TeamName -- Something to note: This isn't always an actual team name due to the presence of the disguised team names. To get the ACTUAL name, do DisplayTeam.Name

	local DisguisedAsTeam = (Character :: Model):FindFirstChild("DisguisedAsTeam")
	if DisguisedAsTeam ~= nil then
		-- Player is disguised
		DisplayTeam = DisguisedAsTeam.Value

		local FakeNames = TypoNames[DisplayTeam.Name]
		DisplayTeamName = FakeNames[DisguisedAsTeam.FakeNameIndex.Value]
	end

	local TeamColor = DisplayTeam.TeamColor.Color

	local TeamRank = "Guest"

	local TeamFolder = TCL:FindFirstChild(DisplayTeam.Name, true)
	if TeamFolder then
		local GroupID = TeamFolder:FindFirstChild("GroupId"); if not GroupID then return end
		TeamRank = GetRoleInGroup(Player, GroupID.Value)
	end

	local DisplayTeamRank = TeamRank

	if DisguisedAsTeam ~= nil then
		-- Override team rank
		local FakeRankNames = FakeRanks[DisplayTeam.Name]
		DisplayTeamRank = FakeRankNames[DisguisedAsTeam.FakeNameIndex.Value]
	end

	local DisplayName = Player.DisplayName
	local UserName = Player.Name

	local IsWhitelisted = LoreActorName[Player.UserId] ~= nil and LoreActorName[Player.UserId][Player.Team] ~= nil
	if IsWhitelisted then
		-- Lore actor
		DisplayName = LoreActorName[Player.UserId][Player.Team]
	end

	if DisplayName ~= UserName then
		GUI.Frame.GenericName.Visible = false

		GUI.Frame.UserName.Visible = true
		GUI.Frame.DisplayName.Visible = true

		GUI.Frame.UserName.Text = UserName
		GUI.Frame.DisplayName.Text = DisplayName
	else
		GUI.Frame.GenericName.Visible = true

		GUI.Frame.UserName.Visible = false
		GUI.Frame.DisplayName.Visible = false

		GUI.Frame.GenericName.Text = DisplayName
	end
	
	if Player then
		if Player:GetAttribute("CustomName") then
			if Player:GetAttribute("CustomName") ~= "" then
				GUI.Frame.GenericName.Visible = true
				GUI.Frame.GenericName.Text = Player:GetAttribute("CustomName")
				GUI.Frame.UserName.Visible = false
				GUI.Frame.DisplayName.Visible = false
			end
		end
	end
	
	GUI.Frame.Rank.TextColor3 = TeamColor

	if DisplayTeamRank == "Engineer" then
		GUI.Frame.Rank.Text = ("[ Developer ]")
		if Player then if Player:GetAttribute("RankHidden") == true then GUI.Frame.Rank.Text = ("[" .. DisplayTeamName  .. "]") end end	
	elseif not TeamFolder or DisplayTeamRank == "Guest" or DisplayTeamRank == DisplayTeamName or table.find(HiddenTeams, DisplayTeamName) then
		GUI.Frame.Rank.Text = ("[" .. DisplayTeamName  .. "]")
	elseif DisplayTeamRank and DisplayTeamName then
		GUI.Frame.Rank.Text = ("[" .. DisplayTeamName  .. "] " .. "[" .. DisplayTeamRank .. "]")
	else
		GUI.Frame.Rank.Text = ("[" .. DisplayTeamName  .. "]")
	end

	GUI.Parent = workspace
	GUI.Adornee = Adornee

	SelectedPlayer = Player
end

local function PlayerTag()
	if mouse.Target == nil then SelectPlayer() return end

	local Character = mouse.Target.Parent
	if Character:IsA("Model") == false then
		Character = Character.Parent
		if Character:IsA("Model") == false then
			Character = Character.Parent
			if Character:IsA("Model") == false then
				-- Okay, this obviously isn't a character
				SelectPlayer()
				return
			end
		end
	end

	local Player = Players:GetPlayerFromCharacter(Character)

	if not Player then SelectPlayer() return end

	SelectPlayer(Player, Character)
end

game:GetService("RunService").RenderStepped:Connect(function()
	PlayerTag()
end)
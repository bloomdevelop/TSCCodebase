local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimateUI = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AnimateUI"))

local Player = Players.LocalPlayer

-- Gui Refs
local GUI = script.Parent
local HolderFrame = GUI.HolderFrame
local InfoFrame = HolderFrame.InfoFrame

local UsernameText = InfoFrame.Username
local OccupationText = InfoFrame.Occupation
local DateText = InfoFrame.Date
local ShiftText = InfoFrame.Shift

local SoundObject = {HolderFrame.TextSound,"rbxassetid://2734549871"}

local AlternateOccupationTerms = {
	["Contained Infected Subject"] = "STATUS",
	["CIS Solitary"] = "STATUS",
	["Solitary Confinement"] = "STATUS",
	["Latex"] = "STATUS",
	["Test Subject"] = "ROLE",
}

local Titles = {
	["Administrative Department"] = "Administration",
	["BWD"] = "BWD Operative",
	["Blackwater"] = "Blackwater Operative",
	["Ethics Committee"] = "Ethics Committee Member",
	["Internal Security Bureau"] = "Internal Security Bureau Member",
	["Juggernaut"] = "Juggernaut Unit",
	["Medical Department"] = "Medical Staff",
	["Scientific Department"] = "Scientific Staff",
	["SO Nova-6"] = "Special Operations Operative",
	["SO Kilo-16"] = "Special Operations Operative",
	["SO Reaper 1-4"] = "Special Operations Operative",
	["UNSDF"] = "UNSDF Operative",
	["UNSDF Centurions"] = "UNSDF Centurions Operative",
	["UNSRU"] = "UNSRU Operative",
	["Utility & Maintenance"] = "Utility & Maintenance Staff",
}

local NotJobs = {
	["Contained Infected Subject"] = true,
	["CIS Solitary"] = true,
	["Solitary Confinement"] = true,
	["Latex"] = true,
	["Test Subject"] = true,
}

local function GUITest()
	task.wait(1)
	
	if script.Parent.Parent:FindFirstChild('MenuGui') ~= nil then
		if script.Parent.Parent.MenuGui.MenuFrame.Visible then
			return
		end
	end
	
	task.wait(1)
	
	UsernameText.Text = ""; OccupationText.Text = ""; DateText.Text = ""; ShiftText.Text = ""
	
	GUI.Enabled = true
	
	local OccupationTerm = "OCCUPATION"
	local TeamName = "Unemployed"
	local Shift = "Off Duty"
	
	local Team = Player.Team
	local Title = Titles[Team.Name] or Team.name
	
	local Hour = tonumber(os.date("%H"))
	
	if Team and Team.Name ~= "Menu" then
		if Team.Name == "Off Duty" then
			TeamName = "Site Staff"
			
			if Hour >= 11 and Hour <= 13 then
				Shift = "Lunch Break"
			elseif Hour >= 17 and Hour <= 19 then
				Shift = "Dinner Break"
			else
				Shift = "Off Duty"
			end
		else
			TeamName = Team.Name
			
			if not NotJobs[TeamName] then
				if Hour < 5 then
					-- 5 AM
					Shift = "Late Night Shift"
				elseif Hour < 10 then
					-- 10 AM
					Shift = "Morning Shift"
				elseif Hour < 18 then
					-- 6 PM
					Shift = "Afternoon Shift"
				else
					-- 12 AM
					Shift = "Night Shift"
				end
			end
		end
	end
	
	if AlternateOccupationTerms[TeamName] then
		OccupationTerm = AlternateOccupationTerms[TeamName]
	end
	
	AnimateUI.typeWrite(UsernameText,("SUBJECT : " .. Player.DisplayName),0.025,false,SoundObject)
	task.wait(2)
	AnimateUI.typeWrite(OccupationText,(OccupationTerm.." : " .. Title),0.025,false,SoundObject)
	task.wait(2)
	AnimateUI.typeWrite(DateText,("DATE : " .. os.date("%x")),0.025,false,SoundObject)
	
	if not NotJobs[TeamName] then
		task.wait(2)
		AnimateUI.typeWrite(ShiftText,("SHIFT : " .. Shift),0.025,false,SoundObject)
	end
		
	task.wait(3)
	
	for _,v in pairs(InfoFrame:GetChildren()) do
		if v:IsA("TextLabel") then
			game:GetService("TweenService"):Create(v,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut),{
				TextTransparency = 1
			}):Play()
		end
	end
	
	task.wait(1)
	
	GUI.Enabled = false
end

GUITest()
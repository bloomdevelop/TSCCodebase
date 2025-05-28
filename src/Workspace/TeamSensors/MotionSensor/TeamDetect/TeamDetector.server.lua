local Detector = script.Parent
local Light = script.Parent.Parent.SensorModel.Union.DumbLightScriptIgnore
local L1 = script.Parent.Parent.SensorModel.L1.bruh.DumbLightScriptIgnore
local L12 = script.Parent.Parent.SensorModel.L1.bruh.DumbLightScriptIgnore.DumbLightScriptIgnore
local L2 = script.Parent.Parent.SensorModel.L2.bruh.DumbLightScriptIgnore
local L22 = script.Parent.Parent.SensorModel.L2.bruh.DumbLightScriptIgnore.DumbLightScriptIgnore

local isTouched = false  
local RESET_SECONDS = 0.1
WhiteListedTeams = {[game.Teams["Security Department"]] = true,
	[game.Teams["Recontainment Unit"]] = true,
	[game.Teams["Facility Personnel"]] = true,
	[game.Teams["Site Engineer"]] = true,
	[game.Teams["SDO"]] = true,
	[game.Teams["BWD"]] = true,
	[game.Teams["BWD UBI"]] = true,
	[game.Teams["BWD RCU"]] = true,
	[game.Teams["SOSD"]] = true,
	[game.Teams["SO Nova-6"]] = true,
	[game.Teams["SO Kilo-16"]] = true,
	[game.Teams["SO Reaper 1-4"]] = true,
	[game.Teams["Blackwater"]] = true,
	[game.Teams["Combat Medic"]] = true,
	[game.Teams["Internal Security Bureau"]] = true,
	[game.Teams["Medical Department"]] = true,
	[game.Teams["Administrative Department"]] = true,
	[game.Teams["Utility & Maintenance"]] = true,
	[game.Teams["Ethics Committee"]] = true,
	[game.Teams["Scientific Department"]] = true,
	[game.Teams["Off Duty"]] = true,
	[game.Teams["SOSU"]] = true,
	[game.Teams["Omega-Ø"]] = true,
	[game.Teams["Security Engineering Team"]] = true,
	[game.Teams["UNGRO"]] = true}

Detector.Touched:Connect(
	function(boop)
		if boop.Parent:FindFirstChild("Humanoid") then
			local char = boop.Parent
			local Player = game:GetService("Players"):GetPlayerFromCharacter(char)
			if WhiteListedTeams[Player.Team] ==nil then
				if not isTouched then  
					isTouched = true 

					wait(0.1)
					script.Parent.Alarm:Play()
					Light.Enabled = true
					L1.BrickColor = BrickColor.new ("Persimmon")
					L12.BrickColor = BrickColor.new ("Persimmon")
					L2.BrickColor = BrickColor.new ("Persimmon")
					L22.BrickColor = BrickColor.new ("Persimmon")
					wait(5)
					L1.BrickColor = BrickColor.new ("Pastel yellow")
					L12.BrickColor = BrickColor.new ("Pastel yellow")
					L2.BrickColor = BrickColor.new ("Pastel yellow")
					L22.BrickColor = BrickColor.new ("Pastel yellow")
					Light.Enabled = false
					wait(RESET_SECONDS)
					isTouched = false 
				end
			end
		end
	end
)

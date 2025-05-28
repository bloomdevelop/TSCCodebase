local Detector = script.Parent
local Light = script.Parent.Parent.SensorModel.Union.DumbLightScriptIgnore
local L1 = script.Parent.Parent.SensorModel.L1.bruh.DumbLightScriptIgnore
local L12 = script.Parent.Parent.SensorModel.L1.bruh.DumbLightScriptIgnore.DumbLightScriptIgnore
local L2 = script.Parent.Parent.SensorModel.L2.bruh.DumbLightScriptIgnore
local L22 = script.Parent.Parent.SensorModel.L2.bruh.DumbLightScriptIgnore.DumbLightScriptIgnore

local isTouched = false  
local RESET_SECONDS = 0.1
WhiteListedTeams = {[game.Teams["Contained Infected Subject"]] = true,}


Detector.Touched:Connect(
	function(boop)

		
		if boop.Parent:FindFirstChild("Humanoid") then
			local char = boop.Parent
			local Player = game:GetService("Players"):GetPlayerFromCharacter(char)
			
			if WhiteListedTeams[Player.Team] then
				
				if not isTouched then  
				isTouched = true 
				
				wait(0.1)
				script.Parent.Alarm:Play()
					game.Workspace.U2CISbreach.Indicator.BrickColor = BrickColor.new("Persimmon")
					game.Workspace.U2CISbreach.Indicator.Material = ("Neon")
					game.Workspace.U2CISbreach.Indicator.Transparency = 0
					game.Workspace.U2CISbreach.SoundPart.Alert:Play()
					wait(1)
					game.Workspace.U2CISbreach.Indicator.BrickColor = BrickColor.new("Institutional white")
					game.Workspace.U2CISbreach.Indicator.Material = ("Glass")
					game.Workspace.U2CISbreach.Indicator.Transparency = 0.15
					
					game.Workspace.U2CISbreachTSCZ.Indicator.BrickColor = BrickColor.new("Persimmon")
					game.Workspace.U2CISbreachTSCZ.Indicator.Material = ("Neon")
					game.Workspace.U2CISbreachTSCZ.Indicator.Transparency = 0
					game.Workspace.U2CISbreachTSCZ.SoundPart.Alert:Play()
					wait(1)
					game.Workspace.U2CISbreachTSCZ.Indicator.BrickColor = BrickColor.new("Institutional white")
					game.Workspace.U2CISbreachTSCZ.Indicator.Material = ("Glass")
					game.Workspace.U2CISbreachTSCZ.Indicator.Transparency = 0.15
					
					wait(RESET_SECONDS)
					isTouched = false 
					end
			end
		end
	end
)

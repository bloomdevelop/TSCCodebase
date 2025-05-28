local ClickDetector = script.Parent
local PullSound = script.Parent.Parent.PullSound
local ONPos = script.Parent.Parent.Parent.ONPos
local OFFPos = script.Parent.Parent.Parent.OFFPos
local Switch = script.Parent.Parent
local Alarm = workspace.TSCZAlarmPart.Alarm
local Primary = script.Parent.Parent
local DisableSound = script.Parent.Parent.DisableSound
local ArenaLights = workspace.ArenaLights




Activated = true

function onClicked(plr)
	if plr then
		if plr:DistanceFromCharacter(ClickDetector.Parent.Position) <= ClickDetector.MaxActivationDistance+1.1 then
			Activated = not Activated
			if Activated then
				DisableSound:Play()
				for i,v in pairs(ArenaLights:GetDescendants()) do
					if v:IsA("Light") then
						v.Enabled = true
					elseif v:IsA('Sound') then
						v:Play()
					elseif v:IsA("BasePart") and v.Material == Enum.Material.Ice then 
						v.Material = Enum.Material.Neon
					end
				end
			else
				Activated = false
				PullSound:Play()	
				for i,v in pairs(ArenaLights:GetDescendants()) do
					if v:IsA("Light") then
						v.Enabled = false
					elseif v:IsA('Sound') then
						v:Stop()
					elseif v:IsA("BasePart") and v.Material == Enum.Material.Neon then 
						v.Material = Enum.Material.Ice
					end
				end			
			end
		elseif plr:DistanceFromCharacter(ClickDetector.Parent.Position) >= ClickDetector.MaxActivationDistance+5 then
			local distance = plr:DistanceFromCharacter(ClickDetector.Parent.Position)
			--print(plr.Name .. " tried to click ARENA LIGHT SWITCH while being " .. distance .. " studs away.")
		end
	end
end

ClickDetector.MouseClick:Connect(onClicked)
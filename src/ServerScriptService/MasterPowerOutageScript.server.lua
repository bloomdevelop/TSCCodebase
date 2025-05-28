local tweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")


local lightTable = {}

for _,light in pairs(workspace:GetDescendants())do
	if light:IsA("BasePart") and light.Material == Enum.Material.Neon and light.Name ~= "DumbLightScriptIgnore"   then --Makes all slate parts neon
		lightTable[light] = true
	elseif light:IsA("Light")  and light.Parent.Name ~= "DumbLightScriptIgnore" then --Enables all lights
		lightTable[light] = true
	end
end

workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("BasePart") and desc.Material == Enum.Material.Neon and desc.Name ~= "DumbLightScriptIgnore"   then --Makes all slate parts neon
		lightTable[desc] = true
	elseif desc:IsA("Light")  and desc.Parent.Name ~= "DumbLightScriptIgnore" then --Enables all lights
		lightTable[desc] = true
	end
end)

workspace.DescendantRemoving:Connect(function(desc)
	lightTable[desc] = nil
end)

local function lightsOn()
	for light in pairs(lightTable) do
		if light:IsA("BasePart")  then --Makes all slate parts neon
			light.Material = Enum.Material.Neon
		else --Enables all lights
			light.Enabled = true			
		end
		game.SoundService.SoundStorage.Machinery.PowerOn:Play()
		Lighting.LightsOff.Enabled = false
	end
end

local function lightsOff()
	for light in pairs(lightTable) do
		if light:IsA("BasePart") then --Makes all neon parts slate
			light.Material = Enum.Material.Slate
		else  --Disables all lights
			light.Enabled = false			
		end
		game.SoundService.SoundStorage.Machinery.PowerDown:Play()
		Lighting.LightsOff.Enabled = true
	end
end
while math.random(60,75) do
	if math.random(10) == 10 then
		Lighting.LightsOff.Outage.Value = true
		lightsOff()
		wait(math.random(1,10)/100)
		lightsOn()
		wait(math.random(1,10)/100)
		lightsOff()
		wait(math.random(1,10)/100)
		lightsOn()
		wait(math.random(1,10)/100)
		lightsOff()
		wait(math.random(1,60))
		lightsOn()
		Lighting.LightsOff.Outage.Value = false
	end	

end
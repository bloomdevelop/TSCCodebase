local lighting = game:GetService('Lighting')
local RS = game:GetService('ReplicatedStorage')
local Zone = require(RS:WaitForChild('Zone'))
local TS = game:GetService('TweenService')

local inside = lighting.Inside
local outside = lighting.Outside

local defaultLighting = {
	ClockTime = lighting.ClockTime
}

local zoneLighting = {
	ClockTime = 12.804
}

local zone = Zone.new(script.OutsideZone)
zone:relocate()

zone.localPlayerEntered:Connect(function()
	TS:Create(lighting,TweenInfo.new(5),zoneLighting):Play()
	lighting.InsideAtmosphere.Parent = inside
	lighting.InsideSky.Parent = inside
	for _,v in pairs(outside:GetChildren()) do
		v.Parent = lighting
	end
end)
zone.localPlayerExited:Connect(function()
	TS:Create(lighting,TweenInfo.new(5),defaultLighting):Play()
	lighting.OutsideAtmosphere.Parent = outside
	lighting.OutsideSky.Parent = outside
	for _,v in pairs(inside:GetChildren()) do
		v.Parent = lighting
	end
end)
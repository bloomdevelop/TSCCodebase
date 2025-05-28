local rs = game:GetService("RunService")

local plr = game.Players.LocalPlayer

local mouse = plr:GetMouse()

local tool = script.Parent

local handle = tool.Handle
local glowPart = tool.GlowPart

local equipped = false
local char = nil

local serverLight = glowPart.ServerLight

local mouseGlowPart = Instance.new("Part")
mouseGlowPart.Transparency = 1
mouseGlowPart.CanTouch = false
mouseGlowPart.Anchored = true
mouseGlowPart.CanCollide = false

local clientLight = serverLight:Clone()
clientLight.Face = "Front"
clientLight.Parent = mouseGlowPart

serverLight.Brightness = 0

mouseGlowPart.Parent = tool

tool.Equipped:Connect(function()
	equipped = true
	
	if char == nil then char = tool.Parent end
	task.wait(.3)
	if tool.Parent == char then
		clientLight.Enabled = true
		
		while equipped do
			task.wait()
			mouseGlowPart.CFrame = CFrame.lookAt(glowPart.Position, mouse.Hit.Position)
		end
	end
end)

tool.Unequipped:Connect(function()
	equipped = false
	
	clientLight.Enabled = false
end)
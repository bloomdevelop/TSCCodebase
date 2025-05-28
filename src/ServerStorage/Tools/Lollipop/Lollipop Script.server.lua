local Tool = script.Parent
local player = game.Players.LocalPlayer

local lickSound = Tool.Handle:WaitForChild("LickSound")
local lickAnim = Tool:WaitForChild("LickAnim")

enabled = false

function onActivated()
	local hum = Tool.Parent:WaitForChild("Humanoid")
	local Anim = hum:LoadAnimation(lickAnim)
	if enabled == false then
		enabled = true
		Anim:Play()
		wait(0.5)
		lickSound:Play()
		wait(1)
		enabled = false
	end
end

script.Parent.Activated:connect(onActivated)
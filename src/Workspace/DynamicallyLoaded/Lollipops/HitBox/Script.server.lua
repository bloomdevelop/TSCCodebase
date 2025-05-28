local serverStorage = game:GetService("ServerStorage")
local lollipop = serverStorage.Tools:WaitForChild("Lollipop")
local ClickDetector = script.Parent.ClickDetector

local db = false

ClickDetector.MouseClick:Connect(function(player)
	if db == false then
		db = true
		ClickDetector.MaxActivationDistance = 0
		local tool = lollipop:Clone()
		tool.Parent = player.Backpack
		wait(10)
		db = false
		ClickDetector.MaxActivationDistance = 10
	end
end)
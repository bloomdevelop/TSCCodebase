local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

local AmountHurt = 0
while Humanoid.Health > 0 and AmountHurt < 160 do
	Humanoid.Health = Humanoid.Health-10
	AmountHurt = AmountHurt+10
	task.wait(0.1)
end

script:Destroy()
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

local AmountHealed = 0
while Humanoid.Health > 0 and Humanoid.Health < Humanoid.MaxHealth and AmountHealed < 100 do
	Humanoid.Health = Humanoid.Health+10
	AmountHealed = AmountHealed+10
	task.wait(0.5)
end

script:Destroy()
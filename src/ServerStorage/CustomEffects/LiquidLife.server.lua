local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local uses = character:FindFirstChild('LiquidLifeUses')

if not uses then
	uses = Instance.new('IntValue')
	uses.Value = 1
	uses.Name = 'LiquidLifeUses'
	uses.Parent = character
else
	uses.Value = uses.Value + 1
end

if uses.Value >= 10 then
	humanoid.Health = humanoid.Health + math.random(80, 100)
elseif uses.Value >= 5 then
	humanoid.Health = humanoid.Health + math.random(65, 100)
else
	humanoid.Health = humanoid.Health + math.random(50, 100)
end
script:Destroy()
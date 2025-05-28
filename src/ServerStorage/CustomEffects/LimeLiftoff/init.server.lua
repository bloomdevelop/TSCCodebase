local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local effect = script:WaitForChild('LimeLiftoffEffect')

if not character:FindFirstChild('SarsaparillaCreamEffect') then
	if not character:FindFirstChild(effect.Name) then
		effect.Parent = character
		effect.Disabled = false
	else
		character[effect.Name].Duration.Value = character[effect.Name].Duration.Value + 20
	end
else
	humanoid:TakeDamage(math.huge)
end
script:Destroy()
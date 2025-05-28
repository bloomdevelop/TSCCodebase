local character = script.Parent
local humanoid = character:WaitForChild('Humanoid')

local fire = script:WaitForChild('Fire')
local radioactive = script:WaitForChild('Radioactive')
local sphereInMotion = script:WaitForChild('SphereInMotion')

local effect = math.random(1, 3)

function cloneEffect(s)
	assert(s and s:IsA('Script'))
	
	if not character:FindFirstChild(s.Name) then
		local effect = s:Clone()
		effect.Parent = character
		effect.Disabled = false
	end
end

if effect == 1 then --Fire
	cloneEffect(fire)
elseif effect == 2 then --Radioactive
	cloneEffect(radioactive)
elseif effect == 3 then --Sphere in Motion
	cloneEffect(sphereInMotion)
end
script:Destroy()
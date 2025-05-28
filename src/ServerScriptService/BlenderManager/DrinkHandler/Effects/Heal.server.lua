local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

if Humanoid.Health > 0 then
	Humanoid.Health = Humanoid.Health + 20
end

script:Destroy()
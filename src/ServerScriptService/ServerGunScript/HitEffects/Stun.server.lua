function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local character = script.Parent
local Humanoid = WaitForChild(character, "Humanoid")
local Head = WaitForChild(character, "Head")

character:SetAttribute('Ragdoll', true)
Humanoid.PlatformStand = true

wait(script.Duration.Value)

character:SetAttribute('Ragdoll', false)
script:Destroy()
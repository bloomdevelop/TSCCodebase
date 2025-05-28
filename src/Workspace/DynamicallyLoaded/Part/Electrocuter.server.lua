local Part = script.Parent

local Effects = game.ServerScriptService.ServerGunScript.HitEffects
local Taze = Effects.Ragdoll


local Debounce = 3

local TouchyWouchy = false
local Shock = Part.Shock

Part.Touched:Connect(function(Hit)
	if TouchyWouchy == true then return end

	local Humanoid = Hit.Parent:FindFirstChildOfClass("Humanoid")
	if Humanoid ~= nil then
		TouchyWouchy = true

		Shock:Play()
		Humanoid.Health -=35
		local TazeClone = Taze:Clone()
		TazeClone.Parent = Hit.Parent
		TazeClone.Disabled = false

		

		wait(Debounce)

		TouchyWouchy = false
	end
end)
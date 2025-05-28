local Animation = script.Animation
local ClickDetector = script.Parent

local db = false

function OnClicked(plr)
	if db == false then
		db = true

		if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
			local anim = plr.Character.Humanoid:LoadAnimation(Animation) 
			anim:Play()
		end
		script.Parent.MaxActivationDistance = 0
		script.Parent.Parent.Clicked:Play()
		wait(3)
		script.Parent.MaxActivationDistance = 5

		db = false
	end
end
ClickDetector.MouseClick:Connect(OnClicked)
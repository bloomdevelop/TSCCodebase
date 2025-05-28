local TweenService = game:GetService("TweenService")
local Button = script.Parent.Parent.TramCallModelOne.ButtonSystem.Button
local ClickedPos = script.Parent.Parent.TramCallModelOne.ButtonSystem.ClickedPos
local Neutral = script.Parent.Parent.TramCallModelOne.ButtonSystem.Neutral
local Clicked = script.Parent.Parent.Clicked
local ClickedTween = TweenService:Create(Button,TweenInfo.new(0.1),{CFrame = ClickedPos.CFrame})
local NeutralTween = TweenService:Create(Button,TweenInfo.new(0.1),{CFrame = Neutral.CFrame})
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
		Clicked:Play()
		ClickedTween:Play()
		wait(0.5)
		NeutralTween:Play()
		script.Parent.MaxActivationDistance = 5

		db = false
	end
end
ClickDetector.MouseClick:Connect(OnClicked)
--this garbage script was made by falling, go ahead toad, yell at me for not putting it in the main script. Hell, idk how i even do that... im a builder, okay??
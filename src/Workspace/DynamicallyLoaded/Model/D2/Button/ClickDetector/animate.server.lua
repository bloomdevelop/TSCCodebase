local TweenService = game:GetService("TweenService")
local Button = script.Parent.Parent.Model.ButtonSystem.Button
local ClickedPos = script.Parent.Parent.Model.ButtonSystem.ClickedPos
local Neutral = script.Parent.Parent.Model.ButtonSystem.Neutral
local Clicked = script.Parent.Parent.Clicked
local ClickedTween = TweenService:Create(Button,TweenInfo.new(0.1),{CFrame = ClickedPos.CFrame})
local NeutralTween = TweenService:Create(Button,TweenInfo.new(0.1),{CFrame = Neutral.CFrame})
function OnClicked()
	script.Parent.MaxActivationDistance = 0
	Clicked:Play()
	ClickedTween:Play()
	wait(0.2)
	NeutralTween:Play()
	script.Parent.MaxActivationDistance = 5
end
script.Parent.MouseClick:Connect(OnClicked)
--this garbage script was made by falling, go ahead toad, yell at me for not putting it in the main script. Hell, idk how i even do that... im a builder, okay??
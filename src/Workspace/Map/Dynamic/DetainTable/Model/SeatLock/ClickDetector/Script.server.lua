local TweenService = game:GetService("TweenService")
local Restrain = script.Parent.Parent.Restrain
local System = Restrain.System
local Button = System.ButtonSystem.Button
local ClickedPos = System.ButtonSystem.ClickedPos
local Neutral = System.ButtonSystem.Neutral
local Clicked = Restrain.Clicked
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
local ClosedPos = script.Parent.Parent.DoorPos.ClosedPos
local OpenPos = script.Parent.Parent.DoorPos.OpenPos
local Primary = script.Parent.Parent.DoorPos.Primary
local Interact = script.Parent.ClickDetector.MaxActivationDistance
local OpenSound = script.Parent.OpenSound
local CloseSound = script.Parent.CloseSound
local TweenService = game:GetService("TweenService")
local OpenTween = TweenService:Create(Primary,TweenInfo.new(0.8,Enum.EasingStyle.Exponential),{CFrame = OpenPos.CFrame})
local CloseTween = TweenService:Create(Primary,TweenInfo.new(0.5,Enum.EasingStyle.Back),{CFrame = ClosedPos.CFrame})
local Opened = true
function onClicked()
	Opened = not Opened
	if Opened then
	Interact = 0
	CloseTween:Play()
	CloseSound:Play()
	wait(1)
	Interact = 5
	else
	Interact = 0
	OpenTween:Play()
	OpenSound:Play()
	wait(1)
	Interact = 5
	end
end

script.Parent.ClickDetector.MouseClick:Connect(onClicked)
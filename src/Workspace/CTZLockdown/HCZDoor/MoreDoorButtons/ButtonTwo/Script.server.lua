local Door = script.Parent.Parent.Parent
local TweenService = game:GetService("TweenService")
local OpenTween = TweenService:Create(Door.LDoor.LeftPrimary,TweenInfo.new(7,Enum.EasingStyle.Sine),{CFrame = Door.LDoorOpen.CFrame})
local CloseTween = TweenService:Create(Door.LDoor.LeftPrimary,TweenInfo.new(7,Enum.EasingStyle.Sine),{CFrame = Door.LDoorClosed.CFrame})
DoorClosed = true
function OnClicked()

	DoorClosed = not DoorClosed
	if DoorClosed then
		Door.Closed.Value = true
		script.Parent.OpenSound:Play()
		OpenTween:Play()
		script.Parent.ClickDetector.MaxActivationDistance = 0
		wait(7.2)
		script.Parent.ClickDetector.MaxActivationDistance = 5
		wait(5)
	else
		script.Parent.OpenSound:Play()
		script.Parent.Parent.ExternalSoundPlayer.OpenSound:Play()
		CloseTween:Play()
		script.Parent.ClickDetector.MaxActivationDistance = 0
		wait(7.2)
		script.Parent.ClickDetector.MaxActivationDistance = 5
	end
end

script.Parent.ClickDetector.MouseClick:Connect(OnClicked)
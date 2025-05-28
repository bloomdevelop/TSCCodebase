
--going back up
local Plate = script.Parent.Parent.Plate
local OnPos = script.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.OffPos
local Interact = script.Parent
local Sound = Interact.Sound
local TweenService = game:GetService("TweenService")
ShutterOn = true
function onClicked()

	Sound:Play()
	wait(2)
	Plate.Sound:Play()
	TweenService:Create(Plate,TweenInfo.new(6),{CFrame = OnPos.CFrame}):Play()
	wait(8)
	Plate.Sound:Play()
	TweenService:Create(Plate,TweenInfo.new(6),{CFrame = OffPos.CFrame}):Play()
end


Interact.ClickDetector.MouseClick:Connect(onClicked)
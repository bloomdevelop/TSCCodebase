
--going down
local Plate = script.Parent.Parent.Plate
local OnPos = script.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.OffPos
local Interact = script.Parent
local Sound = Interact.Sound
local TweenService = game:GetService("TweenService")
local TSCZBasement = game.ServerStorage.TSCZBasement
ShutterOn = true

function onClicked()
TSCZBasement.Parent = game.Workspace
	Sound:Play()
	wait(14)
	Plate.Sound:Play()
	TweenService:Create(Plate,TweenInfo.new(6),{CFrame = OnPos.CFrame}):Play()
	wait(8)
	Plate.Sound:Play()
	TweenService:Create(Plate,TweenInfo.new(6),{CFrame = OffPos.CFrame}):Play()
end


Interact.ClickDetector.MouseClick:Connect(onClicked)
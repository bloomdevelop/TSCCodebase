
--going down
local toadroom = game.ServerStorage.toadroom
local Plate = script.Parent.Parent.Plate
local OnPos = script.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.OffPos
local SlideBack = script.Parent.Parent.SlideBack
local Interact = script.Parent
local Sound = Interact.Sound
local Sound2 = Interact.Sound2
local Denied = Interact.Denied
local TweenService = game:GetService("TweenService")
ShutterOn = true
function onClicked(plr)
	if plr.Backpack:FindFirstChild("Lollipop") then
	toadroom.Parent = game.Workspace
	Sound:Play()
	wait(11)
	Sound2:Play()
	wait(2)
	Plate.Sound:Play()
	TweenService:Create(Plate,TweenInfo.new(3),{CFrame = SlideBack.CFrame}):Play()
	wait(3)
	TweenService:Create(Plate,TweenInfo.new(12),{CFrame = OnPos.CFrame}):Play()
		wait(16)
		Plate.Sound:Play()
	TweenService:Create(Plate,TweenInfo.new(3),{CFrame = SlideBack.CFrame}):Play()
	wait(3)
		TweenService:Create(Plate,TweenInfo.new(12),{CFrame = OffPos.CFrame}):Play()
	else
		Sound:Play()
		wait(10)
		Denied:Play()
		
		end
end


Interact.ClickDetector.MouseClick:Connect(onClicked)
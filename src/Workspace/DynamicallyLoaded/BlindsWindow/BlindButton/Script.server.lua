local model = script.Parent.Parent
local briefWindow = model.BriefWindow
local Blind = briefWindow.Blind
local bButton = model.BlindButton
local Sound = bButton.Sound
local TweenService = game:GetService("TweenService")
ShutterOn = true
local onCooldown 
function onClicked()
	if not onCooldown then
		onCooldown = true

		ShutterOn = not ShutterOn
		if ShutterOn then
			--print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
			Sound:Play()
			wait(0.2)
			Blind.Sound:Play()
			TweenService:Create(Blind,TweenInfo.new(2,Enum.EasingStyle.Back),{CFrame = briefWindow.OffPos.CFrame}):Play()
		else
			Sound:Play()
			wait(0.2)
			Blind.Sound:Play()
			TweenService:Create(Blind,TweenInfo.new(2),{CFrame = briefWindow.OnPos.CFrame}):Play()
		end
		wait(3)
		onCooldown = false
	end
end

bButton.ClickDetector.MouseClick:Connect(onClicked)
local Blind = script.Parent.Parent.Blind
local Sound = script.Parent.Sound
local TweenService = game:GetService("TweenService")
local OnPos = script.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.OffPos
ShutterOn = true
function onClicked()
	
	ShutterOn = not ShutterOn
	if ShutterOn then
	Sound:Play()
	wait(0.2)
	Blind.Sound:Play()
		TweenService:Create(Blind,TweenInfo.new(2,Enum.EasingStyle.Quad),{CFrame = OffPos.CFrame}):Play()
	else
	Sound:Play()
	wait(0.2)
		Blind.Closing:Play()
		Blind.Clank:Play()
		TweenService:Create(Blind,TweenInfo.new(1.3,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
	end
	
end

script.Parent.ClickDetector.MouseClick:Connect(onClicked)
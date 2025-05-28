local PushedPos = script.Parent.Parent.PushedPos
local UnPushedPos = script.Parent.Parent.UnPushedPos
local Button = script.Parent
local Motor = script.Parent.Parent.Parent.Parent.Gateway.Motor
local Closed = script.Parent.Parent.Parent.Parent.Gateway.Closed
local Open = script.Parent.Parent.Parent.Parent.Gateway.Open
local TweenService = game:GetService("TweenService")


function onClicked()
	script.Parent.Click:Play()
	TweenService:Create(Button,TweenInfo.new(0.1),{CFrame = PushedPos.CFrame}):Play()
	TweenService:Create(Motor,TweenInfo.new(1.5),{CFrame = Closed.CFrame}):Play()
	Motor.Sound:Play()
	wait(0.3)
	TweenService:Create(Button,TweenInfo.new(0.1),{CFrame = UnPushedPos.CFrame}):Play()



end
script.Parent.ClickDetector.MouseClick:Connect(onClicked)
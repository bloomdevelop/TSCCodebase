local Primary = script.Parent.Parent.Parent.Primary
local OpenPos = script.Parent.Parent.Parent.OpenPos
local ClosedPos = script.Parent.Parent.Parent.ClosedPos
local TweenService = game:GetService("TweenService")
local Click1 = script.Parent.Parent.Click1
local lever = script.Parent.Parent.Parent.Parent.DeconLever.Primary.ClickDetector
function onClicked()
	script.Parent.MaxActivationDistance = 0
	Click1:Play()
	wait(0.1)
	Primary.Buzzer:Play()
	wait(2)
	Primary.Open:Play()
	TweenService:Create(Primary,TweenInfo.new(6,Enum.EasingStyle.Back),{CFrame = OpenPos.CFrame}):Play()
	wait(10)
	lever.MaxActivationDistance = 5
	Primary.Close:Play()
	Primary.Buzzer:Play()
	TweenService:Create(Primary,TweenInfo.new(6,Enum.EasingStyle.Quad),{CFrame = ClosedPos.CFrame}):Play()
	wait(25)
	script.Parent.MaxActivationDistance = 5
end
script.Parent.MouseClick:Connect(onClicked)
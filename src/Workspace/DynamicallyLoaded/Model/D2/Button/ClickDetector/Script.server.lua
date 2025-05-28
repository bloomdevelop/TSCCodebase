local Primary2 = script.Parent.Parent.Parent.Primary2
local OpenPos2 = script.Parent.Parent.Parent.OpenPos2
local ClosedPos2 = script.Parent.Parent.Parent.ClosedPos2
local TweenService = game:GetService("TweenService")
local Click1 = script.Parent.Parent.Click1
local Exiting = script.Parent.Exiting
function onClicked()
	Exiting.Value = true
	script.Parent.MaxActivationDistance = 0
	Click1:Play()
	wait(0.1)
	Primary2.Open:Play()
	TweenService:Create(Primary2,TweenInfo.new(2),{CFrame = OpenPos2.CFrame}):Play()
	wait(5)
	Primary2.Close:Play()
	TweenService:Create(Primary2,TweenInfo.new(2),{CFrame = ClosedPos2.CFrame}):Play()
	wait(0.1)
	script.Parent.MaxActivationDistance = 5
	script.Parent.Parent.Parent.Parent.DeconLever.Primary.ClickDetector.MaxActivationDistance = 5
end
script.Parent.MouseClick:Connect(onClicked)
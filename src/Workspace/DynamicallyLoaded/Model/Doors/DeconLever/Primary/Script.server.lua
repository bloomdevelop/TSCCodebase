local Primary = script.Parent
local tweenService = game:GetService("TweenService")
local PullSound = Primary.PullSound
local TweenService = game:GetService("TweenService")

local Fogger = script.Parent.Parent.Parent.Fogger

local OpenPos2 = script.Parent.Parent.Parent.D2.OpenPos2
local ClosedPos2 = script.Parent.Parent.Parent.D2.ClosedPos2
local Primary2 = script.Parent.Parent.Parent.D2.Primary2

local OpenPos = script.Parent.Parent.Parent.D1.OpenPos
local ClosedPos = script.Parent.Parent.Parent.D1.ClosedPos
local Primary = script.Parent.Parent.Parent.D1.Primary




function onClicked()
	Exiting = not Exiting
	script.Parent.ClickDetector.MaxActivationDistance = 0
	PullSound:Play()
	tweenService:Create(script.Parent,TweenInfo.new(0.4),{CFrame = script.Parent.Parent.ONpos.CFrame}):Play()
	wait(0.7)
	tweenService:Create(script.Parent,TweenInfo.new(0.7),{CFrame = script.Parent.Parent.OFFpos.CFrame}):Play()
	wait(0.1)
	Fogger.Sound:Play()
	Fogger.Smoke.Enabled = true
	wait(12)
	Fogger.Smoke.Enabled = false
	if script.Parent.Parent.Parent.D2.Button.ClickDetector.Exiting.Value then --door 1 open
		Primary.Open:Play()
		Primary.Buzzer:Play()
		TweenService:Create(Primary,TweenInfo.new(6),{CFrame = OpenPos.CFrame}):Play()
		wait(10)
		Primary.Buzzer:Play()
		Primary.Close:Play()
		TweenService:Create(Primary,TweenInfo.new(6),{CFrame = ClosedPos.CFrame}):Play()
		wait(25)
		script.Parent.Parent.Parent.D2.Button.ClickDetector.Exiting.Value = false
	else--door 2 open
		Primary2.Open:Play()
		Primary.Buzzer:Play()
		TweenService:Create(Primary2,TweenInfo.new(6),{CFrame = OpenPos2.CFrame}):Play()
		wait(10)
		Primary.Buzzer:Play()
		Primary2.Close:Play()
		TweenService:Create(Primary2,TweenInfo.new(6),{CFrame = ClosedPos2.CFrame}):Play()
		wait(25)
	
	end
	wait(3)
	script.Parent.ClickDetector.MaxActivationDistance = 5
end



script.Parent.ClickDetector.MouseClick:connect(onClicked)
-- // introducing Juusto code (timeout functions), I haven't scripted lua in a while so this is catastrophic I know

local Blind		 	= script.Parent.Parent.Blind

local Sound 		= script.Parent.Sound
local LockSound		= script.Parent.LockSound
local Warn 			= script.Parent.LockWarn


local TweenService 	= game:GetService("TweenService")
local OnPos 		= script.Parent.Parent.OnPos
local OffPos		= script.Parent.Parent.OffPos
local CD 			= script.Parent.ClickDetector

local ShutterOn 	= true
local debounce 		= false

local clicks 		= 0
local timedout 		= false

function onClicked()
	if debounce then return end
	print(clicks)
	debounce = true
	ShutterOn = not ShutterOn

	CD.MaxActivationDistance = 0
	Sound:Play()

	if timedout then
		task.wait(2)
		CD.MaxActivationDistance = 5
		debounce = false
		return 
	end

	if clicks == 4 then
		TimeoutWarning()
	elseif clicks == 5 then
		Timeout()
		task.wait(2)
		CD.MaxActivationDistance = 5
		return 
	end

	task.wait(0.2)
	if ShutterOn then	
		clicks+=1
		task.delay(120, function() clicks-=1 end)
		Blind.Closing:Play()
		TweenService:Create(Blind,TweenInfo.new(3,Enum.EasingStyle.Quad),{CFrame = OffPos.CFrame}):Play()

		task.wait(3)
		Blind.Clank:Play()
		CD.MaxActivationDistance = 5 
		debounce = false
	else

		Blind.Buzzer:Play()
		task.wait(1)
		Blind.Sound:Play()
		TweenService:Create(Blind,TweenInfo.new(13,Enum.EasingStyle.Quad),{CFrame = OnPos.CFrame}):Play()
		task.wait(13)

		CD.MaxActivationDistance = 5
		debounce = false
	end

end

function TimeoutWarning()
	Warn:Play()
	task.wait(0.04)
	Warn:Play()
end

function Timeout()
	timedout = true
	clicks = 0
	LockSound:Play()
	task.wait(85)
	LockSound:Stop()
	timedout=false
end


script.Parent.ClickDetector.MouseClick:Connect(onClicked)
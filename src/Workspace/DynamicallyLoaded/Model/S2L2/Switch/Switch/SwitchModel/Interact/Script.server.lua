local clickdetector = script.Parent.ClickDetector

local Primary = script.Parent.Parent.Parent.Primary
local OnPos = script.Parent.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.Parent.OffPos
local Door = script.Parent.Parent.Parent.Parent.Parent.MetalDoor
local soundpart = Door.SoundPart
local ts = game.TweenService
local indicator = Door.Parent.Switch.Indicator.Light
local indicatorone = Door.Parent.SecondarySwitch.Indicator.Light
local ssdet = Door.Parent.SecondarySwitch.Switch.SwitchModel.Interact.ClickDetector.MaxActivationDistance


local Rdoor = Door.RDoor.PrimaryPart
local ROpen = Door.RDoorOpen
local RClosed = Door.RDoorClosed


local soundpart = Door.SoundPart

local closed = Door.Closed


		indicator.BrickColor = BrickColor.new("Persimmon")
		indicator.Alert:Play()
	
		indicator.BrickColor = BrickColor.new("Lily white")


function onclicked()
	if closed.Value == false then
		clickdetector.MaxActivationDistance = 0
		Primary.PullSound:Play()
		ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
		wait(0.8)
		ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
		soundpart.OpenSound:Play()
		
		wait(3)
		soundpart.Scrape:Play()
		ts:Create(Rdoor,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = RClosed.CFrame}):Play()
		closed.Value = true
		indicator.BrickColor = BrickColor.new("Persimmon")
		indicator.Alert:Play()
		indicatorone.BrickColor = BrickColor.new("Persimmon")
		indicatorone.Alert:Play()
		wait(1.4)
		clickdetector.MaxActivationDistance = 5
	else
		if closed.Value == true then
			clickdetector.MaxActivationDistance = 0
			
			Primary.PullSound:Play()
			ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
			wait(0.8)
			ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
			soundpart.OpenSound:Play()
		
			wait(3)
			soundpart.Scrape:Play()
			ts:Create(Rdoor,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = ROpen.CFrame}):Play()
			closed.Value = false
			wait(1.4)
			
			indicator.BrickColor = BrickColor.new("Lily white")
			indicatorone.BrickColor = BrickColor.new("Lily white")
			clickdetector.MaxActivationDistance = 5
		end
	end
end
clickdetector.MouseClick:Connect(onclicked)
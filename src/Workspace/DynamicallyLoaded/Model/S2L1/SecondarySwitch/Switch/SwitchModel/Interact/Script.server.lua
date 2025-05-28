local clickdetector = script.Parent.ClickDetector

local Primary = script.Parent.Parent.Parent.Primary
local OnPos = script.Parent.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.Parent.OffPos
local Door = script.Parent.Parent.Parent.Parent.Parent.MetalDoor
local soundpart = Door.SoundPart
local closed = Door.Closed
local ts = game.TweenService
local indicator = Door.Parent.SecondarySwitch.Indicator.Light
local indicatortwo = Door.Parent.Switch.Indicator.Light


local primdet = Door.Parent.Switch.Switch.SwitchModel.Interact.ClickDetector.MaxActivationDistance


local Rdoor = Door.RDoor.PrimaryPart
local ROpen = Door.RDoorOpen
local RClosed = Door.RDoorClosed

local soundpart = Door.SoundPart


		
		indicator.BrickColor = BrickColor.new("Lily white")


function onclicked()
	if closed.Value == false then
		clickdetector.MaxActivationDistance = 0
	
	Primary.PullSound:Play()
	ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
	wait(0.8)
	ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
		soundpart.OpenSound:Play()
		soundpart.Klaxon:Play()
		wait(3)
		soundpart.Scrape:Play()
	ts:Create(Rdoor,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = RClosed.CFrame}):Play()
		closed.Value = true
		indicator.BrickColor = BrickColor.new("Persimmon")
		indicator.Alert:Play()
		indicatortwo.BrickColor = BrickColor.new("Persimmon")
		indicatortwo.Alert:Play()
	wait(1.4)
		
		wait(19)
		soundpart.Klaxon:Stop()
		clickdetector.MaxActivationDistance = 5
	else
		if closed.Value == true then
			clickdetector.MaxActivationDistance = 0
			
	Primary.PullSound:Play()
	ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
	wait(0.8)
	ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
			soundpart.OpenSound:Play()
			--soundpart.Klaxon:Play()
			wait(3)
			soundpart.Scrape:Play()
	ts:Create(Rdoor,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = ROpen.CFrame}):Play()
			closed.Value = false
			indicator.BrickColor = BrickColor.new("Lily white")
			indicatortwo.BrickColor = BrickColor.new("Lily white")
	wait(1.4)
			
			wait(19)
			soundpart.Klaxon:Stop()
			clickdetector.MaxActivationDistance = 5
	end
	end
	end
clickdetector.MouseClick:Connect(onclicked)
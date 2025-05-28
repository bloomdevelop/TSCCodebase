local clickdetector = script.Parent.ClickDetector
local max = clickdetector.MaxActivationDistance
local Primary = script.Parent.Parent.Parent.Primary
local OnPos = script.Parent.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.Parent.OffPos
local Door = script.Parent.Parent.Parent.Parent.Parent.MetalDoor
local soundpart = Door.SoundPart
local ts = game.TweenService
local indicator = Door.Parent.SecondarySwitch.Indicator.Light

local ssdet = Door.Parent.SecondarySwitch.Switch.SwitchModel.Interact.ClickDetector.MaxActivationDistance

local Ldoor = Door.LDoor.PrimaryPart
local LOpen = Door.LDoorOpen
local LClosed = Door.LDoorClosed

local soundpart = Door.SoundPart

local closed = Door.Closed

function indicatorupdate()
	if closed.Value == true then
		indicator.BrickColor = BrickColor.new("Persimmon")
		indicator.Alert:Play()
	else
		indicator.BrickColor = BrickColor.new("Lily white")
	end
end

function onclicked()
	if closed.Value == false then
		max = 0
		ssdet = 0
		Primary.PullSound:Play()
		ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
		wait(0.8)
		ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
		soundpart.OpenSound:Play()
		ts:Create(Ldoor,TweenInfo.new(5,Enum.EasingStyle.Quad),{CFrame = LClosed.CFrame}):Play()
		closed.Value = true
		indicatorupdate()
		wait(1.4)
		max = 5
		ssdet = 5
	else
		if closed.Value == true then
			max = 0
			ssdet = 0
			Primary.PullSound:Play()
			ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
			wait(0.8)
			ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
			soundpart.OpenSound:Play()
			ts:Create(Ldoor,TweenInfo.new(5,Enum.EasingStyle.Quad),{CFrame = LOpen.CFrame}):Play()
			closed.Value = false
			indicatorupdate()
			wait(1.4)
			max = 5
			ssdet = 5
		end
	end
end
clickdetector.MouseClick:Connect(onclicked)
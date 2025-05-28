local clickdetector = script.Parent.ClickDetector

local Primary = script.Parent.Parent.Parent.Primary
local OnPos = script.Parent.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.Parent.OffPos
local Door = script.Parent.Parent.Parent.Parent.Parent.MetalDoor
local soundpart = Door.SoundPart
local Smoke = soundpart.smoke
local ts = game.TweenService
local indicator = Door.Parent.Switch.Indicator.Light




local DoorR = Door.DoorR
local DoorRPrimary = DoorR.DoorRPrimary
local DoorROpen = DoorR.DoorROpen
local DoorRClosed = DoorR.DoorRClosed
local DoorRPartial = DoorR.DoorRPartial
local DoorRSparks = DoorRPrimary.RSparks.Effect.Sparks
local DoorRSparksTwo = DoorRPrimary.RSparksTwo.Effect.Sparks

local DoorL = Door.DoorL
local DoorLPrimary = DoorL.DoorLPrimary
local DoorLOpen = DoorL.DoorLOpen
local DoorLClosed = DoorL.DoorLClosed
local DoorLPartial = DoorL.DoorLPartial
local DoorLSparks = DoorLPrimary.LSparks.Effect.Sparks
local DoorLSparksTwo = DoorLPrimary.LSparksTwo.Effect.Sparks

local soundpart = Door.SoundPart

local closed = Door.Closed

function SparksOn()
	DoorRSparks.Enabled = true
	DoorLSparks.Enabled = true
	DoorRSparksTwo.Enabled = true
	DoorLSparksTwo.Enabled = true
end
function SparksOff()
	DoorRSparks.Enabled = false
	DoorLSparks.Enabled = false
	DoorRSparksTwo.Enabled = false
	DoorLSparksTwo.Enabled = false
end

function onclicked()
	if closed.Value == true then
		clickdetector.MaxActivationDistance = 0
		Primary.PullSound:Play()
		ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
		wait(0.8)
		ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
		soundpart.OpenWarn:Play()
		wait(12.06)
		soundpart.OpenWarn:Stop()
		soundpart.LastWarn:Play()
		soundpart.OpenSound:Play()
		soundpart.Steam.Particle.Enabled = true
		wait(3)
		soundpart.Scrape:Play()
		soundpart.Thud:Play()
		
		ts:Create(DoorRPrimary,TweenInfo.new(.7,Enum.EasingStyle.Back),{CFrame = DoorRPartial.CFrame}):Play()
		ts:Create(DoorLPrimary,TweenInfo.new(.7,Enum.EasingStyle.Back),{CFrame = DoorLPartial.CFrame}):Play()
		soundpart.Steam.Particle.Enabled = false
		wait(3)
		SparksOn()
		ts:Create(DoorRPrimary,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = DoorROpen.CFrame}):Play()
		ts:Create(DoorLPrimary,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = DoorLOpen.CFrame}):Play()
		closed.Value = false
		wait(20)
		SparksOff()
		Smoke.ParticleEmitter.Enabled = false
		Smoke.Run:Stop()
		indicator.BrickColor = BrickColor.new("Persimmon")
		indicator.Alert:Play()

		wait(1.4)
		clickdetector.MaxActivationDistance = 5
	else
		if closed.Value == false then
			clickdetector.MaxActivationDistance = 0
			
			Primary.PullSound:Play()
			ts:Create(Primary,TweenInfo.new(0.7,Enum.EasingStyle.Bounce),{CFrame = OnPos.CFrame}):Play()
			wait(0.8)
			ts:Create(Primary,TweenInfo.new(0.4,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame}):Play()
		
			soundpart.Klaxon:Play()
			soundpart.OpenSound:Play()
		
			wait(3)
			soundpart.Scrape:Play()
			SparksOn()
			ts:Create(DoorRPrimary,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = DoorRClosed.CFrame}):Play()
			ts:Create(DoorLPrimary,TweenInfo.new(20,Enum.EasingStyle.Quad),{CFrame = DoorLClosed.CFrame}):Play()
			wait(20)
			soundpart.Klaxon:Stop()
			SparksOff()
			closed.Value = true
			
			wait(1.4)
			
			indicator.BrickColor = BrickColor.new("Lily white")
		
			clickdetector.MaxActivationDistance = 5
		end
	end
end
clickdetector.MouseClick:Connect(onclicked)
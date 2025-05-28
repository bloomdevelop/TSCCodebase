local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local seat = script.Parent.Seat
local button = script.Parent.SeatLock
local clickDetector = button.ClickDetector

local ArmL = script.Parent.ArmL
local ArmR = script.Parent.ArmR
local TorsoHold = script.Parent.TorsoHold
local LegHold = script.Parent.LegHold

local ArmLActivated = ArmL.ArmLactivated
local ArmRActivated = ArmR.ArmRactivated
local TorsoActivated = TorsoHold.TorsoHoldactivated
local LegActivated = LegHold.LegHoldactivated

local ArmLNeutral = ArmL.ArmLOpen
local ArmRNeutral = ArmR.ArmRopen
local TorsoNeutral = TorsoHold.TorsoHoldOpen
local LegNeutral = LegHold.LegHoldOpen

local ArmLActivated = TweenService:Create(ArmL,TweenInfo.new(0.1),{CFrame = ArmLActivated.CFrame})
local ArmRActivated = TweenService:Create(ArmR,TweenInfo.new(0.1),{CFrame = ArmRActivated.CFrame})
local TorsoActivated = TweenService:Create(TorsoHold,TweenInfo.new(0.1),{CFrame = TorsoActivated.CFrame})
local LegActivated = TweenService:Create(LegHold,TweenInfo.new(0.1),{CFrame = LegActivated.CFrame})

local ArmLDEActivated = TweenService:Create(ArmL,TweenInfo.new(0.1),{CFrame = ArmLNeutral.CFrame})
local ArmRDEActivated = TweenService:Create(ArmR,TweenInfo.new(0.1),{CFrame = ArmRNeutral.CFrame})
local TorsoDEActivated = TweenService:Create(TorsoHold,TweenInfo.new(0.1),{CFrame = TorsoNeutral.CFrame})
local LegDEActivated = TweenService:Create(LegHold,TweenInfo.new(0.1),{CFrame = LegHold.CFrame})

local db = false
local locked = false
local cachedJP = 0
local char1
local humanoid1
local anim

function onSit()
	if seat.Occupant then
		char1 = seat.Occupant.Parent
		humanoid1 = char1:FindFirstChild("Humanoid")
		if char1 and humanoid1 then
			cachedJP = humanoid1.JumpPower
			if locked == true then
				humanoid1.JumpPower = 0
				humanoid1:UnequipTools()
				local T = script.Bfalse:Clone()
				T.Parent = char1
				T.Disabled = false
			end
			anim = humanoid1:LoadAnimation(seat.sitanim)
			anim:Play()
		end
	elseif seat.Occupant == nil then
		anim:Stop()
		local T = script.Btrue:Clone()
		T.Parent = char1
		T.Disabled = false
		humanoid1.JumpPower = cachedJP
	end
end

function onClick()
	if db == false then
		db = true
		if locked == false then
			seat.Lock:Play()
			ArmLActivated:Play()
			ArmRActivated:Play()
			TorsoActivated:Play()
			LegActivated:Play()
		
			locked = true
			button.Color = Color3.fromRGB(255, 89, 89)
			if seat.Occupant then
				local char = seat.Occupant.Parent
				local humanoid = char:FindFirstChild("Humanoid")
				if char and humanoid then
					humanoid.JumpPower = 0
					humanoid:UnequipTools()
					local T = script.Bfalse:Clone()
					T.Parent = char
					T.Disabled = false
				end
			end

		elseif locked == true then
			seat.Unlock:Play()
			ArmLDEActivated:Play()
			ArmRDEActivated:Play()
			TorsoDEActivated:Play()
			LegDEActivated:Play()
			
			locked = false
			button.Color = Color3.fromRGB(89, 255, 89)
			if seat.Occupant then
				local char = seat.Occupant.Parent
				local humanoid = char:FindFirstChild("Humanoid")
				if char and humanoid then
					humanoid.JumpPower = cachedJP
					local T = script.Btrue:Clone()
					T.Parent = char
					T.Disabled = false
				end
			end
		end
		wait(0.2)
		db = false
	end
end

seat:GetPropertyChangedSignal("Occupant"):Connect(onSit)
clickDetector.MouseClick:Connect(onClick)
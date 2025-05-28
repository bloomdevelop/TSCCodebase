local part = script.Parent
local TramGarageDoor = script.Parent.Parent
local Primary = TramGarageDoor.LDoor.PrimaryPart
local openpos = TramGarageDoor.LDoorOpen
local closedpos = TramGarageDoor.LDoorClosed
local sounds = TramGarageDoor.ExternalSoundPlayer
local tweenservice = game:GetService("TweenService")
local OpenTween = tweenservice:Create(Primary,TweenInfo.new(7.056),{CFrame = openpos.CFrame})
local CloseTween = tweenservice:Create(Primary,TweenInfo.new(7.056),{CFrame = closedpos.CFrame})

local function onPartTouched(otherPart)
	if otherPart.Name == ("TramDoorDetect") then
		print("Opening door for tram")
		TramGarageDoor.ClearanceLevel.Value = 100
		sounds.Alarm:Play()
		wait(1)
		OpenTween:Play()
		sounds.OpenSound:Play()
		wait(8)
		CloseTween:Play()
		sounds.CloseSound:Play()
		wait(7)
		TramGarageDoor.ClearanceLevel.Value = 2
	end
end

part.Touched:Connect(onPartTouched)
return function(p,Door)
	local Open = Door:findFirstChild('Open')
	if Open == nil then
		Open = Instance.new("BoolValue",Door)
		Open.Name = 'Open'
		Open.Value = false
	end
	local door1anim = require(Door.Door1.Hinge.Animator)
	local door_open1 = door1anim.DoorOpen
	local door_close1 = door1anim.DoorClose
	local light = Door.Triggers.Light1
	local light2 = Door.Triggers.Light2
	local accept = Door.Frame.sound.open
	local close = Door.Frame.sound.close
	if p == nil or p:DistanceFromCharacter(Door.dist.Position) <= 8 then 
		script.Parent.Parent.Communicator:Fire("ScheduleDB",Door,1)
		Open.Value = not Open.Value
		if Open.Value == true then
			door_open1:Play()
			light.BrickColor = BrickColor.new("Laurel green")
			light2.BrickColor = BrickColor.new("Laurel green")
			accept:Play()
		else
			door_close1:Play()
			light.BrickColor = BrickColor.new("Br. yellowish orange")
			light2.BrickColor = BrickColor.new("Br. yellowish orange")
			wait(.3)
			close:Play()			
		end
	end
end
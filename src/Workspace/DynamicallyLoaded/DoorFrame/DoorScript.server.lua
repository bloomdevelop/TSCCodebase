
--PUT ME INSIDE A DOOR

if script.Parent:IsA("Model") then
	

	
door = script.Parent

flipDoor = script.FlipDoor
reverseDoor = script.ReverseDoor

doorOpen = Instance.new("BoolValue", script.Parent)
doorOpen.Value = false
doorOpen.Name = "DoorOpen"

doorPosition = Instance.new("Vector3Value", script.Parent)
doorPosition.Value = script.Parent:GetModelCFrame().p
doorPosition.Name = "DoorPosition"

openSound = Instance.new("Sound", script.Parent)
openSound.SoundId = "rbxassetid://192416584"
openSound.Name = "OpenSound"

closeSound = Instance.new("Sound", script.Parent)
closeSound.SoundId = "rbxassetid://192416578"
closeSound.Name = "CloseSound"

remoteFunction = Instance.new("RemoteFunction", script.Parent)

local flip = -1
if flipDoor.Value == true then
	flip = 1
else
	flip = -1
end
local reverse = 1
if reverseDoor.Value == true then
	reverse = -1
else
	reverse = 1
end

doors = {}

local index = 1

for _,model in pairs(door:GetChildren()) do
	if model:IsA("Model") then
		table.insert(doors, model)
		
		primaryPart = Instance.new("Part")
		primaryPart.Name = "primaryPart"
		primaryPart.Anchored = true
		primaryPart.CanCollide = false
		primaryPart.Size = Vector3.new(2,2,2)
		primaryPart.Transparency = 1
		local _,ys,_ = model:GetModelCFrame():toEulerAnglesXYZ()
		primaryPart.CFrame = CFrame.new(model:GetModelCFrame().p) * CFrame.Angles(0,ys * (index * 2 - 1),0)
		primaryPart.Parent = model
		
		--print(primaryPart:GetFullName())

		model.PrimaryPart = primaryPart
		
		local center = model:GetModelCFrame()
		local size = model:GetExtentsSize()
		local biggest = math.max(size.x,size.z)
		local point = CFrame.new()
		--print(getModelLength(door))
		--print(getModelWidth(door))

		if biggest == size.x then
			point = center * CFrame.new(Vector3.new(size.X/2 * flip * (index * 2 - 1),0,0))
		elseif biggest == size.z then
			point = center * CFrame.new(Vector3.new(0,0,size.Z/2 * flip * (index * 2 - 1)))
		end
		
		doorHinge = Instance.new("CFrameValue", model)
		doorHinge.Name = "DoorPivotPoint"
		doorHinge.Value = CFrame.new(point.p)
		
		index = 0
	end
end



function doorChange(doorModel, direction, state)
	for _,part in ipairs(doorModel:GetChildren()) do
		if part:IsA("BasePart") then
			local point = doorModel.DoorPivotPoint.Value
			--local point = CFrame.new(doorModel.DoorHinge.CFrame.p) or CFrame.new(doorModel.PrimaryPart.CFrame.p) or CFrame.new(doorModel.GetChrildren[1].CFrame.p)
			local offset = CFrame.new(part.Position - point.p) --* CFrame.Angles(0,-math.rad(i),0)
			--part.CFrame = partC * CFrame.Angles(0,math.rad(i),0) * offset
		
			local rotation = part.CFrame - part.CFrame.p --This is a way of giving you the CFrame.Angles of the part since Orientation cannot directly be put with CFrame.Angles.
			
			if state == true then
				local position = (point * CFrame.Angles(0,reverse * (direction * 2 - 3) * math.rad(120),0) * offset) -- Let the game calculate out the rotation about the point and just get position of part.
				part.CFrame  = position * rotation -- Fit the part's CFrame together with constant rotation.
				closeSound:Play()
			else
				local position = (point * CFrame.Angles(0,-reverse * (direction * 2 - 3) * math.rad(120),0) * offset) -- Let the game calculate out the rotation about the point and just get position of part.
				part.CFrame  = position * rotation -- Fit the part's CFrame together with constant rotation.
				openSound:Play()
			end
		end
	end
end

function openDoor(player)
	local count = 2
	for i,v in ipairs(doors) do
		doorChange(v, count, door.DoorOpen.Value)
		count = count - 1
	end
	door.DoorOpen.Value = not door.DoorOpen.Value
end

remoteFunction.OnServerInvoke = openDoor

end
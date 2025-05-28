local gui = script.Parent
local TB = gui:WaitForChild('TextBox')
local remote = gui:WaitForChild('RemoteEvent')

local db = false

local size = 1

local function changeSize(char,num)
	local motors = {}
	table.insert(motors, char.HumanoidRootPart:FindFirstChild("RootJoint"))
	for _, motor in pairs(char.Torso:GetChildren()) do
		if motor:IsA("Motor6D") then table.insert(motors, motor) end
	end
	for _, motor in pairs(motors) do
		motor.C0 = CFrame.new((motor.C0.Position * num)) * (motor.C0 - motor.C0.Position)
		motor.C1 = CFrame.new((motor.C1.Position * num)) * (motor.C1 - motor.C1.Position)
	end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Size *= num
		elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
			local handle = v.Handle
			handle.AccessoryWeld.C0 = CFrame.new((handle.AccessoryWeld.C0.Position * num)) * (handle.AccessoryWeld.C0 - handle.AccessoryWeld.C0.Position)
			handle.AccessoryWeld.C1 = CFrame.new((handle.AccessoryWeld.C1.Position * num)) * (handle.AccessoryWeld.C1 - handle.AccessoryWeld.C1.Position)
			local mesh = handle:FindFirstChildOfClass("SpecialMesh")
			if mesh then
				mesh.Scale *= num
			end
		elseif v:IsA("SpecialMesh") and v.Parent.Name ~= "Handle" and v.Parent.Name ~= "Head" then
			v.Scale *= num
		end
	end
	size = num
end

remote.OnServerEvent:Connect(function(plr,v)
	if not db then
		db = true
		
		if plr and plr.Character and v then else return end
		if not tonumber(v) then plr:Kick('Error code: 8432') return end
		
		local char = plr.Character
		local num = math.clamp(v,1,2)
		
		if size ~= 1 then
			changeSize(char,1/size)
		end
		changeSize(char,num)
		
		size = num
		
		task.wait(0.5)
		
		db = false
	end
end)
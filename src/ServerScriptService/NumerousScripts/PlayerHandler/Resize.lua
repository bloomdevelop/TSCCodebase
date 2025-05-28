return function(char, num)
	local motors = {}
	local humanoid: Humanoid = char:FindFirstChild('Humanoid')
	humanoid:UnequipTools() -- unequip tools before anything
	table.insert(motors, char.HumanoidRootPart:FindFirstChild("RootJoint"))
	for _, motor in next, char.Torso:GetChildren() do
		if motor:IsA("Motor6D") then -- insert motor into lazy table
			table.insert(motors, motor)
		end
	end
	for _, motor in next, motors do -- reposition motor cframe values
		motor.C0 = CFrame.new((motor.C0.Position * num)) * (motor.C0 - motor.C0.Position)
		motor.C1 = CFrame.new((motor.C1.Position * num)) * (motor.C1 - motor.C1.Position)
	end
	for _, v in next, char:GetDescendants() do
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
		elseif v:IsA('Weld') then
			v.C0 = CFrame.new((v.C0.Position * num)) * (v.C0 - v.C0.Position)
			v.C1 = CFrame.new((v.C1.Position * num)) * (v.C1 - v.C1.Position)
		end
	end
	table.clear(motors)
end
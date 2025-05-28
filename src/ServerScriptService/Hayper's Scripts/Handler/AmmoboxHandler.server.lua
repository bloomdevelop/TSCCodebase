local Players = game:GetService("Players")

local AmmoboxFolder = workspace:WaitForChild("Ammoboxes")

local ConnectionMap: {[BasePart]: RBXScriptConnection} = {}

function handleGun(tool: Tool): boolean
	local gunData = tool:FindFirstChild("GunData")
	if not gunData then return false end

	local defaultGunData = require(tool:FindFirstChild("GunData"))
	local reserveAmmo = gunData:FindFirstChild("ReserveAmmo") :: IntValue?
	local mag = gunData:FindFirstChild("Mag") :: IntValue?

	local refilledAmmo = false

	if reserveAmmo then
		local maxAmmo = defaultGunData.ReserveAmmo or 0
		refilledAmmo = maxAmmo > reserveAmmo.Value

		reserveAmmo.Value = maxAmmo
	end

	if mag then
		local maxAmmo = defaultGunData.MagSize or 0
		refilledAmmo = refilledAmmo or maxAmmo > mag.Value

		mag.Value = maxAmmo
	end

	return refilledAmmo
end

function hookPart(part: BasePart)
	local surfaceGui = part:FindFirstChild("SurfaceGui") :: SurfaceGui
	local sound = part:FindFirstChild("Sound") :: Sound
	
	if not surfaceGui or not sound then return end
	
	local enabled = true
	
	local function Touched(otherPart: BasePart)
		if not enabled then return end
		local player = Players:GetPlayerFromCharacter(otherPart.Parent)
		if not player then return end

		local ammoRefilled = false

		for _, tool in next, player.Backpack:GetChildren() do
			if tool.ClassName ~= "Tool" then continue end
			ammoRefilled = handleGun(tool)
		end

		if player.Character then
			for _, tool in next, player.Character:GetChildren() do
				if tool.ClassName ~= "Tool" then continue end
				ammoRefilled = ammoRefilled or handleGun(tool)
			end
		end

		if not ammoRefilled then return end

		sound:Play()
		part.Transparency = 1
		part.CanCollide = false
		surfaceGui.Enabled = false

		task.delay(1, function()
			part.Transparency = 0
			part.CanCollide = true
			surfaceGui.Enabled = true
			enabled = true
			
			if not ConnectionMap[part] or not enabled then return end
			
			for _,otherPart in next, part:GetTouchingParts() do
				if not ConnectionMap[part] or not enabled then break end
				Touched(otherPart)
			end
		end)
	end
	
	ConnectionMap[part] = part.Touched:Connect(Touched)
end

for _,part in AmmoboxFolder:GetChildren() do
	hookPart(part)
end

AmmoboxFolder.ChildAdded:Connect(hookPart)
AmmoboxFolder.ChildRemoved:Connect(function(child)
	if not ConnectionMap[child] then return end
	ConnectionMap[child]:Disconnect()
	ConnectionMap[child] = nil
end)
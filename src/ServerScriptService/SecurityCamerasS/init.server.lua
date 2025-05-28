-- // Steven_Scripts, 2022

local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")

local remotesFolder = rst.Remotes
local assetsFolder = rst.Assets

local plr = game.Players.LocalPlayer

local function updateIndicatorLight(cameraPart : BasePart)
	local cameraModel = cameraPart:FindFirstChild("CameraModel")
	
	if cameraModel == nil then return end
	cameraModel = cameraModel.Value
	
	local broken = cameraPart.Broken
	local playersViewing = cameraPart.PlayersViewing
	
	local indicatorLight = cameraModel.IndicatorLight
	
	if broken.Value == false then
		if #playersViewing:GetChildren() == 0 then
			-- Nobody's viewing this camera
			indicatorLight.Color = Color3.new(1, 1, 1)
		else
			-- At least one player is viewing this camera
			indicatorLight.Color = Color3.new(1, 0, 0)
		end
	end
end

local function onSwitchCameraLocation(plr : Player, cameraPart : BasePart)
	local value = plr:FindFirstChild("SecurityCameraLocation")
	
	local cameraModel
	
	if value ~= nil then
		local oldCameraPart = value.Value
		local playersViewing = oldCameraPart.PlayersViewing
		
		-- Remove player from list of players viewing that camera
		playersViewing[plr.Name]:Destroy()
		
		updateIndicatorLight(oldCameraPart)
	end
	
	if cameraPart == nil then
		-- Exited security camera system
		if value ~= nil then
			value:Destroy()
			plr.ReplicationFocus = nil
		end
	else
		-- Switched to new camera
		if value == nil then
			value = Instance.new("ObjectValue")
			value.Name = "SecurityCameraLocation"
			value.Parent = plr
		end
		
		value.Value = cameraPart
		plr.ReplicationFocus = cameraPart
		
		local playersViewing = cameraPart.PlayersViewing

		cameraModel = value.Value:FindFirstChild("CameraModel")
		
		-- Add player to list of players viewing that camera
		local newPlayerValue = Instance.new("BoolValue")
		newPlayerValue.Name = plr.Name
		newPlayerValue.Parent = playersViewing
		
		updateIndicatorLight(cameraPart)
	end
end

-- NOTE: The location parts double as hitboxes.
for i,cameraPart in pairs(workspace.SecurityCameraLocations:GetChildren()) do
	local playersViewingFolder = Instance.new("Folder")
	playersViewingFolder.Name = "PlayersViewing"

	local brokenValue = Instance.new("BoolValue")
	brokenValue.Name = "Broken"

	playersViewingFolder.Parent = cameraPart
	brokenValue.Parent = cameraPart
	
	local cameraModel = cameraPart:FindFirstChild("CameraModel")
	if cameraModel then
		script.OnGunHit:Clone().Parent = cameraPart
		
		for i,effect in pairs(script.Effects:GetChildren()) do
			effect:Clone().Parent = cameraPart
		end
	end
	
	cameraPart.Transparency = 1
end

remotesFolder.SecurityCameras.SwitchCameraLocation.OnServerEvent:Connect(onSwitchCameraLocation)
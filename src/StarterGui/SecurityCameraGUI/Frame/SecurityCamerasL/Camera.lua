-- // Steven_Scripts, 2022

local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")

local assetsFolder = rst.Assets
local remotesFolder = rst.Remotes

local plr = game.Players.LocalPlayer

local camera = workspace.CurrentCamera

local noSignalCC = Instance.new("ColorCorrectionEffect")
noSignalCC.Brightness = -100
noSignalCC.Enabled = false
noSignalCC.Parent = camera

local topFrame = script.Parent.Parent
local cameraEffects = topFrame.CameraEffects
local staticTransparency = topFrame.StaticTransparency

local cameraLocationsFolder = workspace.SecurityCameraLocations
local cameraSwitchButtonsFolder = topFrame.CameraSwitchButtons

local currentCameraPart = nil
local currentCameraStation = nil

local sounds = topFrame.Sounds

local lightingeffects = game.Lighting.SecurityCameraEffects


local cameraSwitchCooldown = false

local brokenStateChangedConnection = nil

local function hideCameraSwitchButtons()
	for i,billboardGui in pairs(cameraSwitchButtonsFolder:GetChildren()) do
		billboardGui.Enabled = false
	end
end

local function showCameraSwitchButtons()
	for i,billboardGui in pairs(cameraSwitchButtonsFolder:GetChildren()) do
		billboardGui.Enabled = true
	end
end

local switchCamera

local function updateCameraSwitchButtons()
	-- Clear out outdated buttons and update existing ones
	for i,billboardGui in pairs(cameraSwitchButtonsFolder:GetChildren()) do
		if billboardGui.Name == currentCameraPart.Name or billboardGui.Adornee == nil or billboardGui.Adornee.Parent == nil then 
			-- Destroy outdated button
			billboardGui:Destroy()
		else
			-- Update button transparency
			local distance = (billboardGui.Adornee.Position - camera.CFrame.Position).Magnitude
			billboardGui.Button.ImageTransparency = 0.5 + (0.4 * math.clamp(distance/500, 0, 1))
		end
	end
	
	for i,cameraPart in pairs(cameraLocationsFolder:GetChildren()) do
		local distance = (cameraPart.Position - camera.CFrame.Position).Magnitude
		
		local billboardGui = cameraSwitchButtonsFolder:FindFirstChild(cameraPart.Name)
		
		if billboardGui == nil and cameraPart.Name ~= currentCameraPart.Name then
			-- This button doesn't exist yet, create a new one
			billboardGui = assetsFolder.UI.CameraSwitchButton:Clone()
			billboardGui.Name = cameraPart.Name
			
			billboardGui.Location.Text = cameraPart.Name
			billboardGui.Location.Visible = false
			billboardGui.Adornee = cameraPart
			
			billboardGui.Button.ImageTransparency = 0.5 + (0.4 * math.clamp(distance/500, 0, 1))
			
			billboardGui.Parent = cameraSwitchButtonsFolder
			
			billboardGui.Button.MouseEnter:Connect(function()
				sounds.Hover:Play()
				
				billboardGui.Button.ImageTransparency = 0.15
				billboardGui.Button.ImageColor3 = Color3.new(1, 0, 0)
				
				billboardGui.Location.Visible = true
			end)
			
			local function onMouseLeave()
				if billboardGui.Parent == nil then return end
				
				distance = (cameraPart.Position - camera.CFrame.Position).Magnitude
				billboardGui.Button.ImageTransparency = 0.5 + (0.4 * math.clamp(distance/500, 0, 1))
				billboardGui.Button.ImageColor3 = Color3.new(1, 1, 1)

				billboardGui.Location.Visible = false
			end
			
			billboardGui.Button.MouseLeave:Connect(onMouseLeave)
			
			billboardGui.Button.MouseButton1Down:Connect(function()
				sounds.ClickDown:Play()
			end)
			
			billboardGui.Button.MouseButton1Up:Connect(function()
				sounds.ClickUp:Play()
				switchCamera(cameraPart)
				onMouseLeave()
			end)
		end
	end
end

local function toggleModelTransparencyModifier(model : Model, transparencyModifier : number)
	for i,part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = transparencyModifier
		end
	end
end

switchCamera = function(cameraPart : BasePart)
	if cameraSwitchCooldown then return end
	
	cameraSwitchCooldown = true
	
	if currentCameraPart ~= nil then
		local cameraModel = currentCameraPart:FindFirstChild("CameraModel")
		if cameraModel ~= nil then
			cameraModel = cameraModel.Value
			
			-- Make old camera model visible
			toggleModelTransparencyModifier(cameraModel, 0)
		end
		
		brokenStateChangedConnection:Disconnect()
	end
	
	currentCameraPart = cameraPart
	
	local cameraModel = cameraPart:FindFirstChild("CameraModel")
	if cameraModel ~= nil then
		cameraModel = cameraModel.Value
		
		-- Make new camera model invisibile
		toggleModelTransparencyModifier(cameraModel, 1)
	end
	
	hideCameraSwitchButtons()
	
	staticTransparency.Value = 0
	cameraEffects.NoSignal.Visible = false
	noSignalCC.Enabled = false
	cameraEffects.Grime.Visible = true
	
	cameraEffects.Location.Text = cameraPart.Name
	
	remotesFolder.SecurityCameras.SwitchCameraLocation:FireServer(cameraPart)
	
	camera.CameraSubject = cameraPart
	plr.CameraMode = Enum.CameraMode.LockFirstPerson

	sounds.CameraChange:Play()
		
	task.wait(1)
	
	updateCameraSwitchButtons()
	
	if cameraPart.Broken.Value == true then
		
		cameraEffects.NoSignal.Visible = true
		noSignalCC.Enabled = true
		cameraEffects.Grime.Visible = false
		
	end

	staticTransparency.Value = 0.8
	cameraSwitchCooldown = false
	
	showCameraSwitchButtons()
	
	brokenStateChangedConnection = cameraPart.Broken:GetPropertyChangedSignal("Value"):Connect(function()
		cameraEffects.NoSignal.Visible = cameraPart.Broken.Value
		noSignalCC.Enabled = cameraPart.Broken.Value
		cameraEffects.Grime.Visible = not cameraPart.Broken.Value
	end)
end

local function enter(cameraStation)
	topFrame.Visible = true
	sounds.Static:Play()
	game.Lighting.SecurityCameraEffects.CamCorrection.Parent = game.Lighting
	currentCameraStation = cameraStation
	
	local closestDistance = math.huge
	local closestCameraPart = nil
	for i,cameraPart in pairs(cameraLocationsFolder:GetChildren()) do
		local distance = (cameraPart.CFrame.Position - camera.CFrame.Position).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestCameraPart = cameraPart
		end
	end
	
	if closestCameraPart ~= nil then
		switchCamera(closestCameraPart)
	else
		warn("Couldn't find a nearby camera!")
	end
	
	-- Auto-refresh switch buttons every 10 seconds
	while currentCameraStation ~= nil do
		updateCameraSwitchButtons()
		task.wait(10)
	end
end

local function exit()
	if currentCameraStation == nil then return end
	
	sounds.Static:Stop()
	sounds.PowerDown:Play()
	game.Lighting.CamCorrection.Parent = game.Lighting.SecurityCameraEffects
	if currentCameraStation == nil then return end
	
	if currentCameraPart ~= nil then
		local cameraModel = currentCameraPart:FindFirstChild("CameraModel")
		if cameraModel then
			cameraModel = cameraModel.Value
			
			-- Make old camera model visible
			toggleModelTransparencyModifier(cameraModel, 0)
		end
		
		currentCameraPart = nil
		remotesFolder.SecurityCameras.SwitchCameraLocation:FireServer(nil)
		noSignalCC.Enabled = false
		
		brokenStateChangedConnection:Disconnect()
	end
	
	topFrame.Visible = false
	
	hideCameraSwitchButtons()
	
	local char = plr.Character
	if char then
		local head = char:FindFirstChild("Head")
		if head then
			-- Rotate camera to face the camera station
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.lookAt(head.Position, currentCameraStation.Position)
			
			camera.CameraType = Enum.CameraType.Custom
		end
	end
	
	currentCameraStation = nil
	
	camera.CameraSubject = char
	plr.CameraMode = Enum.CameraMode.Classic
end

local function onCharAdded(char)
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(exit)
	
	local lastHealth = hum.Health
	hum.HealthChanged:Connect(function()
		if currentCameraStation == nil then return end
		
		local newHealth = hum.Health
		local difference = newHealth-lastHealth
		
		if difference < -5 then
			-- Player's getting hurt. They should probably exit.
			exit()
		end
		
		lastHealth = newHealth
	end)
end

topFrame.Exit.Activated:Connect(exit)
plr.CharacterAdded:Connect(onCharAdded)

---- Initializing
local function setUpSecurityCameraStation(part)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "SecurityCameraStationPrompt"
	
	prompt.ObjectText = "Security Cameras"
	prompt.ActionText = "View"
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = true
	prompt.Style = Enum.ProximityPromptStyle.Custom
	
	prompt.Parent = part

	prompt.Triggered:Connect(function()
		if currentCameraStation ~= nil then return end
		
		if plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum.Health > 0 then
				enter(part)
			end
		end
	end)
end

local securityCameraStations
while true do
	securityCameraStations = cs:GetTagged("SecurityCameraStation")

	for i,part in pairs(securityCameraStations) do
		if part.Parent ~= nil and part:FindFirstChild("SecurityCameraStationPrompt") == nil then
			setUpSecurityCameraStation(part)
		end
	end
	
	if currentCameraStation ~= nil then
		local char = plr.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root and (root.Position - currentCameraStation.Position).Magnitude > 15 then
				exit()
			end
		end
	end
	
	task.wait(10)
end

return true
-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")

local remotesFolder = rst.Remotes

local plr = game.Players.LocalPlayer

local camera = workspace.CurrentCamera

local menuFrame = script.Parent.Parent
local cameraEffects = menuFrame.Viewport.CameraEffects
local staticTransparency = menuFrame.StaticTransparency

local sounds = menuFrame.Sounds

local cameraAngles = {}
local currentCameraAngleIndex = 1

local lastCameraSwitchTimestamp = 0

local cameraSwitchCooldown = false

local function switchCameraAngle(cameraAngleData)
	if cameraSwitchCooldown then return end

	cameraSwitchCooldown = true

	cameraEffects.CameraNumber.Text = "Camera "..cameraAngleData.CameraNumber
	cameraEffects.Cracks.Visible = false

	lastCameraSwitchTimestamp = os.clock()

	staticTransparency.Value = 0

	remotesFolder.ContentStreaming.RequestStreamAround:FireServer(cameraAngleData.CF.Position)

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cameraAngleData.CF

	sounds.CameraChange:Play()

	task.wait(1)

	staticTransparency.Value = 0.95

	cameraSwitchCooldown = false
end

local function onTeamChanged()
	if menuFrame.Visible == false then return end

	local team = plr.Team

	local teamCameraAngles = cameraAngles[team.Name] or cameraAngles["Test Subject"]

	currentCameraAngleIndex = 1
	local cameraAngleData = teamCameraAngles[currentCameraAngleIndex]

	switchCameraAngle(cameraAngleData)
end

local function switchToNextCameraAngle()
	local teamCameraAngles = cameraAngles[plr.Team.Name]

	currentCameraAngleIndex = currentCameraAngleIndex+1
	if currentCameraAngleIndex > #teamCameraAngles then
		currentCameraAngleIndex = 1
	end

	switchCameraAngle(teamCameraAngles[currentCameraAngleIndex])
end

local function onMenuVisibilityChanged()
	local visible = menuFrame.Visible
	if visible then
		camera.CameraType = Enum.CameraType.Scriptable
		switchToNextCameraAngle()
	else
		camera.CameraType = Enum.CameraType.Custom
	end
end

local menuCameraAnglesFolder = rst:WaitForChild("MenuCameraAngles")

local camerasChecked = 0
for i,folder in pairs(menuCameraAnglesFolder:GetChildren()) do
	local teamCameraAngles = {}
	for i,part in pairs(folder:GetChildren()) do
		camerasChecked = camerasChecked+1
		teamCameraAngles[i] = {CameraNumber = camerasChecked, CF = part.CFrame}
	end

	cameraAngles[folder.Name] =  teamCameraAngles
end

onMenuVisibilityChanged()
onTeamChanged()
menuFrame:GetPropertyChangedSignal("Visible"):Connect(onMenuVisibilityChanged)
plr:GetPropertyChangedSignal("Team"):Connect(onTeamChanged)

task.spawn(function()
	while task.wait(5) do
		if menuFrame.Visible == true then
			local timeSinceLastCameraSwitch = os.clock() - lastCameraSwitchTimestamp
			if timeSinceLastCameraSwitch > 10 then
				local teamCameraAngles = cameraAngles[plr.Team.Name]
				
				if not teamCameraAngles then
					lastCameraSwitchTimestamp = os.clock()
					continue
				end
				
				if  #teamCameraAngles > 1 then
					switchToNextCameraAngle()
				end
			end
		else
			task.wait(20)
		end
	end
end)

return true
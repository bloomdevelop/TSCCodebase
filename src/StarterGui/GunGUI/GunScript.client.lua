local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = replicatedStorage.Remotes

local gunFireRemote = remotesFolder.Guns.GunFire
local gunHitRemote = remotesFolder.Guns.GunHit

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local gunGui = script.Parent
local gunAmmoCounter = gunGui.GunAmmoCounter
local crosshair = gunGui.Crosshair
local chargeBar = gunGui.ChargeBar

local connections = {}

gunHitRemote.OnClientEvent:Connect(function(playerWhoShot, gunData, hitPart, hitPosition)
	if playerWhoShot ~= player then return end
	
	local markerData = gunData.Marker 
	if markerData then
		local isHeadShot = hitPart.Name == "Head"
		
		crosshair.Hitmarker.ImageColor3 = isHeadShot and markerData.ColourHS or markerData.Colour
		crosshair.Hitmarker.ImageTransparency = 0
		tweenService:Create(crosshair.Hitmarker, TweenInfo.new(markerData.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
		if markerData.Sounds then
		local markersound = crosshair.MarkerSound:Clone()
		markersound.SoundId = "rbxassetid://"..markerData.Sounds[math.random(1,#markerData.Sounds)]
		markersound.PlaybackSpeed =  isHeadShot and markerData.PitchHS or markerData.Pitch
		markersound.Parent = script
		markersound:Play()
			debris:addItem(markersound,1.15)
		end
	end
end)

local function gunAdded(gun)
	local gunData = require(gun.GunData)
	local crosshairData = gunData.Crosshair 
	gunGui.MobileButtons.Visible = userInputService.TouchEnabled
	if crosshairData then		
		crosshair.Main.Down.Position = UDim2.new(0,0,0,crosshairData.Expansion)
		crosshair.Main.Left.Position = UDim2.new(0,-crosshairData.Expansion,0,0)
		crosshair.Main.Right.Position = UDim2.new(0,crosshairData.Expansion,0,0)
		crosshair.Main.Up.Position = UDim2.new(0,0,0,-crosshairData.Expansion)

		crosshair.Main.Down.Size = UDim2.new(0,1,0,crosshairData.Thiccness)
		crosshair.Main.Left.Size = UDim2.new(0,crosshairData.Thiccness,0,1)
		crosshair.Main.Right.Size = UDim2.new(0,crosshairData.Thiccness,0,1)
		crosshair.Main.Up.Size = UDim2.new(0,1,0,crosshairData.Thiccness)

		crosshair.Visible = true
	else
		crosshair.Visible = false
	end

	if gunData.MagSize ~= 0 and gunData.Charge == nil then
		gunAmmoCounter.Mag.Current.Text =  gun.GunData.Mag.Value --current mag
		gunAmmoCounter.Mag.Max.Text = gunData.MagSize --max mag

		gunAmmoCounter.Visible = true
		--connections to update the gun mag
		local magConnection = gun.GunData.Mag.Changed:Connect(function(value)
			gunAmmoCounter.Mag.Current.Text = value
		end)	
		local reserveConnection
		if gunData.ReserveAmmo then
			gunAmmoCounter.Reserve.Max.Text =  gunData.ReserveAmmo --max reserve
			gunAmmoCounter.Reserve.Current.Text =  gun.GunData.ReserveAmmo.Value --current reserve
			reserveConnection = gun.GunData.ReserveAmmo.Changed:Connect(function(value)
				gunAmmoCounter.Reserve.Current.Text = value
			end)	
			gunAmmoCounter.Reserve.Visible = true
		else
			gunAmmoCounter.Reserve.Visible = false
		end
		table.insert(connections,magConnection)
		table.insert(connections,reserveConnection) 
	else
		gunAmmoCounter.Visible = false
	end
	if gunData.Charge then
		chargeBar.Visible = true
		chargeBar.Low.Position = UDim2.new(gunData.Charge.LowCharge/gunData.Charge.MaxCharge,0,0.5,0)
		chargeBar.Mid.Position = UDim2.new(gunData.Charge.MidCharge/gunData.Charge.MaxCharge,0,0.5,0)
	else
		chargeBar.Visible = false
	end
end

local function gunRemoved(gun)
	gunAmmoCounter.Visible = false
	crosshair.Visible = false
	gunGui.Scope.Visible = false
	chargeBar.Visible = false
end
character.ChildAdded:Connect(function(child)
	if child:IsA("Tool") and child:FindFirstChild("GunData") then
		gunAdded(child)
	end
end)

character.ChildRemoved:Connect(function(child)
	if child:IsA("Tool") and child:FindFirstChild("GunData") then
		gunRemoved(child)
		for index,curConnection in pairs(connections)do
			if curConnection then
				curConnection:Disconnect()
				connections[index] = nil
			end
		end
	end
end)
mouse.Move:Connect(function()
	crosshair.Position = UDim2.new(0,mouse.X,0, mouse.Y)
end)
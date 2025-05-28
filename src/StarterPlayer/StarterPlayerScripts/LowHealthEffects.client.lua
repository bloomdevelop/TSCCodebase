local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Heartbeat = SoundService:WaitForChild("SoundStorage"):WaitForChild("Enviromental"):WaitForChild("Heartbeat")

local SlowInfo = TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) 
local FastInfo = TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local NFov = 70
local LFov = 100

local NormalFov = TweenService:Create(workspace.CurrentCamera, FastInfo, {
	FieldOfView = NFov
})

local LowFov =  TweenService:Create(workspace.CurrentCamera, SlowInfo, {
	FieldOfView = LFov
})

function characterAdded(Character: Model)
	Lighting.lowblur.Enabled = false
	Lighting.lowbloom.Enabled = false
	Lighting.lowcorrect.Enabled = false
	workspace.CurrentCamera.FieldOfView = NFov
	
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local conn
	local conn2

	conn = Humanoid.HealthChanged:Connect(function()
		if Humanoid.Health > 20 then
			NormalFov:Play()
			Lighting.lowblur.Enabled = false
			Lighting.lowbloom.Enabled = false
			Lighting.lowcorrect.Enabled = false
			Heartbeat:Stop()
		else
			LowFov:Play()
			Lighting.lowblur.Enabled = true
			Lighting.lowbloom.Enabled = true
			Lighting.lowcorrect.Enabled = true
			Heartbeat.Playing = true
		end
	end)

	conn2 = Humanoid.Died:Connect(function()
		Heartbeat:Stop()
		conn:Disconnect()
		conn2:Disconnect()
	end)
end

Player.CharacterAdded:Connect(characterAdded)

if Player.Character then
	characterAdded(Player.Character)
end
local player = game.Players.LocalPlayer

ShakeDist = 25

local cameraShaker = require(game.ReplicatedStorage.CameraShaker)
local camera = workspace.CurrentCamera

local camShake = cameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)

local function onDescendantAdded(desc)
	if desc:IsA("Explosion") then
		local ExDist = (player.Character.Head.Position - desc.Position).magnitude
		local ShakeMagnitude = ExDist/(desc.BlastRadius/8)
        if ShakeMagnitude < ShakeDist then
		    camShake:Start()
			camShake:ShakeOnce(desc.BlastRadius/2, 10, 0, 1.5)
			
			local menuGui = player.PlayerGui.MenuGui
			if menuGui.MenuFrame.Visible == true then
				menuGui.MenuFrame.Sounds.GlassBreak:Play()
				menuGui.MenuFrame.Viewport.CameraEffects.Cracks.Visible = true
			end
		end
	end
end

workspace.DescendantAdded:Connect(onDescendantAdded)

--[thienbao2109]--
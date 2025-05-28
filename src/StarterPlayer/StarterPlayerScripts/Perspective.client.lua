local runService = game:GetService("RunService")

local player = game.Players.LocalPlayer
camera = workspace.CurrentCamera

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
end)



Z = 0
damping = humanoid.WalkSpeed * 2
PI = math.pi
tck =  PI / 2
running = false
strafing = false

humanoid.Strafing:connect(function(bool)
	strafing = bool
end)

humanoid.Jumping:connect(function()
	running = false
end)

humanoid.Swimming:connect(function()
	running = false
end)

humanoid.Running:connect(function(speed)
	if speed > 0.5 then
		running = true
	else
		running = false
	end
end)

humanoid.Changed:connect(function(Var)
	if Var == "WalkSpeed" then
		if humanoid.WalkSpeed > 8 then 
			damping = humanoid.WalkSpeed * 2
		else 
			damping = humanoid.WalkSpeed * 16 
		end
	end
end)

function mix(par1, par2, factor)
	return par2 + (par1 - par2) * factor
end

runService.RenderStepped:Connect(function()
	if character and character:FindFirstChild("Head") and humanoid and camera.CameraType ~= Enum.CameraType.Scriptable and camera.CameraSubject == humanoid then
		Z = (camera.CFrame.p - character.Head.Position).Magnitude < 0 and 1 or 0
		if running and not strafing then
			tck = tck + humanoid.WalkSpeed / 92 -- Calculate Bobbing speed.
		else
			if tck > 0 and tck < PI / 2 or  tck > PI / 2 and tck < PI then
				tck = mix(tck, PI / 2, 0.9)
			end
			if tck > PI and tck < PI * 1.5 or  tck > PI * 1.5 and tck < PI * 2 then
				tck = mix(tck, PI * 1.5, 0.9)
			end
		end
		if tck >= PI * 2 then
			tck = 0
		end	
		camera.CFrame *=
			CFrame.new(math.cos(tck) / damping, math.sin(tck * 2) / (damping * 2), Z) * 
			CFrame.Angles(0, 0, math.sin(tck - PI * 1.5) / (damping * 20)) -- Set camera CFrame
	end
end)
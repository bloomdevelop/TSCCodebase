local player = game.Players.LocalPlayer
local cam = game.Workspace.CurrentCamera
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local selected = false
local lastUpdate = 0

userInput.InputBegan:Connect(function(input,GPE)
	function getNextMovement(tickTime,speed)
		if selected then
			local nextMove = Vector3.new()

			if not GPE then
				-- Left/Right
				if userInput:IsKeyDown("A") then
					nextMove = nextMove + Vector3.new(-1,0,0)
				elseif userInput:IsKeyDown("D") then
					nextMove = nextMove + Vector3.new(1,0,0)
				end
				-- Forwar/Back
				if userInput:IsKeyDown("W") then
					nextMove = nextMove + Vector3.new(0,0,-1)
				elseif userInput:IsKeyDown("S") then
					nextMove = nextMove + Vector3.new(0,0,1)
				end
				-- Up/Down
				--[[if userInput:IsKeyDown("Space") then
					nextMove = nextMove + Vector3.new(0,1,0)
				elseif userInput:IsKeyDown("LeftControl") then
					nextMove = nextMove + Vector3.new(0,-1,0)
				end--]]
				if player.PlayerGui.NoClipGui then
					if userInput:IsKeyDown("R") then
						local num = tonumber(player.PlayerGui.NoClipGui.Frame.Speed.Text)
						num = num + 5
						player.PlayerGui.NoClipGui.Frame.Speed.Text = num
					end

					if userInput:IsKeyDown("F") then
						local num = tonumber(player.PlayerGui.NoClipGui.Frame.Speed.Text)
						if num <= 0 then
							num = 0
						else
							num = num - 5
						end
						player.PlayerGui.NoClipGui.Frame.Speed.Text = num
					end
				end
			end
			return CFrame.new(nextMove * (speed * tickTime))
		end
	end
end)

function onSelected()
	local char = player.Character
	if char then
		local humanoid = char:WaitForChild("Humanoid")
		local humRoot = char:WaitForChild("HumanoidRootPart")
		local originalPos = humRoot.CFrame
		local originalOrientation = humRoot.Orientation
		local originalCamOrientation = cam.CFrame
		local playerGui = player:WaitForChild("PlayerGui")
		local tempNum
		local speed
		local clone = script.Parent.NoClipGui:Clone()
		clone.Parent = playerGui
		clone.Frame.Return.MouseButton1Up:Connect(function()
			humRoot.CFrame = originalPos
			humRoot.Orientation = originalOrientation
			cam.CFrame = originalCamOrientation
		end)

		selected = true
		humRoot.Anchored = true
		humanoid.PlatformStand = true
		lastUpdate = tick()
		while selected do
			game["Run Service"].Stepped:Wait()
			speed = tonumber(clone.Frame.Speed.Text)
			if speed == nil then
				speed = 100
			end
			local delta = tick()-lastUpdate
			local look = (cam.Focus.p-cam.CoordinateFrame.p).unit
			local move = getNextMovement(delta,speed)
			local pos = humRoot.Position
			if move ~= nil then
				tempNum = move
				humRoot.CFrame = CFrame.new(pos,pos+look) * move
			elseif move == nil and tempNum then
				humRoot.CFrame = CFrame.new(pos,pos+look) * tempNum
			end
			lastUpdate = tick()
		end
		humRoot.Anchored = false
		humRoot.Velocity = Vector3.new()
		humanoid.PlatformStand = false
		script.Parent.NoClipGui.Frame.Speed.Text = speed
		clone:Destroy()
	end
end

function onDeselected()
	selected = false
end

script.Parent.Equipped:Connect(onSelected)
script.Parent.Unequipped:Connect(onDeselected)
local Cameras = game.ReplicatedStorage.CameraFunction:InvokeServer()
local CameraNum = 1
local function GotoCamera()
	script.Parent.TextLabel.Text = "Camera #"..CameraNum
	--print(CameraNum,Cameras[CameraNum])
	--workspace.CurrentCamera.CameraSubject = Cameras[CameraNum]
	workspace.CurrentCamera.CFrame = Cameras[CameraNum]
end
GotoCamera()

script.Parent.Back.MouseButton1Click:Connect(function()
	if CameraNum > 1 then
		CameraNum = CameraNum - 1
		GotoCamera()
	else
		CameraNum = 1
	end
end)

script.Parent.Next.MouseButton1Click:Connect(function()
	if CameraNum < #Cameras then
		CameraNum = CameraNum + 1
		GotoCamera()
	else
		CameraNum = #Cameras
	end
end)

script.Parent.ExitCamera.MouseButton1Click:Connect(function()
	--repeat
	--	wait()
	--	workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid -- When a player clicked 'Exit Camera' the camera will return to a character's humanoid.
	--until workspace.CurrentCamera.CameraSubject == game.Players.LocalPlayer.Character.Humanoid
	game.Players.LocalPlayer.Character.Humanoid:UnequipTools()
end)
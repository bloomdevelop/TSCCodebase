script.Parent.Equipped:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local CameraGui = script.Parent.CameraGui:Clone()
	CameraGui.Parent = game.Players.LocalPlayer.PlayerGui
	CameraGui.Frame.CameraControl.Disabled = false
end)

script.Parent.Unequipped:Connect(function()
	game.Players.LocalPlayer.PlayerGui.CameraGui:Destroy()
	workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
	workspace.CurrentCamera.CFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end)
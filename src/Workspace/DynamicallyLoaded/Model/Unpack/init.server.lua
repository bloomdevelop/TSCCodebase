local Typing = script.Typing
local RemoteEvent = script.PlaySound

script.SurfaceGui.Parent = game:GetService("StarterGui")
RemoteEvent.Parent = script.Parent.Screen

RemoteEvent.OnServerEvent:Connect(function()
	coroutine.resume(coroutine.create(function()
		local Sound = Typing:Clone()
		Sound.Parent = script.Parent.BottomHalf
		Sound.PlaybackSpeed = math.random(0.95,1.05)
		Sound.TimePosition = 0
		Sound:Play()
		wait(Sound.TimeLength)
		if Sound then Sound:Destroy() end
	end))
end)
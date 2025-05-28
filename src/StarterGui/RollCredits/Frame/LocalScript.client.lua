local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local nameTween = TweenService:Create(script.Parent.Credits,TweenInfo.new(12,Enum.EasingStyle.Linear),{Position = UDim2.new(0,0,0,0)})
local creditTween = TweenService:Create(script.Parent.Credits,TweenInfo.new(55,Enum.EasingStyle.Linear),{Position = UDim2.new(0,0,-4.5,0)})
game.ReplicatedStorage.Remotes.NukeDeto.OnClientEvent:Connect(function()
	for i,v in pairs(workspace.AlarmLights:GetChildren())do
		if v.Name == ("Buzz") then
			v.Volume = 0
		end
	end
	script.Parent.HalfLifeCredits:Play()
	script.Parent.Credits.Position = UDim2.new(0,0,1,0)
	script.Parent.Visible = true
	TweenService:Create(Lighting,TweenInfo.new(1,Enum.EasingStyle.Linear),{ExposureCompensation = 0}):Play()
	nameTween:Play()
	wait(16)
	creditTween:Play()
end)
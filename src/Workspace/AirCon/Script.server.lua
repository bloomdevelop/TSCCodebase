local TS = game:GetService("TweenService")
local folder = script.Parent

local info = TweenInfo.new(
	0.25,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,
	false,
	0
)

for _,v in pairs(folder:GetChildren()) do
	if v:IsA("Model") and v.PrimaryPart then
		local spin1 = TS:Create(v.PrimaryPart,info,{CFrame = v.PrimaryPart.CFrame * CFrame.Angles(0,0,math.rad(120))})
		local spin2 = TS:Create(v.PrimaryPart,info,{CFrame = v.PrimaryPart.CFrame * CFrame.Angles(0,0,math.rad(240))})
		local spin3 = TS:Create(v.PrimaryPart,info,{CFrame = v.PrimaryPart.CFrame * CFrame.Angles(0,0,math.rad(360))})

		spin1:Play()
		spin1.Completed:Connect(function()spin2:Play() end)
		spin2.Completed:Connect(function()spin3:Play() end)
		spin3.Completed:Connect(function()spin1:Play() end)
	end
end
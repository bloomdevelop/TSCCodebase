local TweenService = game:GetService("TweenService")
local OnPos = script.Parent.Parent.Parent.On
local OffPos = script.Parent.Parent.Parent.Off
local Primary = script.Parent.Parent.Parent.Primary
local PullSound = script.Parent.Parent.PullSound
local ReturnSound = script.Parent.Parent.ReturnSound
local Alarm = script.Parent.Parent.Parent.Hitbox.Alarm

local PulledTween = TweenService:Create(Primary,TweenInfo.new(0.2,Enum.EasingStyle.Bounce),{CFrame = OffPos.CFrame})
local ReturnTween = TweenService:Create(Primary,TweenInfo.new(0.5,Enum.EasingStyle.Back),{CFrame = OnPos.CFrame})

function OnClicked()
	script.Parent.MaxActivationDistance = 0
	PullSound:Play()
	PulledTween:Play()
	Alarm:Play()
	wait(0.3)
	ReturnSound:Play()
	ReturnTween:Play()
	wait(0.2)
	script.Parent.MaxActivationDistance = 5
end

script.Parent.MouseClick:Connect(OnClicked)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local SoundStorage = SoundService.SoundStorage

script.Parent.Frame.Visible=false

local downImageTween = TweenService:Create(script.Parent.Frame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5,0,0.1,0)})
local upImageTween = TweenService:Create(script.Parent.Frame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5,0,0,10)})

ReplicatedStorage:WaitForChild("PAEvent").OnClientEvent:Connect(function(player: Player, message: string)
	if not player:IsA("Player") then return end

	SoundStorage.Intercom.Beep:Play()
	script.Parent.Frame.Visible=true
	downImageTween:Play()
	script.Parent.Frame.Text.Text = "<b>"..player.Name.."</b>"..": "..message

	SoundStorage.Intercom.Talking:Play()

	task.wait(10)

	SoundStorage.Intercom.Talking:Stop()
	SoundStorage.Intercom.IntercomHangup:Play()

	upImageTween:Play()
	
	task.wait(1)
	script.Parent.Frame.Visible=false
end)

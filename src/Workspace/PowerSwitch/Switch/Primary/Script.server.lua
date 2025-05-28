local Primary = script.Parent
local OnPos = script.Parent.Parent.OnPos
local OffPos = script.Parent.Parent.OffPos
local TweenService = game:GetService("TweenService")
local ON = false

function onClicked()
	local ON = not ON
	if ON == true then
	Primary.PullSound:Play()
	ON = true
		TweenService:Create(Primary,TweenInfo.new(0.4),{CFrame = OnPos.CFrame}):Play()
	else
		TweenService:Create(Primary,TweenInfo.new(0.4),{CFrame = OffPos.CFrame}):Play()
	end
end
script.Parent.ClickDetector.MouseClick:Connect(onClicked)
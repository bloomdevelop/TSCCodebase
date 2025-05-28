local Hitbox = script.Parent.Parent
local Primary = script.Parent.Parent.Parent.Primary
local OpenPos = script.Parent.Parent.Parent.OpenPos
local ClosedPos = script.Parent.Parent.Parent.ClosedPos
local CD = script.Parent
local TS = game.TweenService
local OpenSound = Hitbox.OpenSound
local CloseSound = Hitbox.CloseSound

local OpenTween = TS:Create(Primary,TweenInfo.new(0.5,Enum.EasingStyle.Bounce),{CFrame = OpenPos.CFrame})
local CloseTween = TS:Create(Primary,TweenInfo.new(0.3,Enum.EasingStyle.Back),{CFrame = ClosedPos.CFrame})

local Open = false
function OnClicked()
	Open = not Open
if Open then
		CD.MaxActivationDistance = 0
		OpenSound:Play()
		OpenTween:Play()
		wait(0.5)
		CD.MaxActivationDistance = 5
	else
		CD.MaxActivationDistance = 0
		CloseSound:Play()
		CloseTween:Play()
		wait(0.2)
		CD.MaxActivationDistance = 5
		
	end
	
end
CD.MouseClick:Connect(OnClicked)
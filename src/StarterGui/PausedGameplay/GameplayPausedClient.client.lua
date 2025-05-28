local GuiService = game:GetService("GuiService")
local Tweenservice = game:GetService('TweenService')
local player = game.Players.LocalPlayer

GuiService:SetGameplayPausedNotificationEnabled(false)

local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function visibleOff()
	Tweenservice:Create(script.Parent.Container.Notif, fadeOut, {
		BackgroundTransparency = 1
	}):Play()
	Tweenservice:Create(script.Parent.Container.Notif.UIStroke, fadeOut, {
		Transparency = 1
	}):Play()
	Tweenservice:Create(script.Parent.Container.Notif.Label, fadeOut, {
		TextTransparency = 1
	}):Play()
	task.wait(0.3)
	script.Parent.Container.Visible = false
end

local function visibleOn()
	script.Parent.Container.Visible = true
	Tweenservice:Create(script.Parent.Container.Notif, fadeIn, {
		BackgroundTransparency = 0.3
	}):Play()
	Tweenservice:Create(script.Parent.Container.Notif.UIStroke, fadeIn, {
		Transparency = 0.3
	}):Play()
	Tweenservice:Create(script.Parent.Container.Notif.Label, fadeIn, {
		TextTransparency = 0
	}):Play()
end

local function onPauseStateChanged()
	if player.GameplayPaused then
		visibleOn()
	else
		visibleOff()
	end
end

player:GetPropertyChangedSignal("GameplayPaused"):Connect(onPauseStateChanged)
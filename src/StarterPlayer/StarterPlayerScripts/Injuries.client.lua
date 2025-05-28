local tws = game:GetService("TweenService")

local plr = game.Players.LocalPlayer

local cam = workspace.CurrentCamera

local injuriesFolder = nil

local blackEyeBrightness = -0.2
local blackEyeBlur = 5

local originalPainKillerCC = nil
local painkillerCC = nil
local painkillerLowTween = nil

local injuryEffects = {
	BlackEye = {
		Add = function()
			local blur = Instance.new("BlurEffect")
			blur.Name = "BlackEyeBlur"


			local cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "BlackEyeColorCorrection"

			local painkillerMultiplier = 1
			if plr:GetAttribute("PainkillerTimer") ~= nil then
				painkillerMultiplier = 0.2
			end

			blur.Size = blackEyeBlur*painkillerMultiplier
			cc.Brightness = blackEyeBrightness*painkillerMultiplier

			blur.Parent = cam
			cc.Parent = cam
		end,

		Remove = function()
			cam.BlackEyeBlur:Destroy()
			cam.BlackEyeColorCorrection:Destroy()
		end,

		Update = function()
			local cc = cam:FindFirstChild("BlackEyeColorCorrection")
			local blur = cam:FindFirstChild("BlackEyeBlur")

			local painkillerMultiplier = 1
			if plr:GetAttribute("PainkillerTimer") ~= nil then
				painkillerMultiplier = 0.2
			end

			blur.Size = blackEyeBlur*painkillerMultiplier
			cc.Brightness = blackEyeBrightness*painkillerMultiplier
		end,
	}
}

local function onInjuryAdded(injuryValue)
	local effects = injuryEffects[injuryValue.Name]
	if effects then
		effects.Add()
	end
end

local function onInjuryRemoved(injuryValue)
	local effects = injuryEffects[injuryValue.Name]
	if effects then
		effects.Remove()
	end
end

local function onPainkillerStatusChanged()
	local painkillerTimer = plr:GetAttribute("PainkillerTimer")
	if painkillerTimer ~= nil then
		painkillerCC.Parent = cam

		if painkillerTimer < 30 then
			if painkillerLowTween.PlaybackState ~= Enum.PlaybackState.Playing then
				painkillerLowTween:Play()
			end
		elseif painkillerLowTween.PlaybackState == Enum.PlaybackState.Playing then
			painkillerLowTween:Cancel()

			painkillerCC.Brightness = originalPainKillerCC.Brightness
			painkillerCC.Contrast = originalPainKillerCC.Contrast
			painkillerCC.TintColor = originalPainKillerCC.TintColor
		end
	else
		painkillerCC.Parent = nil
	end

	for i,injuryValue in pairs(injuriesFolder:GetChildren()) do
		local effects = injuryEffects[injuryValue.Name]
		if effects then
			effects.Update()
		end
	end
end

plr:GetAttributeChangedSignal("PainkillerTimer"):Connect(onPainkillerStatusChanged)

injuriesFolder = plr:WaitForChild("Injuries")
originalPainKillerCC = script:WaitForChild("PainkillerColorCorrection")
painkillerCC = originalPainKillerCC:Clone()

painkillerLowTween = tws:Create(painkillerCC, TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In, -1, true), {Brightness = 0, Contrast = 0, TintColor = Color3.new(1, 1, 1)})

injuriesFolder.ChildAdded:Connect(onInjuryAdded)
injuriesFolder.ChildRemoved:Connect(onInjuryRemoved)
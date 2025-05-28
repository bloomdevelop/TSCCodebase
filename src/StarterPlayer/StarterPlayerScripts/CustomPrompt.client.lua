local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local GamepadButtonImage = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png",
}

local KeyboardButtonImage = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png",
}

local KeyboardButtonIconMapping = {
	["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[","] = "rbxasset://textures/ui/Controls/comma.png",
	["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
	["."] = "rbxasset://textures/ui/Controls/period.png",
	[" "] = "rbxasset://textures/ui/Controls/spacebar.png",
}

local KeyCodeToTextMapping = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12",
	[Enum.KeyCode.PageUp] = "PgUp",
	[Enum.KeyCode.PageDown] = "PgDn",
	[Enum.KeyCode.Home] = "Home",
	[Enum.KeyCode.End] = "End",
	[Enum.KeyCode.Insert] = "Ins",
	[Enum.KeyCode.Delete] = "Del"
}

local KeyCodeToFontSize = {
	[Enum.KeyCode.LeftControl] = 12,
	[Enum.KeyCode.RightControl] = 12,
	[Enum.KeyCode.LeftAlt] = 12,
	[Enum.KeyCode.RightAlt] = 12,
	[Enum.KeyCode.F10] = 12,
	[Enum.KeyCode.F11] = 12,
	[Enum.KeyCode.F12] = 12,
	[Enum.KeyCode.PageUp] = 8,
	[Enum.KeyCode.PageDown] = 8,
	[Enum.KeyCode.Home] = 8,
	[Enum.KeyCode.End] = 10,
	[Enum.KeyCode.Insert] = 10,
	[Enum.KeyCode.Delete] = 10,
}

local PlayerGui

local LocalPlayer = Players.LocalPlayer
while LocalPlayer == nil do
	Players.ChildAdded:wait()
	LocalPlayer = Players.LocalPlayer
end

PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function getScreenGui(): ScreenGui
	local screenGui = PlayerGui:FindFirstChild("ProximityPrompts")
	if screenGui == nil then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ProximityPrompts"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = PlayerGui
	end
	return screenGui
end

local function createPrompt(prompt: ProximityPrompt, inputType, gui: BasePlayerGui)
	local tweensForButtonHoldBegin: {Tween} = {}
	local tweensForButtonHoldEnd: {Tween} = {}
	local tweensForFadeOut: {Tween} = {}
	local tweensForFadeIn: {Tween} = {}

	local tweenInfoInFullDuration = TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfoOutHalfSecond = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfoFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfoQuick = TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

	local promptUI = script.Prompt:Clone()

	local frame = promptUI.ButtonFrame
	local resizeableInputFrame = frame.InputFrame.ResizeableInputFrame

	local inputframe = frame.InputFrame
	local textframe = frame.TextFrame

	table.insert(tweensForFadeOut, TweenService:Create(inputframe, tweenInfoFast, { Transparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(inputframe, tweenInfoFast, { Transparency = 0.7 }))		
	table.insert(tweensForFadeOut, TweenService:Create(inputframe.Corner, tweenInfoFast, { ImageTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(inputframe.Corner, tweenInfoFast, { ImageTransparency = 0 }))		

	table.insert(tweensForButtonHoldBegin, TweenService:Create(textframe, tweenInfoFast, { Transparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(textframe, tweenInfoFast, { Transparency = 0.7 }))	
	table.insert(tweensForFadeOut, TweenService:Create(textframe, tweenInfoFast, { Transparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(textframe, tweenInfoFast, { Transparency = 0.7 }))		

	local actionText = Instance.new("TextLabel")
	actionText.Name = "ActionText"
	actionText.Size = UDim2.fromScale(1, 1)
	actionText.Font = Enum.Font.SciFi
	actionText.TextSize = 19
	actionText.BackgroundTransparency = 1
	actionText.TextColor3 = Color3.new(1, 1, 1)
	actionText.TextXAlignment = Enum.TextXAlignment.Left
	actionText.Parent = frame.TextFrame

	local objectText = Instance.new("TextLabel")
	objectText.Name = "ObjectText"
	objectText.Size = UDim2.fromScale(1, 1)
	objectText.Font = Enum.Font.SciFi
	objectText.TextSize = 14
	objectText.BackgroundTransparency = 1
	objectText.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	objectText.TextXAlignment = Enum.TextXAlignment.Left
	objectText.Parent = frame.TextFrame

	table.insert(tweensForButtonHoldBegin, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(objectText, tweenInfoFast, { TextTransparency = 0 }))	

	table.insert(tweensForButtonHoldBegin, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForButtonHoldEnd, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 1 }))
	table.insert(tweensForFadeIn, TweenService:Create(actionText, tweenInfoFast, { TextTransparency = 0 }))
	
	------
	actionText.TextTransparency = 1
	objectText.TextTransparency = 1
	textframe.Transparency = 1
	inputframe.Transparency = 1
	inputframe.Corner.Transparency = 1

	if inputType == Enum.ProximityPromptInputType.Gamepad then
		if GamepadButtonImage[prompt.GamepadKeyCode] then
			local icon = Instance.new("ImageLabel")
			icon.Name = "ButtonImage"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Size = UDim2.fromOffset(24, 24)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.Image = GamepadButtonImage[prompt.GamepadKeyCode]
			icon.Parent = resizeableInputFrame

			table.insert(tweensForFadeOut, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 1 }))
			table.insert(tweensForFadeIn, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 0 }))
			
			icon.ImageTransparency = 1
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		local buttonImage = Instance.new("ImageLabel")
		buttonImage.Name = "ButtonImage"
		buttonImage.BackgroundTransparency = 1
		buttonImage.Size = UDim2.fromOffset(25, 31)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.fromScale(0.5, 0.5)
		buttonImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		buttonImage.Parent = resizeableInputFrame

		table.insert(tweensForFadeOut, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 1 }))
		table.insert(tweensForFadeIn, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 0 }))
		
		buttonImage.ImageTransparency = 1
	else
		local buttonImage = Instance.new("ImageLabel")
		buttonImage.Name = "ButtonImage"
		buttonImage.BackgroundTransparency = 1
		buttonImage.Size = UDim2.fromOffset(28, 30)
		buttonImage.AnchorPoint = Vector2.new(0.5, 0.5)
		buttonImage.Position = UDim2.fromScale(0.5, 0.5)
		buttonImage.Image = "rbxasset://textures/ui/Controls/key_single.png"
		buttonImage.Parent = resizeableInputFrame

		table.insert(tweensForFadeOut, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 1 }))
		table.insert(tweensForFadeIn, TweenService:Create(buttonImage, tweenInfoQuick, { ImageTransparency = 0 }))
		
		buttonImage.ImageTransparency = 1

		local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)

		local buttonTextImage = KeyboardButtonImage[prompt.KeyboardKeyCode]
		if buttonTextImage == nil then
			buttonTextImage = KeyboardButtonIconMapping[buttonTextString]
		end

		if buttonTextImage == nil then
			local keyCodeMappedText = KeyCodeToTextMapping[prompt.KeyboardKeyCode]
			if keyCodeMappedText then
				buttonTextString = keyCodeMappedText
			end
		end

		if buttonTextImage then
			local icon = Instance.new("ImageLabel")
			icon.Name = "ButtonImage"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Size = UDim2.fromOffset(36, 36)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.Image = buttonTextImage
			icon.Parent = resizeableInputFrame

			table.insert(tweensForFadeOut, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 1 }))
			table.insert(tweensForFadeIn, TweenService:Create(icon, tweenInfoQuick, { ImageTransparency = 0 }))
			
			icon.ImageTransparency = 1
		elseif buttonTextString ~= nil and buttonTextString ~= '' then
			local buttonText = Instance.new("TextLabel")
			buttonText.Name = "ButtonText"
			buttonText.Position = UDim2.fromOffset(0, -1)
			buttonText.Size = UDim2.fromScale(1, 1)
			buttonText.Font = Enum.Font.GothamMedium

			local buttonTextSize = KeyCodeToFontSize[prompt.KeyboardKeyCode]
			if buttonTextSize == nil then
				buttonTextSize = 14
			end
			buttonText.TextSize = buttonTextSize

			buttonText.BackgroundTransparency = 1
			buttonText.TextColor3 = Color3.new(1, 1, 1)
			buttonText.TextXAlignment = Enum.TextXAlignment.Center
			buttonText.Text = buttonTextString
			buttonText.Parent = resizeableInputFrame

			table.insert(tweensForFadeOut, TweenService:Create(buttonText, tweenInfoQuick, { TextTransparency = 1 }))
			table.insert(tweensForFadeIn, TweenService:Create(buttonText, tweenInfoQuick, { TextTransparency = 0 }))
			
			buttonText.TextTransparency = 1	
		else
			error("ProximityPrompt '" .. prompt.Name .. "' has an unsupported keycode for rendering UI: " .. tostring(prompt.KeyboardKeyCode))
		end
	end

	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local button = Instance.new("TextButton")
		button.BackgroundTransparency = 1
		button.TextTransparency = 1
		button.Size = UDim2.fromScale(1, 1)
		button.Parent = promptUI
		button.Selectable = false

		local buttonDown = false

		button.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and
				input.UserInputState ~= Enum.UserInputState.Change then
				prompt:InputHoldBegin()
				buttonDown = true
			end
		end)
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if buttonDown then
					buttonDown = false
					prompt:InputHoldEnd()
				end
			end
		end)

		promptUI.Active = true
	end

	if prompt.HoldDuration > 0 then
		local fillBar = Instance.new("Frame")
		fillBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		fillBar.BorderColor3 = Color3.fromRGB(255, 255, 255)
		fillBar.Size = UDim2.fromScale(0, 1)
		fillBar.ZIndex = 3
		fillBar.Parent = inputframe

		table.insert(tweensForButtonHoldBegin, TweenService:Create(fillBar, tweenInfoInFullDuration, { Size = UDim2.fromScale(1, 1) }))
		table.insert(tweensForButtonHoldEnd, TweenService:Create(fillBar, tweenInfoOutHalfSecond, { Size = UDim2.fromScale(0, 1) }))
	end

	local holdBeganConnection
	local holdEndedConnection
	local triggeredConnection
	local triggerEndedConnection

	if prompt.HoldDuration > 0 then
		holdBeganConnection = prompt.PromptButtonHoldBegan:Connect(function()
			for _, tween in ipairs(tweensForButtonHoldBegin) do
				tween:Play()
			end
		end)

		holdEndedConnection = prompt.PromptButtonHoldEnded:Connect(function()
			for _, tween in ipairs(tweensForButtonHoldEnd) do
				tween:Play()
			end
		end)
	end

	triggeredConnection = prompt.Triggered:Connect(function()
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
	end)

	triggerEndedConnection = prompt.TriggerEnded:Connect(function()
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Play()
		end
	end)

	local function updateUIFromPrompt()
		-- todo: Use AutomaticSize instead of GetTextSize when that feature becomes available
		local actionTextSize = TextService:GetTextSize(prompt.ActionText, 19, Enum.Font.SciFi, Vector2.new(1000, 1000))
		local objectTextSize = TextService:GetTextSize(prompt.ObjectText, 14, Enum.Font.SciFi, Vector2.new(1000, 1000))
		local maxTextWidth = math.max(actionTextSize.X, objectTextSize.X)
		local promptHeight = 72
		local promptWidth = 72
		local textPaddingLeft = 24

		local textWidth = 0

		if (prompt.ActionText ~= nil and prompt.ActionText ~= '') or
			(prompt.ObjectText ~= nil and prompt.ObjectText ~= '') then
			textWidth = maxTextWidth + textPaddingLeft*2
		end

		local actionTextYOffset = 0
		if prompt.ObjectText ~= nil and prompt.ObjectText ~= '' then
			actionTextYOffset = 9
		end
		actionText.Position = UDim2.new(0, textPaddingLeft, 0, actionTextYOffset)
		objectText.Position = UDim2.new(0, textPaddingLeft, 0, -10)

		actionText.Text = prompt.ActionText
		objectText.Text = prompt.ObjectText
		actionText.AutoLocalize = prompt.AutoLocalize
		actionText.RootLocalizationTable = prompt.RootLocalizationTable
		objectText.AutoLocalize = prompt.AutoLocalize
		objectText.RootLocalizationTable = prompt.RootLocalizationTable

		promptUI.Size = UDim2.fromOffset(promptWidth + textWidth, promptHeight)
		promptUI.SizeOffset = Vector2.new(prompt.UIOffset.X / promptUI.Size.Width.Offset, prompt.UIOffset.Y / promptUI.Size.Height.Offset)

		inputframe.Size = UDim2.fromOffset(promptWidth, promptHeight)
		textframe.Size = UDim2.fromOffset(textWidth, promptHeight)
		textframe.Position = UDim2.fromOffset(promptWidth, 0)
	end

	local changedConnection = prompt.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()

	promptUI.Adornee = prompt.Parent
	promptUI.Parent = gui
	
	for _, tween in ipairs(tweensForFadeIn) do
		tween:Play()
	end

	local function cleanup()
		if holdBeganConnection then
			holdBeganConnection:Disconnect()
		end

		if holdEndedConnection then
			holdEndedConnection:Disconnect()
		end

		triggeredConnection:Disconnect()
		triggerEndedConnection:Disconnect()
		changedConnection:Disconnect()
		
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
		task.wait(0.2)

		promptUI.Parent = nil
	end

	return cleanup
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	if prompt.Style ~= Enum.ProximityPromptStyle.Custom then return end
	local gui = getScreenGui()
	local cleanupFunction = createPrompt(prompt, inputType, gui)
	prompt.PromptHidden:Wait()
	cleanupFunction()
end)
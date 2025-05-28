-- // Steven_Scripts, 2022

local tws = game:GetService("TweenService")
local cs = game:GetService("CollectionService")
local rst = game:GetService("ReplicatedStorage")
local rs = game:GetService("RunService")

local remotesFolder = rst.Remotes

local plr = game.Players.LocalPlayer

local mouse = plr:GetMouse()

local ui = script.Parent.Parent
local dishwashingUI = ui.Dishwashing
local frame = dishwashingUI.Frame
local plate = frame.Plate

local lastMousePos = Vector2.new(mouse.X, mouse.Y)

-- based off of percent of the plate size, not pixels
local minScrubThreshold = 0.1
local maxScrubThreshold = 0.35

local currentSink = nil
local platesLeft = 4
local cleanProgress = 0

local scrubbing = false

local plateCooldown = false

local plateInTween = tws:Create(plate, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)})
local plateOutTween = tws:Create(plate, TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(4, 0, 0.5, 0)})
local plateBumpTween = tws:Create(plate, TweenInfo.new(.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)})

local animationTracks = {}

local rng = Random.new()

local function plateOut()
	script.Clink:Play()
	plateOutTween:Play()

	task.wait(.4)
end

local function plateIn()
	if plateOutTween.PlaybackState == Enum.PlaybackState.Playing then plateOutTween:Cancel() end
	plate.Position = UDim2.new(-4, 0, 0.5, 0)
	plate.Filth.ImageTransparency = 0

	script.Slide:Play()
	plateInTween:Play()

	task.wait(.4)
end

local function updatePlateCount()
	frame.PlatesLeft.Text = platesLeft.." plates left"
end

local function selectSink(newSink)
	currentSink = newSink
	if newSink == nil then
		---- Cancel
		dishwashingUI.Visible = false

		scrubbing = false
		plateCooldown = false

		cleanProgress = 0

		animationTracks.Washing:Stop()
		animationTracks.SinkOff:Play()
	else
		---- Start
		platesLeft = 4
		updatePlateCount()
		
		if rng:NextInteger(1, 100) == 1 then
			frame.Instructions.Text = "get to scrubbing nerd"
		else
			frame.Instructions.Text = "Scrub your cursor back and forth across the plate to clean it."
		end
		
		dishwashingUI.Visible = true

		plate.Position = UDim2.new(0.5, 0, 0.5, 0)
		plate.Filth.ImageTransparency = 0

		animationTracks.SinkOn:Play()
		animationTracks.Washing:Play()

		local interrupted = false
		local lastHealth = nil
		while currentSink == newSink do
			task.wait(.2)
			local char = plr.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					if lastHealth == nil then
						lastHealth = hum.Health
					end

					if hum.Health >= lastHealth then
						lastHealth = hum.Health

						local root = char:FindFirstChild("HumanoidRootPart")
						if root then 
							local distance = (root.Position - newSink.PrimaryPart.Position).Magnitude

							if distance > 6 then
								-- Player walked away
								interrupted = true
								break
							end
						else
							-- Root part is missing
							interrupted = true
							break
						end
					else
						-- Player took damage
						interrupted = true
						break
					end
				else
					-- Player died
					interrupted = true
					break
				end
			else
				-- Player is respawning
				interrupted = true
				break
			end
		end

		if interrupted then
			remotesFolder.JobStations.Stop:FireServer(currentSink, false)
			selectSink(nil)
		end
	end
end

local function nextPlate()
	platesLeft = platesLeft-1
	updatePlateCount()

	plateOut()

	if platesLeft > 0 then
		plateIn()
	else
		remotesFolder.JobStations.Stop:FireServer(currentSink, true)
		selectSink(nil)
	end
end

local function mouseMove()
	local newMousePos = Vector2.new(mouse.X, mouse.Y)

	if currentSink ~= nil then
		if plateCooldown == false then
			local uiCenter = frame.AbsolutePosition + frame.AbsoluteSize/2
			local mouseDistanceFromUICenter = (uiCenter - newMousePos).Magnitude

			local onPlate = mouseDistanceFromUICenter <= (frame.AbsoluteSize.X/2)
			if onPlate then 
				dishwashingUI.Sponge.ImageTransparency = 0
			else
				dishwashingUI.Sponge.ImageTransparency = 0.8
			end

			if scrubbing == false and onPlate then
				local uiCenter = frame.AbsolutePosition + frame.AbsoluteSize/2

				dishwashingUI.Sponge.ImageTransparency = 0

				local mouseMoveDistance = (lastMousePos - newMousePos).Magnitude

				local minScrubThresholdPixels = minScrubThreshold*plate.AbsoluteSize.X
				local maxScrubThresholdPixels = maxScrubThreshold*plate.AbsoluteSize.X

				if mouseMoveDistance > minScrubThresholdPixels then
					---- scrub it
					scrubbing = true

					local scrubSeverity = (mouseMoveDistance-minScrubThresholdPixels) / maxScrubThresholdPixels
					scrubSeverity = math.clamp(scrubSeverity, 0, 1)

					local scrubSound = script.Scrub:Clone()

					scrubSound.TimePosition = 0.1
					scrubSound.PlaybackSpeed = 1 + scrubSeverity/2

					scrubSound.Parent = script
					scrubSound:Play()

					game.Debris:AddItem(scrubSound, 1)

					cleanProgress = math.clamp(cleanProgress+(0.08*scrubSeverity), 0, 1)

					plate.Filth.ImageTransparency = cleanProgress

					if cleanProgress == 1 then
						cleanProgress = 0
						nextPlate()
					end

					plate.Position = UDim2.new(0.5, 0, 0.5, 5)
					plateBumpTween:Play()

					task.wait(.15)
					scrubbing = false
				end
			end
		else
			dishwashingUI.Sponge.ImageTransparency = 0.8
		end
	end

	lastMousePos = newMousePos
end

local function onRenderStepped()
	if currentSink ~= nil then
		dishwashingUI.Sponge.Position = UDim2.new(0, mouse.X, 0, mouse.Y+5)
	end
end

local function onCharacterAdded(char)
	local hum = char:WaitForChild("Humanoid")
	local animator = hum:WaitForChild("Animator")

	animationTracks = {}
	for i,animation in pairs(script.Animations:GetChildren()) do
		animationTracks[animation.Name] = animator:LoadAnimation(animation)
	end
end

local module = {}

function module:SetUp(sink)
	local cooldownValue = sink.Cooldown

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Sink"
	prompt.ActionText = "Wash dishes"
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 5
	prompt.Style = Enum.ProximityPromptStyle.Custom

	local primaryPart = sink.PrimaryPart
	if primaryPart == nil then
		repeat task.wait(10) until sink.PrimaryPart ~= nil
		primaryPart = sink.PrimaryPart
	end

	prompt.Parent = primaryPart

	prompt.Triggered:Connect(function()
		if currentSink == nil then
			local canStart = remotesFolder.JobStations.Start:InvokeServer(sink)
			if canStart then
				selectSink(sink)
			end
		end
	end)

	cooldownValue:GetPropertyChangedSignal("Value"):Connect(function()
		if cooldownValue.Value == false then 
			prompt.MaxActivationDistance = 5
		else
			prompt.MaxActivationDistance = 0
		end
	end)
end

mouse.Move:Connect(mouseMove)

rs.RenderStepped:Connect(onRenderStepped)

plr.CharacterAdded:Connect(onCharacterAdded)
if plr.Character ~= nil then
	onCharacterAdded(plr.Character)
end

return module
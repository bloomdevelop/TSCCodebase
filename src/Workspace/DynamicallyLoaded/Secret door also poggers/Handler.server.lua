local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

local CorrectCode = "621591105" --Code to gib the keyword

CorrectCode = tostring(math.random(100000000,999999999))
print(CorrectCode)

script.Parent.FileCabinet1["1-A"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,1,1) .. "-A"
script.Parent.FileCabinet2["1-A"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,2,2) .. "-A"
script.Parent.FileCabinet3["1-A"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,3,3) .. "-A"

script.Parent.FileCabinet1["1-B"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,4,4) .. "-B"
script.Parent.FileCabinet2["1-B"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,5,5) .. "-B"
script.Parent.FileCabinet3["1-B"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,6,6) .. "-B"

script.Parent.FileCabinet1["1-C"].Slide.FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,7,7) .. "-C"
script.Parent.FileCabinet2["1-C"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,8,8) .. "-C"
script.Parent.FileCabinet3["1-C"].FunnyPart.SurfaceGui.TextLabel.Text = string.sub(CorrectCode,9,9) .. "-C"

local CurrentCode = ""

local Keypad = script.Parent.FileCabinet1["1-C"].Slide.Keypad.Keys

local keypad = {
	zero = Keypad["0"],
	one = Keypad["1"],
	two = Keypad["2"],
	three = Keypad["3"],
	four = Keypad["4"],
	five = Keypad["5"],
	six = Keypad["6"],
	seven = Keypad["7"],
	eight = Keypad["8"],
	nine = Keypad["9"],
	cancel = Keypad.cancel,
	accept = Keypad.accept,
}

local code = {
	zero = 0,
	one = 1,
	two = 2,
	three = 3,
	four = 4,
	five = 5,
	six = 6,
	seven = 7,
	eight = 8,
	nine = 9,	
}

local Moving = false

for v,i in pairs(keypad) do
	if i:FindFirstChildWhichIsA("ClickDetector") then
		i:FindFirstChildWhichIsA("ClickDetector").MouseClick:Connect(function(plr)
			if script.Parent.Radio.Activated.Value == false and Moving == false then
				local clickSound = script.Parent.Sounds.Click11:Clone()
				clickSound.Parent = i
				clickSound.Name = "SoundIgnore"
				clickSound:Play()
				debris:AddItem(clickSound,clickSound.TimeLength/clickSound.PlaybackSpeed)

				if code[v] then
					CurrentCode = CurrentCode .. "" .. code[v]
				elseif v == "cancel" then
					CurrentCode = ""
				elseif v == "accept" then
					if CurrentCode == CorrectCode then
						local clickSound = script.Parent.Sounds.Beep:Clone()
						clickSound.Parent = i
						clickSound.Name = "SoundIgnore"
						clickSound:Play()
						debris:AddItem(clickSound,clickSound.TimeLength/clickSound.PlaybackSpeed)
						script.Parent.Radio.Activated.Value = true	
						for _,color in pairs(script.Parent.Radio.RedLines:GetChildren()) do
							color.Color = Color3.fromRGB(106, 255, 80)
							color.Material = Enum.Material.Neon
						end
					else
						local clickSound = script.Parent.Sounds.AccessDeniedTwo:Clone()
						clickSound.Parent = i
						clickSound.Name = "SoundIgnore"
						clickSound:Play()
						debris:AddItem(clickSound,clickSound.TimeLength/clickSound.PlaybackSpeed)
					end
					CurrentCode = 0
				end
			end
		end)
	end
end

local function SlideBack()
	Moving = true
	
	local clickSound = script.Parent.Sounds.Move:Clone()
	clickSound.Parent = script.Parent.Door
	clickSound.Name = "SoundIgnore"
	clickSound:Play()
	
	local tweenBack = tweenService:Create(script.Parent.Door,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
		CFrame = script.Parent.GoBack.CFrame
	})
	tweenBack:Play()
	tweenBack.Completed:Wait()
	wait(0.5)
	local tweenBack = tweenService:Create(script.Parent.Door,TweenInfo.new(4.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
		CFrame = script.Parent.SlideOff.CFrame
	})
	tweenBack:Play()
	tweenBack.Completed:Wait()
	clickSound:Stop()
	wait(5)
	clickSound:Play()
	local tweenBack = tweenService:Create(script.Parent.Door,TweenInfo.new(4.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{
		CFrame = script.Parent.GoBack.CFrame
	})
	tweenBack:Play()
	tweenBack.Completed:Wait()
	wait(0.5)
	local tweenBack = tweenService:Create(script.Parent.Door,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
		CFrame = script.Parent.SlideOn.CFrame
	})
	tweenBack:Play()
	tweenBack.Completed:Wait()
	clickSound:Stop()
	wait(1)
	
	Moving = false
end

script.Parent.Radio.Hitbox.ClickDetector.MouseClick:Connect(function(plr)
	if script.Parent.Radio.Activated.Value == true and Moving == false then
		script.Parent.Radio.Activated.Value = false
		Moving = true
		local clickSound = script.Parent.Sounds.Beep:Clone()
		clickSound.Parent = script.Parent.Radio.Hitbox
		clickSound.Name = "SoundIgnore"
		clickSound:Play()
		debris:AddItem(clickSound,clickSound.TimeLength/clickSound.PlaybackSpeed)
		for _,color in pairs(script.Parent.Radio.RedLines:GetChildren()) do
			color.Color = Color3.fromRGB(255, 89, 89)
			color.Material = Enum.Material.Glass
		end
		if not script.Parent:FindFirstChild("backroomsDoor") then
			local backroom = game.ServerStorage.backroomsDoor
			backroom.Parent = script.Parent
		end
		wait(4)
		SlideBack()
		Moving = false
	end
end)

script.Parent.Button.ClickDetector.MouseClick:Connect(function(plr)
	if Moving == false then
		Moving = true
		local clickSound = script.Parent.Sounds.Beep:Clone()
		clickSound.Parent = script.Parent.Button
		clickSound.Name = "SoundIgnore"
		clickSound:Play()
		debris:AddItem(clickSound,clickSound.TimeLength/clickSound.PlaybackSpeed)
		if not script.Parent:FindFirstChild("backroomsDoor") then
			local backroom = game.ServerStorage.backroomsDoor
			backroom.Parent = script.Parent
		end
		wait(1.5)
		SlideBack()
		Moving = false
	end
end)

local Moving2 = false
local Opend = false

script.Parent.FileCabinet1["1-C"].Slide.Union.ClickDetector.MouseClick:Connect(function(plr)
	if Moving2 == false then
		local clickSound = script.Parent.Sounds.Drawer:Clone()
		clickSound.Parent = script.Parent.FileCabinet1["1-C"].Union
		clickSound.Name = "SoundIgnore"
		clickSound:Play()
		debris:AddItem(clickSound,clickSound.TimeLength/clickSound.PlaybackSpeed)
		if Opend == false then
			Opend = true
			Moving2 = true
			local tweenBack = tweenService:Create(script.Parent.FileCabinet1["1-C"].Slide.PrimaryPart,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				CFrame = script.Parent.FileCabinet1["1-C"].MoveOut.CFrame
			})
			tweenBack:Play()
			tweenBack.Completed:Wait()
			wait(0.1)
			Moving2 = false
		else
			Opend = false
			Moving2 = true
			local tweenBack = tweenService:Create(script.Parent.FileCabinet1["1-C"].Slide.PrimaryPart,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				CFrame = script.Parent.FileCabinet1["1-C"].MoveNormal.CFrame
			})
			tweenBack:Play()
			tweenBack.Completed:Wait()
			wait(0.1)
			Moving2 = false
		end
	end
end)
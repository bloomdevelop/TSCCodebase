-- // Steven_Scripts, 2022

local rst = game:GetService("ReplicatedStorage")
local tws = game:GetService("TweenService")
local cp = game:GetService("ContentProvider")
local ss = game:GetService("SoundService")

local bindablesFolder = rst.BindableFunction
-- hayper I hope you know this is the name of an actual object class which makes this really bad practice
local soundStorage = ss.SoundStorage
local riotInfo = workspace.RiotInfo

local plr = game.Players.LocalPlayer

local ui = script.Parent

local cam = workspace.CurrentCamera

local fighting = false
local songTransitioning = false

local lastTimeShot = os.clock()

--------------------

local flash = Instance.new("ColorCorrectionEffect")
flash.Parent = cam

local flashTween = tws:Create(flash, TweenInfo.new(.5), {Brightness = 0})

local iconTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)

local leftIconInTween = tws:Create(ui.RiotEnabled.LeftIcon, iconTweenInfo, {Position = UDim2.new(0, 0, 0.5, 0)})
local rightIconInTween = tws:Create(ui.RiotEnabled.RightIcon, iconTweenInfo, {Position = UDim2.new(1, 0, 0.5, 0)})

local leftIconOutTween = tws:Create(ui.RiotEnabled.LeftIcon, iconTweenInfo, {ImageTransparency = 1})
local rightIconOutTween = tws:Create(ui.RiotEnabled.RightIcon, iconTweenInfo, {ImageTransparency = 1})

local startTweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local titleSizeTween = tws:Create(ui.RiotEnabled.Title, startTweenInfo, {TextSize = 24})

local timerInTween = tws:Create(ui.RiotEnabled.Timer, startTweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0})

local killCountDividerTween = tws:Create(ui.KillCount.Divider, startTweenInfo, {BackgroundTransparency = 0})

local killCountLeftInTween1 = tws:Create(ui.KillCount.Left.Combatives, startTweenInfo, {Position = UDim2.new(0, 0, 0, 0)})
local killCountLeftInTween2 = tws:Create(ui.KillCount.Left.NonCombatives, startTweenInfo, {Position = UDim2.new(0, 0, 0.6, 0)})

local killCountRightInTween = tws:Create(ui.KillCount.Right.TestSubjects, startTweenInfo, {Position = UDim2.new(0, 0, 0, 0)})

local endTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local killCountOutTween = tws:Create(ui.KillCount, endTweenInfo, {Position = UDim2.new(0.5, 0, 0, -60)})

local titleOutTween = tws:Create(ui.RiotEnabled.Title, endTweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})

local timerOutTween = tws:Create(ui.RiotEnabled.Timer, endTweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})

local function riotStartEffects()
	ui.RiotEnabled.LeftIcon.ImageTransparency = 0
	ui.RiotEnabled.RightIcon.ImageTransparency = 0
	
	ui.RiotEnabled.LeftIcon.Position = UDim2.new(-6, 0, 0.5, 0)
	ui.RiotEnabled.RightIcon.Position = UDim2.new(7, 0, 0.5, 0)
	
	ui.RiotEnabled.Title.TextTransparency = 0
	ui.RiotEnabled.Title.TextStrokeTransparency = 0
	
	ui.RiotEnabled.Title.TextSize = 48
	ui.RiotEnabled.Title.Visible = false
	
	ui.RiotEnabled.Timer.TextTransparency = 1
	ui.RiotEnabled.Timer.TextStrokeTransparency = 1
	
	ui.KillCount.Position = UDim2.new(0.5, 0, 0, 40)
	
	ui.KillCount.Divider.BackgroundTransparency = 1
	
	ui.KillCount.Left.Combatives.Position = UDim2.new(1, 0, 0, 0)
	ui.KillCount.Left.NonCombatives.Position = UDim2.new(1, 0, 0.6, 0)
	ui.KillCount.Right.TestSubjects.Position = UDim2.new(-1, 0, 0, 0)
	
	ui.RiotEnabled.Visible = true
	ui.KillCount.Visible = true
	
	leftIconInTween:Play()
	rightIconInTween:Play()
	
	task.wait(1)
	
	ui.RiotEnabled.Title.Visible = true
	
	flash.Brightness = 1
	
	script.RiotStart:Play()
	
	flashTween:Play()
	
	task.wait(3)
	
	leftIconOutTween:Play()
	rightIconOutTween:Play()
	
	titleSizeTween:Play()
	timerInTween:Play()
	
	killCountDividerTween:Play()
	
	killCountLeftInTween1:Play()
	killCountLeftInTween2:Play()
	killCountRightInTween:Play()
end

local function onFightingStateChanged()
	if riotInfo.Rioting.Value == false then return end
	
	local newFightingState = fighting
	
	if songTransitioning then return end
	
	songTransitioning = true
	
	local oldTrack
	
	local newTrack
	local newTrackTransition
	
	if newFightingState == true then
		oldTrack = soundStorage.Music.SystemRiot.Control
		
		newTrack = soundStorage.Music.SystemRiot.Assault
		newTrackTransition = soundStorage.Music.SystemRiot.AssaultTransition
	else
		oldTrack = soundStorage.Music.SystemRiot.Assault
		
		newTrack = soundStorage.Music.SystemRiot.Control
		newTrackTransition = soundStorage.Music.SystemRiot.ControlTransition
	end
	
	-- Stop old track
	oldTrack:Stop()
	
	-- Play transition track and wait for it to end
	newTrackTransition:Play()
	task.wait(newTrackTransition.TimeLength)
	
	-- Double check to make sure the fighting state remained the same
	if newFightingState == fighting then
		-- Play new track
		newTrack:Play()
	end
	
	songTransitioning = false
end

local function onRiotStart()
	coroutine.wrap(riotStartEffects)()
	task.wait(2)
	coroutine.wrap(onFightingStateChanged)()
end

local function onRiotEnd()
	titleOutTween:Play()
	killCountOutTween:Play()
	timerOutTween:Play()
	
	task.delay(1, function()
		ui.RiotEnabled.Visible = false
		ui.KillCount.Visible = false
	end)
	
	local track
	if fighting == true then
		track = soundStorage.Music.SystemRiot.Assault
	else
		track = soundStorage.Music.SystemRiot.Control
	end
	
	-- Fade out song
	for i=2,0,-0.04 do
		task.wait(0.0333)
		track.Volume = i
	end
	track:Stop()
	track.Volume = 2
end

local function onRiotStateChanged()
	if riotInfo.Rioting.Value == true then
		onRiotStart()
	else
		onRiotEnd()
	end
end

local function addZeroIfOneCharacter(text)
	if string.len(text) == 1 then
		return "0"..text
	end
	return text
end

local function onRiotTimerChanged()
	local secondsLeft = riotInfo.TimeLeft.Value
	
	local formattedTime = ""
	
	local mins = math.floor(secondsLeft/60)
	local remainder = secondsLeft - (mins*60)
	
	ui.RiotEnabled.Timer.Text = "Riot ends in "..mins..":"..addZeroIfOneCharacter(remainder)
end

local function onShot(playerWhoShot, hitCharacter)
	if playerWhoShot == plr then
		local playerWhoGotShot = game.Players:GetPlayerFromCharacter(hitCharacter)
		if playerWhoGotShot == nil then
			-- They just shot an NPC, nothing to be alarmed about
			return
		end
	end
	
	lastTimeShot = os.clock()
	
	if fighting == false then
		fighting = true	
		onFightingStateChanged()
	end
	
	-- Wait 28s
	task.wait(40)
	
	-- Check if player has gone without engaging in combat for the last 28s
	if os.clock() - lastTimeShot > 39 then
		-- Yep, no longer fighting
		fighting = false
		onFightingStateChanged()
	end
end

local function onCombativeDeath()
	ui.KillCount.Left.Combatives.Text = "COMBATIVE DEATHS: "..riotInfo.CombativeDeaths.Value
end

local function onNonCombativeDeath()
	ui.KillCount.Left.NonCombatives.Text = "NON-COMBATIVE DEATHS: "..riotInfo.NonCombativeDeaths.Value
end

local function onTestSubjectDeath()
	ui.KillCount.Right.TestSubjects.Text = "TEST SUBJECT DEATHS: "..riotInfo.TestSubjectDeaths.Value
end

riotInfo.Rioting:GetPropertyChangedSignal("Value"):Connect(onRiotStateChanged)
riotInfo.TimeLeft:GetPropertyChangedSignal("Value"):Connect(onRiotTimerChanged)

riotInfo.CombativeDeaths:GetPropertyChangedSignal("Value"):Connect(onCombativeDeath)
riotInfo.NonCombativeDeaths:GetPropertyChangedSignal("Value"):Connect(onNonCombativeDeath)
riotInfo.TestSubjectDeaths:GetPropertyChangedSignal("Value"):Connect(onTestSubjectDeath)

bindablesFolder.GunSystem.Shot.Event:Connect(onShot)

if riotInfo.Rioting.Value == true then
	onRiotStart()
	
	-- Update death counters
	onCombativeDeath()
	onNonCombativeDeath()
	onTestSubjectDeath()
end

cp:PreloadAsync({ui.RiotEnabled.LeftIcon, ui.RiotEnabled.RightIcon, soundStorage.Music.SystemRiot.Assault, soundStorage.Music.SystemRiot.AssaultTransition, soundStorage.Music.SystemRiot.Control, soundStorage.Music.SystemRiot.ControlTransition})
local plr = game.Players.LocalPlayer

local currentRegionValue = plr:WaitForChild("CurrentRegion")

local joinTimestamp = os.clock()
local spawnTimestamp = os.clock()

plr.CharacterAdded:Connect(function()
	spawnTimestamp = os.clock()
end)

local summaryScreen = workspace:WaitForChild("DynamicallyLoaded"):WaitForChild("SummaryScreen")

local function add0IfOneCharacter(text)
	if string.len(text) == 1 then
		return "0"..text
	else
		return text
	end
end

local function formatSeconds(seconds)
	local hours = math.floor(seconds/60/60)
	local minutesRemainder = math.floor((seconds - hours*60*60)/60)
	local secondsRemainder = math.floor(seconds - (hours*60*60) - (minutesRemainder*60))
	
	return add0IfOneCharacter(hours)..":"..add0IfOneCharacter(minutesRemainder)..":"..add0IfOneCharacter(secondsRemainder)
end

while true do
	if summaryScreen:FindFirstChild("ScreenPart") ~= nil then
		local frame = summaryScreen.ScreenPart.SurfaceGui.Background.Frame.Stats
		
		local currentTimestamp = os.clock()
		
		frame.Deaths.Text = "Deaths: "..plr.Deaths.Value
		frame.Kills.Text = "Kills: "..plr.Kills.Value
		frame.TimeAlive.Text = "Time alive: "..formatSeconds(currentTimestamp - spawnTimestamp)
		frame.TimePlaying.Text = "Time playing: "..formatSeconds(currentTimestamp - joinTimestamp)
		
		task.wait(0.1)
	else
		task.wait(10)
	end
end
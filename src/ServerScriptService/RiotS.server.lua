-- // Steven_Scripts, 2022

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

local BindablesFolder = ServerStorage.Bindables

local RiotInfo = workspace.RiotInfo

local chance = 200
local riotPeriod = 15*60

local chanceBonus = 1 -- 1 means no bonus

local riotParts = ReplicatedStorage.RiotParts

local combativeTeams = {
	["Combat Medic"] = true,
	["BWD"] = true,
	["BWD RCU"] = true,
	["BWD UBI"] = true,
	["Blackwater"] = true,
	["Internal Security Bureau"] = true,
	["Juggernaut"] = true,
	["Recontainment Unit"] = true,
	["SDO"] = true,
	["Security Department"] = true,
	["SO Kilo-16"] = true,
	["SO Nova-6"] = true,
	["SO Reaper 1-4"] = true,
	["SOSU"] = true,
	["Delta Horde Control"] = true
}

local function CheckBounds(worldPosition)
	for _,zone in pairs(riotParts:GetChildren())do	
		local size = zone.Size / 2
		local pos = zone.CFrame:PointToObjectSpace(worldPosition)
		if pos.X >= -size.X and  pos.X <= size.X and pos.Y >= -size.Y and  pos.Y <= size.Y and pos.Z >= -size.Z and  pos.Z <= size.Z then
			return true 
		end
	end
	return false
end

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local hum = character:WaitForChild("Humanoid")
		
		local isTestSubject = player.Team == Teams["Test Subject"]
		
		if RiotInfo.Rioting.Value == true and isTestSubject then
			-- print("take your stuff") 
			ServerStorage.Tools["AK-47"]:Clone().Parent = player.Backpack
			ServerStorage.Tools["Card-L3"]:Clone().Parent = player.Backpack
		end
		
		hum.Died:Connect(function()
			if RiotInfo.Rioting.Value == true then
				if isTestSubject then
					RiotInfo.TestSubjectDeaths.Value = RiotInfo.TestSubjectDeaths.Value+1
				else
					local isCombative = combativeTeams[player.Team.Name] == true
					if isCombative then
						RiotInfo.CombativeDeaths.Value = RiotInfo.CombativeDeaths.Value+1
					else
						RiotInfo.NonCombativeDeaths.Value = RiotInfo.NonCombativeDeaths.Value+1
					end
				end
			end
		end)
	end)
end)

local function StartRiot()
	if RiotInfo.Rioting.Value == false then
		RiotInfo.Rioting.Value = true
		
		RiotInfo.TestSubjectDeaths.Value = 0
		RiotInfo.NonCombativeDeaths.Value = 0
		RiotInfo.CombativeDeaths.Value = 0
		
		for _,testSubject in pairs(Teams["Test Subject"]:GetPlayers())do
			if testSubject.Character and testSubject.Character.PrimaryPart and CheckBounds(testSubject.Character.PrimaryPart.Position) then
				ServerStorage.Tools["AK-47"]:Clone().Parent = testSubject.Backpack
				ServerStorage.Tools["Card-L3"]:Clone().Parent = testSubject.Backpack
			end
		end
		
		SoundService.SoundStorage.Alarms.RiotBuzzerTwo:Play()
		
		for secondsLeft=riotPeriod, 1, -1 do
			RiotInfo.TimeLeft.Value = secondsLeft
			task.wait(1)
		end
		
		RiotInfo.Rioting.Value = false
	end
end

BindablesFolder.Riots.ForceRiotStart.Event:Connect(StartRiot)

local rng = Random.new()

while task.wait(riotPeriod) do
	if rng:NextInteger(1, math.ceil(chance/chanceBonus)) == 1 then
		-- Riot roll passed
		-- Reset chance bonus
		chanceBonus = 1
		
		StartRiot()
	else
		-- Riot roll failed
		-- Increase chance for next time
		chanceBonus += 0.2
	end
end
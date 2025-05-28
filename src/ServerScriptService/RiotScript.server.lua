local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

local ServerRemotes = ReplicatedStorage:WaitForChild("ServerRemotes")
local PlayerData = ServerRemotes:WaitForChild("PlayerData")
local GetPlayerRankInGroup = PlayerData:WaitForChild("GetPlayerRankInGroup")

local chance = 25
local riotPeriod = 15*60
local riotting = false

local riotParts = ReplicatedStorage.RiotParts
riotParts:SetPrimaryPartCFrame(riotParts.PrimaryPart.CFrame - Vector3.new(0,150,0))

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
		if riotting and player.Team == Teams["Test Subject"] and CheckBounds(character.PrimaryPart.Position) then
			ServerStorage.Tools["AK-47"]:Clone().Parent = player.Backpack
			ServerStorage.Tools["Card-L3"]:Clone().Parent = player.Backpack
		end
	end)
end)

local function startRiot()
	if not riotting then
		riotting = true
		delay(riotPeriod,function()
			riotting = false
		end)
		--print("RIIIIIOOT")
		for _,testSubject in pairs(Teams["Test Subject"]:GetPlayers())do
			if testSubject.Character and testSubject.Character.PrimaryPart and CheckBounds(testSubject.Character.PrimaryPart.Position) then
				ServerStorage.Tools["AK-47"]:Clone().Parent = testSubject.Backpack
				ServerStorage.Tools["Card-L3"]:Clone().Parent = testSubject.Backpack
			end
		end
		Lighting.Riot.Enabled = true
		SoundService.SoundStorage.Alarms.RiotBuzzerTwo:Play()
		wait(3.1)
		Lighting.Riot.Enabled = false
		SoundService.SoundStorage.Alarms.RiotBuzzer:Play()
	end
end

workspace.RiotStarter.ClickDetector.MouseClick:Connect(function(player)
	local rankInMainGroup = GetPlayerRankInGroup:Invoke(player, 11577231)
	if rankInMainGroup == 11 or rankInMainGroup == 12 or rankInMainGroup ==253 or rankInMainGroup == 255 then
		--print("Starting riot in 30s")
		wait(30)
		startRiot()
	end
end)

while wait(riotPeriod) do
	if math.random(1,chance) == chance  then
		startRiot()
	end
end
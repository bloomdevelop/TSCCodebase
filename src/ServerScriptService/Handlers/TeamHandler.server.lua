local TeamFunction = game.ReplicatedStorage.TeamChange

local Teams = require(game.ReplicatedStorage.Exos_XG.Teams).Teams
local UIDWhitelist = require(game.ReplicatedStorage.Exos_XG.Teams).UserIDList

shared.Teams = function() return require(script.Teams) end

shared.getRank = function(plr)
	wait()
	for Team, Table in pairs(Teams) do
		if plr.Team and Table[1] == plr.Team.Name then
			return plr:GetRankInGroup(Table[2])
		end
	end
end

shared.getRole = function(plr)
	wait()
	for Team, Table in pairs(Teams) do
		if plr.Team and Table[1] == plr.Team.Name then
			return plr:GetRoleInGroup(Table[2])
		end
	end
end

function WLCheck(plr,team)
	local Team = UIDWhitelist[team]
	if Team == nil then
		return false
	end
	for i,v in pairs(Team) do
		if plr.UserId == v then
			return true
		end
	end
	return false
end

local debounce = {}

TeamFunction.OnServerInvoke = function(plr, t, team)
	if debounce[plr] ~= nil then
		debounce[plr] += 1
	else
		debounce[plr] = 1
	end
	--print(debounce)
	if t == "GetTeams" then
		local TeamsTable = {} -- NOTE; format is ["Team Abbreviation"] = Rank
		for Team, Table in pairs(Teams) do
			if (Table[3] ~= nil and plr:GetRankInGroup(Table[2]) >= Table[3]) or (Table[3] == nil and plr:IsInGroup(Table[2])) then
				TeamsTable[Team] = {true, plr:GetRoleInGroup(Table[2])}
			else
				TeamsTable[Team] = {false}
			end
		end
		return TeamsTable
	elseif t == "ChangeTeam" then
		local Table = Teams[team]
		if (Table[3] ~= nil and plr:GetRankInGroup(Table[2]) >= Table[3]) or (Table[3] == nil and plr:IsInGroup(Table[2])) or WLCheck(plr,team) == true then
			plr.Team = game.Teams[Table[1]]
			return true
		else
			return false
		end
	elseif t == "Play" and plr.Character.Humanoid.Health > 0 and not plr.PlayerGui:FindFirstChild("SolitaryGui") then
		plr:LoadCharacter(CFrame.new(workspace[plr.Team.Name .. " Spawn"].Position))
		return "Done"
	end
end

-- make use of an attribute system, instead of while true loops
-- i made this btw, just too lazy -- jaker

task.spawn(function()
	while true do
		task.wait(1)
		for i, p in next, debounce do
			if p > 10 then
				i:Kick("Too many requests")
			elseif p > 0 then
				debounce[i] -= 1
			end
		end
	end
end)

--local avatarUrl = game:GetService('Players'):GetUserThumbnailAsync(i.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
--game.ReplicatedStorage.Remotes.Logger:Invoke({
--	title = "Player spammed team handler",
--	content = "Player **"..i.Name.."** spammed the TeamChange remote **"..p.."** times."..((p > 60) and "\nYou may want to ban them." or ""),
--	thumbnail = avatarUrl
--})
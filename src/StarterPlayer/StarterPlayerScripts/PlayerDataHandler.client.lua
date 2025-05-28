local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

local BindableFunction = ReplicatedStorage:WaitForChild("BindableFunction")
local PlayerData = BindableFunction:WaitForChild("PlayerData")

type Array<V> = {[number]: V}
type Map<K, V> = {[K]: V}

export type GroupData = {
	Name: string,
	Id: number,
	EmblemUrl: number,
	EmblemId: number,
	Rank: number,
	Role: string,
	IsPrimary: boolean,
	IsInClan: false -- Always false, Here because backward complatibility
}

local PlayerGroupData:Map<number, Map<number, GroupData>> = {}
-- PlayerGroupData[PlayerUserId][GroupId]

function handlePlayer(player: Player)
	local groupList: Array<GroupData>?

	local success = pcall(function()
		groupList = GroupService:GetGroupsAsync(player.UserId)
	end)

	if not groupList or not success then
		task.wait(1)
		handlePlayer(player)
		return
	end
	
	PlayerGroupData[player.UserId] = {}
	for _,group in next, groupList :: Array<GroupData> do
		PlayerGroupData[player.UserId][group.Id] = group
	end
end

Players.PlayerAdded:Connect(handlePlayer)
Players.PlayerRemoving:Connect(function(player)
	PlayerGroupData[player.UserId] = nil
end)

task.spawn(function()
	repeat
		handlePlayer(Players.LocalPlayer) -- We are higher priority than other people
		for _,plr in next, Players:GetPlayers() do
			if plr == Players.LocalPlayer then continue end
			handlePlayer(plr)
		end
		task.wait(60)
	until false
end)

PlayerData:WaitForChild("GetPlayerRankInGroup").OnInvoke = function(Player: Player, GroupId: number | string): number
	local GroupId = tonumber(GroupId) or 0
	if not PlayerGroupData[Player.UserId] then handlePlayer(Player) end
	if not PlayerGroupData[Player.UserId] or not PlayerGroupData[Player.UserId][GroupId] then return 0 end
	return PlayerGroupData[Player.UserId][GroupId].Rank
end

PlayerData:WaitForChild("GetPlayerRoleInGroup").OnInvoke = function(Player: Player, GroupId: number | string): string?
	local GroupId = tonumber(GroupId) or 0
	if not PlayerGroupData[Player.UserId] then handlePlayer(Player) end
	if not PlayerGroupData[Player.UserId] or not PlayerGroupData[Player.UserId][GroupId] then return nil end
	return PlayerGroupData[Player.UserId][GroupId].Role
end
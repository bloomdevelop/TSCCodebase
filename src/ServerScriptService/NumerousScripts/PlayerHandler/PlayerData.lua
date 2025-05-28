local MarketPlaceService = game:GetService('MarketplaceService')
local GroupService = game:GetService('GroupService')

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

export type GroupDatas = Map<number, GroupData>

export type AssetData = Map<number, boolean>

export type PlayerDataType = {
	UserId: number,
	Refreshs: Map<string, number>,
	GroupData: GroupDatas,
	AssetData: AssetData,
	SelectedTeam: string,
	FetchGroups: (self: any) -> nil,
	GetGroups: (self: any) -> GroupDatas,
	GetRankInGroup: (self: any, GroupId: number | string) -> number,
	GetRoleInGroup: (self: any, GroupId: number | string) -> string,
	GetOwnsGamePass: (self: any, AssetId: number) -> boolean
}

function PlayerDataFunction(userid: number)
	local PlayerData = setmetatable({
		UserId = userid,
		Refreshs = {
			Groups = 0,
			Assets = 0,
		},
		GroupData = {},
		AssetData = {},
		SelectedTeam = "Menu"
	} :: PlayerDataType, {})
	PlayerData.__index = PlayerData

	function PlayerData:FetchGroups()		
		local groupList: Array<GroupData>?

		local success = pcall(function()
			groupList = GroupService:GetGroupsAsync(PlayerData.UserId)
		end)

		if not groupList or not success then
			task.wait(1)
			return PlayerData:FetchGroups()
		end

		PlayerData.GroupData = {}
		for _,group in next, groupList :: Array<GroupData> do
			PlayerData.GroupData[group.Id] = group
		end

		PlayerData.Refreshs.Groups = tick()
		return true
	end

	function PlayerData:GetGroups()
		if not PlayerData.GroupData or PlayerData.Refreshs.Groups + 60 > tick() then -- update every 1 minute
			PlayerData.FetchGroups()
		end
		return PlayerData.GroupData
	end

	function PlayerData:GetRankInGroup(groupid: number | string)
		PlayerData:GetGroups()
		if PlayerData.GroupData[tonumber(groupid)] ~= nil then
			return PlayerData.GroupData[tonumber(groupid)].Rank
		end
		return 0
	end

	function PlayerData:GetRoleInGroup(groupid: number | string)
		PlayerData:GetGroups()
		if PlayerData.GroupData[tonumber(groupid)] ~= nil then
			return PlayerData.GroupData[tonumber(groupid)].Role
		end
	end

	function PlayerData:GetOwnsGamePass(assetid: number | string)
		if PlayerData.AssetData[assetid] == nil or PlayerData.Refreshs.Assets + 60 > tick() then -- update every 1 minute
			PlayerData.AssetData = {}
			PlayerData.AssetData[assetid] = MarketPlaceService:UserOwnsGamePassAsync(PlayerData.UserId, assetid)
			PlayerData.Refreshs.Assets = tick()
		end
		return PlayerData.AssetData[assetid]
	end

	return PlayerData
end

return PlayerDataFunction
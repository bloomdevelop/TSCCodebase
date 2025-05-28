local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams =  game:GetService("Teams")

local HayperScripts = ServerScriptService:WaitForChild("Hayper's Scripts")
local ScrambleText = require(HayperScripts:WaitForChild("TextScramble"))
local InfectCheck = require(ReplicatedStorage:WaitForChild("InfectedCheckModule"))

local ServerRemotes = ReplicatedStorage:WaitForChild("ServerRemotes")
local PlayerData = ServerRemotes:WaitForChild("PlayerData")
local GetPlayerRankInGroup = PlayerData:WaitForChild("GetPlayerRankInGroup")

local module = {}

--------------------------------------------------------------------------------------------------------------------

export type ChatTag = {
	TagText: number,
	TagColor: Color3
}

export type ExtraData = {
	ChatColor: Color3,
	NameColor: Color3,
	Font: Font,
	TextSize: number,
	Tags: {[number]: ChatTag}
}

export type MessageObject = {
	ExtraData: ExtraData,
	FromSpeaker: string,
	ID: number,
	IsFiltered: boolean,
	MessageLength: number,
	MessageLengthUtf8: number,
	MessageType: string,
	OriginalType: string,
	SpeakerDisplayName: string,
	SpeakerUserId: number,
	Time: number,
	Message: string?,
	FilterResult: TextFilterResult?,
	IsFilterResult: boolean
}

export type Speaker = {
	ChannelJoined: RBXScriptSignal,
	Channels: {[number]: any}, -- idk yet
	ChatService: {[string]: any}, -- idk yet
	EventFolder: {[string]: any}, --idk yet
	ExtraData: ExtraData,
	Muted: RBXScriptSignal,
	MutedSpeakers: {[number]: Speaker},
	Name: string,
	PlayerObj: Player,
	Unmuted: RBXScriptSignal,
	eChannelJoined: RBXScriptSignal,
	eMuted: RBXScriptSignal,
	eUnmuted: RBXScriptSignal
}

export type ChatChannel = {[string]: any} -- Will do this later

--------------------------------------------------------------------------------------------------------------------

-- Cache function for performance
local abs, max, huge = math.abs, math.max, math.huge

local Team: {[string]: Team} = {
	MD = Teams:WaitForChild("Medical Department"),
	CM = Teams:WaitForChild("Combat Medic"),
	UM = Teams:WaitForChild("Utility & Maintenance")
}

local function DeepCopy<K, V>(table:{ [K]: V }): { [K]: V }
	local copy: { [K]: V } = {}
	for k, v in pairs(table) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

-- getDistance from HumanoidRootPart
function module.getDistance(from:Player, to:Player): number
	if not from.Character or not to.Character then return huge end
	if not (from.Character :: Model):FindFirstChild("HumanoidRootPart") or not (to.Character :: Model):FindFirstChild("HumanoidRootPart") then return huge end

	-- Again, Luau
	return abs((((from.Character :: Model):FindFirstChild("HumanoidRootPart") :: Part).Position - ((to.Character :: Model):FindFirstChild("HumanoidRootPart") :: Part).Position).Magnitude)
end

-- return haveTranslator, isTranslatorPrototype
function module.isTranslator(instance: Instance): (boolean, boolean)
	local isPrototype = instance.Name == "Prototype Translator"
	return instance.ClassName == "Tool" and (instance.Name == "Translator" or isPrototype), isPrototype
end

-- Only detect when they are holding it OR wearing it
-- return haveTranslator, isTranslatorPrototype, TranslatorTool
function module.haveTranslator(player: Player): (boolean, boolean, Tool?)
	if not player.Character or not player.Character:FindFirstChild("Torso") then return false, false, nil end

	-- Why? luau?
	for _,i in next, ((player.Character :: Model):FindFirstChild("Torso") :: Part):GetChildren() do
		local isTranslator, isPrototype = module.isTranslator(i)
		if not isTranslator then continue end
		return isTranslator, isPrototype, i :: Tool
	end	

	for _,i in next, (player.Character :: Model):GetChildren() do
		local isTranslator, isPrototype = module.isTranslator(i)
		if not isTranslator then continue end
		return isTranslator, isPrototype, i :: Tool
	end

	return false, false, nil
end

local roleTeams: {[number]: {[number]: any}} = {
	{Team.CM, 13732985, 254, nil},
	{Team.MD, 11649027, 254, nil},
	{Team.MD, 11649027, 251, nil},
	{Team.MD, 11649027, 6, nil},
	{Team.UM, 12022092, 3, nil},
	{Team.CM, nil, nil, 1921023125}
}

function module.isCIP(player: Player): boolean
	for _,roleData in next, roleTeams do
		if player.Team ~= roleData[1] then continue end
		if (roleData[2] ~= nil and roleData[3] ~= nil) and GetPlayerRankInGroup:Invoke(player, roleData[2]) ~= roleData[3] then continue end
		if (roleData[2] == nil or roleData[3] == nil) and roleData[4] ~= player.UserId then continue end
		return true
	end
	return false
end

-- return haveCollar, Collar
function module.haveCollar(player: Player): (boolean, Accessory?)
	if not player.Character then return false end

	for _,i in next, (player.Character :: Model):GetChildren() do
		if i.ClassName ~= "Accessory" then continue end
		if i.Name ~= "AnkleBraclet" or i:GetAttribute("Broken") then continue end
		return true, i :: Accessory
	end

	return false, nil
end

function module.isCISAdministrator(player: Player): boolean
	return GetPlayerRankInGroup:Invoke(player, 14474303) >= 12
end

-- messageObj should be Filtered
function module.ProcessMessage(self: ChatChannel, messageObj: MessageObject, speakerTo:Speaker, speakerFrom:Speaker): MessageObject
	if not workspace:FindFirstChild("LATEXEXPERIMENT") then return messageObj end
	if (not speakerFrom or not speakerTo) or (not speakerFrom.PlayerObj or not speakerTo.PlayerObj) then return messageObj end
	
	local isFromInfected = InfectCheck(speakerFrom.PlayerObj)
	local isToInfected = InfectCheck(speakerTo.PlayerObj)

	if  (speakerTo.Name == speakerFrom.Name) or
		(isFromInfected == isToInfected) then
		return messageObj
	end
	
	if (speakerFrom.PlayerObj.Character and speakerFrom.PlayerObj.Character:FindFirstChild("TranslatorBypass")) or (speakerTo.PlayerObj.Character and speakerTo.PlayerObj.Character:FindFirstChild("TranslatorBypass")) then return messageObj end
	if (isToInfected and module.haveCollar(speakerTo.PlayerObj)) or (isFromInfected and module.haveCollar(speakerFrom.PlayerObj)) then return messageObj end
	if (isToInfected and module.isCIP(speakerTo.PlayerObj)) or (isFromInfected and module.isCIP(speakerFrom.PlayerObj)) then return messageObj end
	if (isToInfected and module.isCISAdministrator(speakerTo.PlayerObj)) or (isFromInfected and module.isCISAdministrator(speakerFrom.PlayerObj)) then return messageObj end
	
	if 15 > module.getDistance(speakerFrom.PlayerObj, speakerTo.PlayerObj) then
		local fromHasTranslator, fromHasPrototype, fromTranslatorTool = module.haveTranslator(speakerFrom.PlayerObj)
		local toHasTranslator, toHasPrototype, toTranslatorTool = module.haveTranslator(speakerTo.PlayerObj)
		
		local fromWordRemain = fromHasPrototype and (fromTranslatorTool:GetAttribute("WordRemain") or 0) or 1
		local toWordRemain = toHasPrototype and (toTranslatorTool:GetAttribute("WordRemain") or 0) or 1

		if fromHasTranslator and fromWordRemain > 0 or toHasTranslator and toWordRemain > 0 then
			if fromHasPrototype then
				fromTranslatorTool:SetAttribute("WordRemain", max(0, fromWordRemain-1))
			elseif toHasPrototype then
				toTranslatorTool:SetAttribute("WordRemain", max(0, toWordRemain-1))
			end
			return messageObj
		end
	end

	local msgObj = DeepCopy(messageObj) :: MessageObject
	msgObj.Message = msgObj.Message and ScrambleText(msgObj.Message :: string) or nil

	return msgObj
end

return module
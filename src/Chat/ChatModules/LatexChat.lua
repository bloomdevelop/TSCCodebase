--[[
FoxxoTrystan
08/20/2022
LatexChat

LatexChat ChatModule : System to handle chat between users, only Latex can speak latex and they will be always be able to hear others latex, latex that has the ability to speak english;
latex toggle using "/latex" or "/l to speak between english or latex, for that latex must be "CIS/CIP" or have a translator for those actions to take place.
Humans may never speak latex but may understand it if having an "Translator" in they inventory.
This system is NOT standalone and required a localscript and RemoteEvent.

Please check those values/functions are correct as those may need ajustements.
> CISTeam -> Value : Team.
> IsCIP -> Function : Group/Rank Check + CIPValue Check.
> InfectedCheckModule -> Require : Module.
> HasTranslator -> Value : "Translator" Tool Name.
---
**WARNING: This script use Asynchronous code to handle "Run Function"**
If any issues or suggestions/feedback, please contact FoxxoTrystan!

Yeep!
--]]

--// Variables/Values
local Chat = game:GetService("Chat")
local ReplicatedModules = Chat:WaitForChild("ClientChatModules")
local ChatConstants = require(ReplicatedModules:WaitForChild("ChatConstants"))
local ChatSettings = require(ReplicatedModules:WaitForChild("ChatSettings"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InfectedCheckModule = require(ReplicatedStorage:WaitForChild("InfectedCheckModule"))
local LatexChatRemote = ReplicatedStorage:WaitForChild("LatexChatRemote")

local errorTextColor = ChatSettings.ErrorMessageTextColor or Color3.fromRGB(245, 50, 50)
local errorExtraData = {ChatColor = errorTextColor}

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local HTTPService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local CISTeam = Teams:WaitForChild("Contained Infected Subject")

local LatexPlayer = {} :: any

--// GetRankInGroup (Replacement Because Roblox Error 505)
local GetRankInGroup: (Who:Player, GroupId:number) -> number
do --Safe GetRank
	local RankCache = {}

	function GetRankInGroup(Who:Player, GroupId:number): number
		local Rank = RankCache[GroupId]
		Rank = Rank and Rank[Who]
		if not Rank then
			repeat
				local Succ, Why = pcall(Who.GetRankInGroup, Who, GroupId)
				Rank = Why
				task.wait(.3)
			until Succ

			local Cache = RankCache[GroupId]
			if Cache then
				Cache[Who] = Rank
			else
				Cache = {
					[Who] = Rank
				}
				RankCache[GroupId] = Cache
			end
		end

		return Rank
	end

	local function ClearCache(Who:Player)
		for i, v in next, RankCache do
			v[Who] = nil
		end
	end
	Players.PlayerRemoving:Connect(ClearCache)
end

--// IsCIP/IsCIS Function
--[[
Check if player is a CIP or a CIS (Not "Actor In Training")
Return boolean.
]]
local function IsCIP(Player: Player): boolean
	if Player.Team == CISTeam then
		if GetRankInGroup(Player, 14474303) ~= 6 then
			return true
		end
	end
	
	local Latex, CIP = InfectedCheckModule(Player)
	if CIP then return true end
	local Latex, CIP = nil
	
	return false
end

--// FilterLatexMessage Function
--[[
Return string.
]]
local function FilterLatexMessage(TextToUse: string, UserID: number): string
	local Success = pcall(function()
		TextToUse = TextService:FilterStringAsync(TextToUse, UserID)
	end)
	if not Success then
		TextToUse = false
	end
	Success = nil
	return TextToUse
end

--// HasTranslator Function
--[[
Check if the player has the translator in they inv or holding it.
Return boolean.
]]
local function HasTranslator(Player: Player): boolean
	local Bool = false
	local Translator = Player.Backpack:FindFirstChild("Translator")
	if (Translator) then
		Bool = true
	else
		local Character = Player.Character
		if (Character) then
			Translator = Character:FindFirstChild("Translator")
			if (Translator) then
				Bool = true
			end
		end
	end
	
	return Bool
end

--// IsSpeakingLatex
--[[
Check if player is speaking latex.
Player must be a Latex then check if that latex can speak english.
Return boolean.
]]
local function IsSpeakingLatex(Player: Player): boolean	
	if InfectedCheckModule(Player) then
		if IsCIP(Player) or HasTranslator(Player) then
			local Charcater = Player.Character
			if (Charcater) then
				if Charcater:GetAttribute("SpeakLatex") == true then
					return true
				else
					return false
				end
			end
		end
		return true
	end
	
	return false
end

--// CanHearLatex function
--[[
Check if player can hear Latex langauge, by being a latex or with a translator.
Return boolean.
]]
local function CanHearLatex(Player: Player): boolean
	if InfectedCheckModule(Player) or HasTranslator(Player) then
		return true
	end
	
	return false
end

--// Run Function
--[[
Main function to handle chat service, if player is not speaking latex message will go unmodified and handeled by the roblox default chatmodule.
If player is speaking latex, will check every player if they can hear it and give the correct message, if player is speaking latex the chat will NOT be modified and will not render and only render on the client.
**WARNING: Asynchronous Code**
Return boolean. (For Default ChatModule Check)
]]
local function Run(ChatService)
	local function LatexChat(speakerName, message, channelName)
		local speakerObj = ChatService:GetSpeaker(speakerName)
		if (speakerObj) then
			local Player = speakerObj:GetPlayer()
			if (Player) then
				if IsSpeakingLatex(Player) then
					if not LatexPlayer[Player.UserId] then
						local Data = {
							Type = "BubbleSettings",
							PlayerUserId = Player.UserId,
							Latex = true
						}
						LatexChatRemote:FireAllClients(Data)
						LatexPlayer[Player.UserId] = true
						Data = nil
					end
					local FilterResult = FilterLatexMessage(message, Player.UserId)
					for i, OtherPlayer in pairs(Players:GetPlayers()) do
						task.spawn(function()
							if (OtherPlayer) then
								local otherspeaker = ChatService:GetSpeaker(OtherPlayer.Name)
								if (otherspeaker) then
									if CanHearLatex(OtherPlayer) then
										otherspeaker:SendMessage(message, channelName, speakerName)
									else
										local FilterMessage = ""
										if (FilterResult) then
											local Success, Result = pcall(function()
												return FilterResult:GetChatForUserAsync(OtherPlayer.UserId)
											end)
											if Success then
												FilterMessage = Result
											end
											Success = nil
										end
										local Data = {
											Type = "Chat",
											Text = FilterMessage,
											PlayerID = Player.UserId
										}
										LatexChatRemote:FireClient(OtherPlayer, Data)
										Data = nil
										FilterMessage = nil
									end
								end
							end
						end)
					end
					FilterResult = nil
				else
					if LatexPlayer[Player.UserId] then
						local Data = {
							Type = "BubbleSettings",
							PlayerUserId = Player.UserId,
							Latex = false
						}
						LatexChatRemote:FireAllClients(Data)
						LatexPlayer[Player.UserId] = nil
						Data = nil
					end
					return false
				end
			end
		end

		return true
	end
	
	Players.PlayerRemoving:Connect(function(Player)
		LatexPlayer[Player.UserId] = nil
	end)
	
	--// Register "LatexChat" Service
	ChatService:RegisterProcessCommandsFunction("LatexChat", LatexChat)
	
	--// DoLatexCommand Function
	--[[
	System to toggle between english/latex language, will check if the user making the cmd is a latex and if yes checking if the user can speak english.
	On language change a "beep" will be heard.
	Return nil.
	]]
	local function DoLatexCommand(fromSpeaker, message, channel)
		if message == nil then
			message = ""
		end

		local speaker = ChatService:GetSpeaker(fromSpeaker)
		if speaker then
			local player = speaker:GetPlayer()

			if player then
				if not InfectedCheckModule(player) then
					speaker:SendSystemMessage("You cannot speak Latex!", channel, errorExtraData)
					local Data = {
						Type = "Notif",
						Title = "Latex Language",
						Text = "You cannot speak Latex!"
					}
					LatexChatRemote:FireClient(player, HTTPService:JSONEncode(Data))
					Data = nil
					return
				end
				
				if not IsCIP(player) and not HasTranslator(player) then
					speaker:SendSystemMessage("You cannot speak English!", channel, errorExtraData)
					local Data = {
						Type = "Notif",
						Title = "Latex Language",
						Text = "You cannot speak English!"
					}
					LatexChatRemote:FireClient(player, HTTPService:JSONEncode(Data))
					Data = nil
					return
				end
				
				local Character = player.Character
				if (Character) then
					if Character:GetAttribute("SpeakLatex") == true then
						Character:SetAttribute("SpeakLatex", false)
						speaker:SendSystemMessage("You are now speaking English!", channel)
						local Data = {
							Type = "Notif",
							Title = "Latex Language",
							Text = "You are now speaking English!"
						}
						LatexChatRemote:FireClient(player, Data)
						Data = nil
						
					else
						Character:SetAttribute("SpeakLatex", true)
						speaker:SendSystemMessage("You are now speaking Latex!", channel)
						local Data = {
							Type = "Notif",
							Title = "Latex Language",
							Text = "You are now speaking Latex!"
						}
						LatexChatRemote:FireClient(player, Data)
						Data = nil
					end
				end
			end
		end
	end
	
	--// LatexCommandsFunction Function
	--[[
	Check if "/latex" or "/l" command has been executed, first check for optimization to avoid checking others stuff.
	Return boolean. (For Default ChatService Check)
	]]
	local function LatexCommandsFunction(fromSpeaker, message, channel)
		local processedCommand = false

		if message == nil then
			error("Message is nil")
		end

		if string.sub(message, 1, 7):lower() == "/latex " or message:lower() == "/latex" then
			DoLatexCommand(fromSpeaker, string.sub(message, 8), channel)
			processedCommand = true
		elseif string.sub(message, 1, 3):lower() == "/l " or message:lower() == "/l" then
			DoLatexCommand(fromSpeaker, string.sub(message, 4), channel)
			processedCommand = true
		end

		return processedCommand
	end
	
	--// Register "latex_commands" Service
	ChatService:RegisterProcessCommandsFunction("latex_commands", LatexCommandsFunction, ChatConstants.StandardPriority)
end

return Run

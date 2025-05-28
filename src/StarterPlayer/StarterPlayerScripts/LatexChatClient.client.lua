--[[
FoxxoTrystan
08/20/2020
LatexChatClient
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Chat = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTPService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LatexChatRemote = ReplicatedStorage:WaitForChild("LatexChatRemote")

local LatexWords = {
	["a"] = "σ",
	["b"] = "£",
	["c"] = "∃",
	["d"] = "₳",
	["e"] = "ε",
	["f"] = "╛",
	["g"] = "Γ",
	["h"] = "µ",
	["i"] = "∩",
	["j"] = "⌠",
	["k"] = "≡",
	["l"] = "Œ",
	["m"] = "ß",
	["n"] = "Þ",
	["o"] = "⌐",
	["p"] = "Æ",
	["q"] = "¶",
	["r"] = "Ω",
	["s"] = "Φ",
	["t"] = "╪",
	["u"] = "↨",
	["v"] = "‡",
	["w"] = "w",
	["x"] = "⋛",
	["y"] = "¥",
	["z"] = "√",
	
	["0"] = "◄",
	["1"] = "●",
	["2"] = "▬",
	["3"] = "▲",
	["4"] = "■",
	["5"] = "▱",
	["6"] = "◈",
	["7"] = "▩",
	["8"] = "▣",
	["9"] = "►"
	
}

local WhiteListWords = {" ", "?", "!", ",", ".", ":", ";", "(", ")", "{", "}", "[", "]", "/", "-", "~", "+", "=", "*", "^", ">", '"', "'", "#", "_", "'", "`", "¨"}

local LatexChatSettings = {
	Transparency = 0.1,
	TextColor3 = Color3.fromRGB(242, 242, 242),
	BackgroundColor3 = Color3.fromRGB(32, 34, 37),
	CornerRadius = UDim.new(0, 6),
	Font = Enum.Font.FredokaOne
}

local RadioChatSettings = {
	CornerEnabled = false,
	TailVisible = false,
	Transparency = 0.15,
	TextSize = 24,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.Sarpanch,
	Padding = 10,
	BubblesSpacing = 1,
	MaxBubbles = 2,
	MinimizeDistance = 60,
	MaxDistance = 130,
	MaxWidth = 400,
	BackgroundImage = {
		Image = "rbxassetid://9591844190",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 8, 1010, 235),
		SliceScale = 0.5
	}
}

local function StringToLatex(TextToUse: string): string
	local LatexMessage = {}
	local Chars = string.split(TextToUse, "")
	for i,v in pairs(Chars) do
		if table.find(WhiteListWords, v) then
			table.insert(LatexMessage, v)
		else
			local ReplaceWord = LatexWords[string.lower(v)]
			if (ReplaceWord) then
				table.insert(LatexMessage, ReplaceWord)
			else
				table.insert(LatexMessage, "•")
			end
		end
	end
	Chars = nil
	return table.concat(LatexMessage)
end

local UserChatSettings = {
	UserSpecificSettings = {
		["RadioPart"] = RadioChatSettings
	}
}

Chat:SetBubbleChatSettings(UserChatSettings)

LatexChatRemote.OnClientEvent:Connect(function(Data)
	if Data.Type == "Chat" then
		local Player = Players:GetPlayerByUserId(Data.PlayerID)
		if (Player) then
			local Character = Player.Character
			if (Character) then
				Chat:Chat(Character, StringToLatex(Data.Text), Enum.ChatColor.White)
			end
			Character = nil
		end
		Player = nil
	elseif Data.Type == "Notif" then
		StarterGui:SetCore("SendNotification", {
			Title = Data.Title,
			Text = Data.Text
		})
	elseif Data.Type == "BubbleSettings" then
		if Data.Latex then
			UserChatSettings.UserSpecificSettings[Data.PlayerUserId] = LatexChatSettings
		else
			UserChatSettings.UserSpecificSettings[Data.PlayerUserId] = {
				CornerRadius = UDim.new(0, 8),
			}
		end
		Chat:SetBubbleChatSettings(UserChatSettings)
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	if UserChatSettings.UserSpecificSettings[Player.UserId] then
		UserChatSettings.UserSpecificSettings[Player.UserId] = nil
	end
end)
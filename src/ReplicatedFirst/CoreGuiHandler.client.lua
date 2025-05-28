local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, function()
	return {
		BubbleChatEnabled = true,
		ClassicChatEnabled = false,
	}
end)